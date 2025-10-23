//
//  ScheduleEntry.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 22.10.2025.
//

import Foundation

struct ScheduleEntry: Decodable, Identifiable, Hashable {
    let id: Int
    let group_id: Int?
    let schedule_date: String // формат "dd.MM.yyyy"
    let lesson_number: String // приходит строкой
    let subject: String
    let room: String
    let teacher: String
    let last_updated: String?
    let lastUpdated: Int?

    // Удобные производные
    var lessonNumberInt: Int {
        Int(lesson_number) ?? 0
    }

    // Преобразование schedule_date -> Date (локально)
    func date(using formatter: DateFormatter = ScheduleEntry.dateFormatter) -> Date? {
        formatter.date(from: schedule_date)
    }

    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()
}
