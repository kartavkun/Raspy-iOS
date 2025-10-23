//
//  ScheduleSettingsView.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 19.04.2025.
//

import SwiftUI

struct ScheduleSettingsView: View {
    @State private var shouldPresentSheet = false
    @EnvironmentObject private var selections: SelectedSchedulesStore
    
    var body: some View {
        List {
            Section {
                Button{
                    shouldPresentSheet.toggle()
                } label: {
                    Label("Добавить расписание", systemImage: "magnifyingglass")
                }
                .sheet(isPresented: $shouldPresentSheet) {
                    // OnDismiss
                } content: {
                    AddScheduleSheet()
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
            
            // Selected Groups
            if !selections.selectedNames(forType: "group").isEmpty {
                Section(header: Text("Выбранные группы")) {
                    ForEach(selections.selectedNames(forType: "group"), id: \.self) { name in
                        HStack {
                            Image(systemName: "person.3")
                                .foregroundStyle(.blue)
                            Text(name)
                            Spacer()
                            // Optional: remove button
                            Button(role: .destructive) {
                                // Build a synthetic APIItem to reuse toggle for removal
                                let item = APIItem(type: "group", name: name)
                                selections.toggle(item)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.red)
                        }
                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
            
            // Selected Teachers
            if !selections.selectedNames(forType: "teacher").isEmpty {
                Section(header: Text("Выбранные преподаватели")) {
                    ForEach(selections.selectedNames(forType: "teacher"), id: \.self) { name in
                        HStack {
                            Image(systemName: "person.crop.rectangle.stack")
                                .foregroundStyle(.purple)
                            Text(name)
                            Spacer()
                            Button(role: .destructive) {
                                let item = APIItem(type: "teacher", name: name)
                                selections.toggle(item)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.red)
                        }
                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
            
            // Selected Rooms
            if !selections.selectedNames(forType: "room").isEmpty {
                Section(header: Text("Выбранные аудитории")) {
                    ForEach(selections.selectedNames(forType: "room"), id: \.self) { name in
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundStyle(.green)
                            Text(name)
                            Spacer()
                            Button(role: .destructive) {
                                let item = APIItem(type: "room", name: name)
                                selections.toggle(item)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.red)
                        }
                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .scrollContentBackground(.hidden)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Расписания")
    }
}

#Preview {
    NavigationView {
        ScheduleSettingsView()
            .environmentObject(SelectedSchedulesStore())
    }
}
