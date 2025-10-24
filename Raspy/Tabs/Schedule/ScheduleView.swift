//
//  ScheduleView.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 16.04.2025.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var selections: SelectedSchedulesStore
    @State private var selectedDate: Date = Date()

    // Жест: внутреннее состояние, чтобы срабатывать один раз на свайп
    @State private var hasSwipedForCurrentDrag = false

    // Networking state
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var allEntries: [ScheduleEntry] = []

    private let service = ScheduleService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()

                content
            }
            .contentShape(Rectangle()) // чтобы жест ловился по всей области
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        // Сработаем один раз, как только превысили порог
                        guard !hasSwipedForCurrentDrag else { return }
                        let threshold: CGFloat = 60
                        if value.translation.width <= -threshold {
                            // свайп влево -> следующий день
                            withAnimation(.easeOut) {
                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                            }
                            hasSwipedForCurrentDrag = true
                        } else if value.translation.width >= threshold {
                            // свайп вправо -> предыдущий день
                            withAnimation(.easeOut) {
                                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                            }
                            hasSwipedForCurrentDrag = true
                        }
                    }
                    .onEnded { _ in
                        hasSwipedForCurrentDrag = false
                    }
            )
            .navigationTitle("Расписание")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    SelectedMenu(
                        groupNames: groupNames,
                        teacherNames: teacherNames,
                        roomNames: roomNames,
                        setPriority: { type, name in
                            selections.setPriority(type: type, name: name)
                        },
                        isPriorityName: { type, name in
                            selections.isPriority(type: type, name: name)
                        },
                        priorityTitle: selections.currentGlobalPriorityName()
                    )

                    // Date-only compact picker
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
            }
            .task(id: reloadTrigger) {
                await loadSchedule()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let errorMessage {
            VStack(spacing: 12) {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Повторить") {
                    Task { await loadSchedule() }
                }
            }
            .padding()
        } else if isLoading {
            ProgressView()
        } else {
            let items = entriesForSelectedDate()
            if items.isEmpty {
                VStack(spacing: 8) {
                    Text(formattedSelectedDate)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Нет пар")
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else if items.count >= 5 {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(formattedSelectedDate)
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        ForEach(items) { entry in
                            LessonCard(entry: entry)
                                .padding(.horizontal, 16)
                        }
                        Spacer(minLength: 12)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text(formattedSelectedDate)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    ForEach(items) { entry in
                        LessonCard(entry: entry)
                            .padding(.horizontal, 16)
                    }
                    Spacer(minLength: 12)
                }
            }
        }
    }

    // MARK: - Data

    private var reloadTrigger: String {
        // Триггер перезагрузки: дата (день) + текущий приоритет
        let dayKey = ScheduleEntry.dateFormatter.string(from: selectedDate)
        let pr = selections.currentGlobalPriority()
        return "\(dayKey)|\(pr?.0 ?? "_")|\(pr?.1 ?? "_")"
    }

    private func loadSchedule() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard let (type, name) = selections.currentGlobalPriority() else {
            allEntries = []
            errorMessage = "Выберите расписание (группа/преподаватель/аудитория)."
            return
        }

        do {
            let entries = try await service.fetch(type: type, name: name, date: selectedDate)
            allEntries = entries
        } catch {
            var urlString = ""
            if let nsError = error as NSError?, let url = nsError.userInfo["url"] as? String {
                urlString = "\nURL: \(url)"
            }
            errorMessage = "Не удалось загрузить расписание.\n\(error.localizedDescription)\(urlString)"
            allEntries = []
        }
    }

    private func entriesForSelectedDate() -> [ScheduleEntry] {
        let key = ScheduleEntry.dateFormatter.string(from: selectedDate)
        return allEntries
            .filter { $0.schedule_date == key }
            .sorted { a, b in
                if a.lessonNumberInt == b.lessonNumberInt {
                    return a.subject.localizedCompare(b.subject) == .orderedAscending
                }
                return a.lessonNumberInt < b.lessonNumberInt
            }
    }

    // MARK: - Derived data
    private var groupNames: [String] {
        selections.selectedNames(forType: "group")
    }
    private var teacherNames: [String] {
        selections.selectedNames(forType: "teacher")
    }
    private var roomNames: [String] {
        selections.selectedNames(forType: "room")
    }

    private var formattedSelectedDate: String {
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("d MMMM, EEEE")
        return df.string(from: selectedDate)
    }
}

// MARK: - Small helper views

private struct SelectedMenu: View {
    let groupNames: [String]
    let teacherNames: [String]
    let roomNames: [String]
    let setPriority: (_ type: String, _ name: String) -> Void
    let isPriorityName: (_ type: String, _ name: String) -> Bool
    let priorityTitle: String?

    var body: some View {
        Menu {
            if !groupNames.isEmpty {
                ScheduleSection(
                    title: "Группы",
                    type: "group",
                    names: groupNames,
                    setPriority: setPriority,
                    isPriorityName: isPriorityName
                )
            }
            if !teacherNames.isEmpty {
                ScheduleSection(
                    title: "Преподаватели",
                    type: "teacher",
                    names: teacherNames,
                    setPriority: setPriority,
                    isPriorityName: isPriorityName
                )
            }
            if !roomNames.isEmpty {
                ScheduleSection(
                    title: "Аудитории",
                    type: "room",
                    names: roomNames,
                    setPriority: setPriority,
                    isPriorityName: isPriorityName
                )
            }

            if groupNames.isEmpty && teacherNames.isEmpty && roomNames.isEmpty {
                Text("Нет выбранных расписаний")
                    .foregroundStyle(.secondary)
            }
        } label: {
            Text((priorityTitle?.isEmpty == false) ? priorityTitle! : "Выбранные")
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

private struct ScheduleSection: View {
    let title: String
    let type: String
    let names: [String]
    let setPriority: (_ type: String, _ name: String) -> Void
    let isPriorityName: (_ type: String, _ name: String) -> Bool

    var body: some View {
        Section(title) {
            ForEach(names, id: \.self) { name in
                Button {
                    setPriority(type, name)
                } label: {
                    RowLabel(name: name, isPriority: isPriorityName(type, name))
                }
            }
        }
    }
}

private struct RowLabel: View {
    let name: String
    let isPriority: Bool

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Image(systemName: isPriority ? "star.fill" : "star")
                .foregroundStyle(isPriority ? .yellow : .secondary)
        }
    }
}

// MARK: - Lesson Card

private struct LessonCard: View {
    let entry: ScheduleEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text("\(entry.lessonNumberInt)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.subject)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let group = entry.group, !group.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "person.3")
                            .foregroundStyle(.secondary)
                        Text(group)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "person")
                        .foregroundStyle(.secondary)
                    Text(entry.teacher)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    Image(systemName: "building.2")
                        .foregroundStyle(.secondary)
                    Text(entry.room)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    ScheduleView()
        .environmentObject(SelectedSchedulesStore())
}
