//
//  AddScheduleSheet.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 17.09.2025.
//

import SwiftUI
import Foundation

// MARK: - API / Local models
struct APIItem: Codable, Identifiable, Hashable {
    let type: String
    let name: String
    var id: UUID = UUID() // генерируем локально

    enum CodingKeys: String, CodingKey {
        case type, name // id исключаем из декодирования
    }
}

// MARK: - Data service
@MainActor
class ScheduleDataService: ObservableObject {
    @Published var items: [APIItem] = []

    func fetchAll() async {
        var allItems: [APIItem] = []

        if let groups: [APIItem] = await fetch(endpoint: "groups") {
            allItems.append(contentsOf: groups)
        }
        if let teachers: [APIItem] = await fetch(endpoint: "teachers") {
            allItems.append(contentsOf: teachers)
        }
        if let rooms: [APIItem] = await fetch(endpoint: "rooms") {
            allItems.append(contentsOf: rooms)
        }

        items = allItems
    }

    private func fetch<T: Decodable>(endpoint: String) async -> [T]? {
        guard let url = URL(string: "\(Config.baseURL)/\(endpoint)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Ошибка загрузки \(endpoint):", error)
            return nil
        }
    }
}

// MARK: - View
struct AddScheduleSheet: View {
    @StateObject private var service = ScheduleDataService()
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var selections: SelectedSchedulesStore

    var body: some View {
        NavigationStack {
            List {
                // Группы
                let groups = service.items.filter { $0.type.lowercased() == "group" && (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)) }
                if !groups.isEmpty {
                    Section("Группы") {
                        ForEach(groups) { item in
                            Button {
                                selections.toggle(item)
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selections.isSelected(item) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                    } else {
                                        Image(systemName: "star")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Преподаватели
                let teachers = service.items.filter { $0.type.lowercased() == "teacher" && (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)) }
                if !teachers.isEmpty {
                    Section("Преподаватели") {
                        ForEach(teachers) { item in
                            Button {
                                selections.toggle(item)
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selections.isSelected(item) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                    } else {
                                        Image(systemName: "star")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Аудитории
                let rooms = service.items.filter { $0.type.lowercased() == "room" && (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)) }
                if !rooms.isEmpty {
                    Section("Аудитории") {
                        ForEach(rooms) { item in
                            Button {
                                selections.toggle(item)
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selections.isSelected(item) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                    } else {
                                        Image(systemName: "star")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Расписание")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Назад", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .task {
                await service.fetchAll()
            }
        }
    }
}

// Preview
#Preview {
    AddScheduleSheet()
        .environmentObject(SelectedSchedulesStore())
}
