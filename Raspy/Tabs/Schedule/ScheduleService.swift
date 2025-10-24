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
        case badURL(url: String?)
        case missingDate
        case network(Error)
        case decoding(Error)
    }
    
    /// Загружает расписание по активному приоритету (и дате для преподавателей)
    func fetch(type: String, name: String, date: Date? = nil) async throws -> [ScheduleEntry] {
        let trimmedType = type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let base = Config.baseURL
        var url: URL?
        
        switch trimmedType {
        case "group":
            guard let baseURL = URL(string: base) else {
                throw ServiceError.badURL(url: base)
            }
            
            let groupURL = baseURL.appendingPathComponent("schedule")
            var comps = URLComponents(url: groupURL, resolvingAgainstBaseURL: false)
            comps?.queryItems = [
                .init(name: "group_name", value: name)
            ]
            
            guard let finalURL = comps?.url else {
                throw ServiceError.badURL(url: groupURL.absoluteString)
            }
            url = finalURL
            
        case "teacher":
            guard let date = date else {
                throw ServiceError.missingDate
            }
            
            guard let baseURL = URL(string: base) else {
                throw ServiceError.badURL(url: base)
            }
            
            let df = DateFormatter()
            df.locale = Locale(identifier: "ru_RU")
            df.dateFormat = "yyyy-MM-dd"
            let formattedDate = df.string(from: date)
            
            let teacherURL = baseURL.appendingPathComponent("schedule").appendingPathComponent("teacher")
            var comps = URLComponents(url: teacherURL, resolvingAgainstBaseURL: false)
            comps?.queryItems = [
                .init(name: "teacher_name", value: name),
                .init(name: "date", value: formattedDate)
            ]
            
            guard let finalURL = comps?.url else {
                throw ServiceError.badURL(url: teacherURL.absoluteString)
            }
            url = finalURL
            
        case "room":
            guard let baseURL = URL(string: base) else {
                throw ServiceError.badURL(url: base)
            }
            
            let roomURL = baseURL.appendingPathComponent("schedule/room")
            var comps = URLComponents(url: roomURL, resolvingAgainstBaseURL: false)
            comps?.queryItems = [
                .init(name: "room", value: name)
            ]
            
            guard let finalURL = comps?.url else {
                throw ServiceError.badURL(url: roomURL.absoluteString)
            }
            url = finalURL
            
        default:
            throw ServiceError.noPriority
        }
        
        guard let endpointURL = url else {
            throw ServiceError.badURL(url: nil)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: endpointURL)
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
