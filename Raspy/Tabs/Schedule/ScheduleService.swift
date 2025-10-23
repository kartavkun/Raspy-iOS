//
//  ScheduleService.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 22.10.2025.
//

import Foundation

struct ScheduleService {
    enum ServiceError: Error {
        case noPriority
        case badURL
        case network(Error)
        case decoding(Error)
    }

    // Загружает расписание по активному приоритету
    func fetch(type: String, name: String) async throws -> [ScheduleEntry] {
        let paramName: String
        switch type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "group": paramName = "group_name"
        case "teacher": paramName = "teacher_name"
        case "room": paramName = "room_name"
        default:
            throw ServiceError.noPriority
        }

        // Кодируем имя в URL
        var comps = URLComponents(string: "\(Config.baseURL)/schedule")
        comps?.queryItems = [
            .init(name: paramName, value: name)
        ]
        guard let url = comps?.url else {
            throw ServiceError.badURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                return try JSONDecoder().decode([ScheduleEntry].self, from: data)
            } catch {
                throw ServiceError.decoding(error)
            }
        } catch {
            throw ServiceError.network(error)
        }
    }
}
