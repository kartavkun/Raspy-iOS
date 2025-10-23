//
//  SelectedSchedulesStore.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 22.10.2025.
//

import Foundation
import SwiftUI

final class SelectedSchedulesStore: ObservableObject {
    // Persist selected sets
    @AppStorage("selectedGroups") private var selectedGroupsStorage: String = ""
    @AppStorage("selectedTeachers") private var selectedTeachersStorage: String = ""
    @AppStorage("selectedRooms") private var selectedRoomsStorage: String = ""

    // One global priority (store as "type|name")
    @AppStorage("priorityGlobalKey") private var priorityGlobalKeyStorage: String = ""

    // Published in-memory sets for UI reactivity
    @Published private(set) var selectedGroups: Set<String> = []
    @Published private(set) var selectedTeachers: Set<String> = []
    @Published private(set) var selectedRooms: Set<String> = []

    // In-memory global priority key
    @Published private(set) var priorityGlobalKey: String = ""

    init() {
        selectedGroups = Self.decodeSet(from: selectedGroupsStorage)
        selectedTeachers = Self.decodeSet(from: selectedTeachersStorage)
        selectedRooms = Self.decodeSet(from: selectedRoomsStorage)

        priorityGlobalKey = priorityGlobalKeyStorage
        sanitizeGlobalPriority()
    }

    // MARK: - Public API

    func isSelected(_ item: APIItem) -> Bool {
        switch normalizedType(item.type) {
        case "group": return selectedGroups.contains(key(for: item))
        case "teacher": return selectedTeachers.contains(key(for: item))
        case "room": return selectedRooms.contains(key(for: item))
        default: return false
        }
    }

    func toggle(_ item: APIItem) {
        let type = normalizedType(item.type)
        let k = key(for: item)

        switch type {
        case "group":
            if selectedGroups.contains(k) {
                selectedGroups.remove(k)
                if priorityGlobalKey == k { clearGlobalPriority() }
            } else {
                selectedGroups.insert(k)
                // если приоритет пуст — назначим первым добавленным
                if priorityGlobalKey.isEmpty { setGlobalPriority(item) }
            }
            persist(&selectedGroupsStorage, with: selectedGroups)

        case "teacher":
            if selectedTeachers.contains(k) {
                selectedTeachers.remove(k)
                if priorityGlobalKey == k { clearGlobalPriority() }
            } else {
                selectedTeachers.insert(k)
                if priorityGlobalKey.isEmpty { setGlobalPriority(item) }
            }
            persist(&selectedTeachersStorage, with: selectedTeachers)

        case "room":
            if selectedRooms.contains(k) {
                selectedRooms.remove(k)
                if priorityGlobalKey == k { clearGlobalPriority() }
            } else {
                selectedRooms.insert(k)
                if priorityGlobalKey.isEmpty { setGlobalPriority(item) }
            }
            persist(&selectedRoomsStorage, with: selectedRooms)

        default:
            break
        }

        objectWillChange.send()
    }

    // MARK: - Global priority

    func setGlobalPriority(_ item: APIItem) {
        let k = key(for: item)
        // Приоритет можно назначить только среди выбранных
        guard isSelected(item) else { return }
        priorityGlobalKey = k
        priorityGlobalKeyStorage = k
        objectWillChange.send()
    }

    func setPriority(type: String, name: String) {
        // удобный адаптер для UI, где есть только тип/имя
        let item = APIItem(type: type, name: name)
        setGlobalPriority(item)
    }

    func isPriority(type: String, name: String) -> Bool {
        priorityGlobalKey == "\(normalizedType(type))|\(name)"
    }

    func currentGlobalPriorityName() -> String? {
        guard !priorityGlobalKey.isEmpty else { return nil }
        return Self.name(fromKey: priorityGlobalKey)
    }

    // Новый удобный аксессор: вернуть (type, name)
    func currentGlobalPriority() -> (type: String, name: String)? {
        guard !priorityGlobalKey.isEmpty else { return nil }
        let parts = priorityGlobalKey.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }

    // Accessors if other views need the names for display
    func selectedNames(forType type: String) -> [String] {
        switch normalizedType(type) {
        case "group": return selectedGroups.map { Self.name(fromKey: $0) }.sorted()
        case "teacher": return selectedTeachers.map { Self.name(fromKey: $0) }.sorted()
        case "room": return selectedRooms.map { Self.name(fromKey: $0) }.sorted()
        default: return []
        }
    }

    // MARK: - Helpers

    private func sanitizeGlobalPriority() {
        guard !priorityGlobalKey.isEmpty else { return }
        // priority must belong to one of the selected sets
        let parts = priorityGlobalKey.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { clearGlobalPriority(); return }
        let t = parts[0]
        switch t {
        case "group":
            if !selectedGroups.contains(priorityGlobalKey) { clearGlobalPriority() }
        case "teacher":
            if !selectedTeachers.contains(priorityGlobalKey) { clearGlobalPriority() }
        case "room":
            if !selectedRooms.contains(priorityGlobalKey) { clearGlobalPriority() }
        default:
            clearGlobalPriority()
        }
    }

    private func clearGlobalPriority() {
        priorityGlobalKey = ""
        priorityGlobalKeyStorage = ""
    }

    private func normalizedType(_ type: String) -> String {
        type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func key(for item: APIItem) -> String {
        "\(normalizedType(item.type))|\(item.name)"
    }

    private func persist(_ storage: inout String, with set: Set<String>) {
        storage = Self.encodeSet(set)
    }

    private static func encodeSet(_ set: Set<String>) -> String {
        set.sorted().joined(separator: "\n")
    }

    private static func decodeSet(from string: String) -> Set<String> {
        guard !string.isEmpty else { return [] }
        return Set(string.components(separatedBy: "\n"))
    }

    private static func name(fromKey key: String) -> String {
        if let sep = key.firstIndex(of: "|") {
            return String(key[key.index(after: sep)...])
        }
        return key
    }
}
