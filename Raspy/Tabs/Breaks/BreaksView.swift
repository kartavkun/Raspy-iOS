//
//  BreaksView.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 16.04.2025.
//

import SwiftUI

struct BreaksView: View {
    let schedule = [
        (number: 1, firstHalf: "8:00-8:45", secondHalf: "8:50-9:35"),
        (number: 2, firstHalf: "9:45-10:30", secondHalf: "10:35-11:20"),
        (number: 3, firstHalf: "11:40-12:25", secondHalf: "12:35-13:15"),
        (number: 4, firstHalf: "13:25-14:10", secondHalf: "14:15-15:00"),
        (number: 5, firstHalf: "15:10-15:55", secondHalf: "16:00-16:45"),
        (number: 6, firstHalf: "16:55-17:40", secondHalf: "17:45-18:30"),
        (number: 7, firstHalf: "18:40-19:25", secondHalf: "19:30-20:15")
    ]

    let SaturdaySchedule = [
        (number: 1, firstHalf: "8:00-8:45", secondHalf: "8:50-9:35"),
        (number: 2, firstHalf: "9:45-10:30", secondHalf: "10:35-11:20"),
        (number: 3, firstHalf: "11:30-12:15", secondHalf: "12:25-13:05"),
        (number: 4, firstHalf: "13:15-14:00", secondHalf: "14:05-14:50"),
        (number: 5, firstHalf: "15:00-15:45", secondHalf: "15:50-16:35"),
        (number: 6, firstHalf: "16:45-17:30", secondHalf: "17:35-18:20"),
        (number: 7, firstHalf: "18:30-19:15", secondHalf: "19:20-20:05")
    ]

    let holidays = [
        (number: 1, firstHalf: "8:00", secondHalf: "9:00"),
        (number: 2, firstHalf: "9:10", secondHalf: "10:10"),
        (number: 3, firstHalf: "10:20", secondHalf: "11:20"),
        (number: 4, firstHalf: "11:30", secondHalf: "12:30"),
        (number: 5, firstHalf: "12:40", secondHalf: "13:40"),
        (number: 6, firstHalf: "13:50", secondHalf: "14:50"),
        (number: 7, firstHalf: "15:00", secondHalf: "16:00"),
    ]
    
    @State private var selectedSchedule = 0
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Picker для выбора типа расписания
                Picker("Тип расписания", selection: $selectedSchedule) {
                    Text("Будни").tag(0)
                    Text("Суббота").tag(1)
                    Text("Праздники").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(currentSchedule, id: \.number) { item in
                            HStack(spacing: 0) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1)) // просто светлый фон квадратика, не зависит от текущего времени
                                        .frame(width: 40, height: 40)
                                    Text("\(item.number)")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .padding(.leading, 16)
                                
                                Text(item.firstHalf)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                
                                Text(item.secondHalf)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 16)
                            }
                            .padding(.vertical, 12)
                            .background(
                                isCurrentPair(item)
                                    ? Color.blue.opacity(0.3)  // подсветка всей строки
                                    : (item.number % 2 == 0 ? Color.gray.opacity(0.05) : Color.clear)
                            )
                            .cornerRadius(8)
                        }
                    }
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Перерывы")
            .background(Color(uiColor: .secondarySystemBackground))
            .onAppear {
                updateSelectedSchedule()
            }
            .onReceive(timer) { _ in
                currentTime = Date()
                updateSelectedSchedule()
            }
        }
    }
    
    private func updateSelectedSchedule() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentTime)
        
        // 1 - воскресенье, 2 - понедельник, ..., 7 - суббота
        if weekday == 7 { // Суббота
            selectedSchedule = 1
        } else {
            selectedSchedule = 0 // Будни и воскресенье
        }
    }
    
    /// Создает объект Date для сегодняшнего дня с указанным временем ("08:00")
    private func dateToday(hourMinute: String) -> Date? {
        let components = hourMinute.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else { return nil }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = currentTime
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        return calendar.date(from: dateComponents)
    }
    
    private func isCurrentPair(_ pair: (number: Int, firstHalf: String, secondHalf: String)) -> Bool {
        // Текущее время
        let now = currentTime
        
        func dateFromTimeString(_ time: String) -> Date? {
            dateToday(hourMinute: time)
        }
        
        // Для праздников
        if selectedSchedule == 2 {
            guard
                let start = dateFromTimeString(pair.firstHalf),
                let end = dateFromTimeString(pair.secondHalf)
            else { return false }
            return now >= start && now <= end
        }

        // Для обычных дней
        let firstHalfTimes = pair.firstHalf.split(separator: "-")
        let secondHalfTimes = pair.secondHalf.split(separator: "-")

        guard
            firstHalfTimes.count == 2,
            secondHalfTimes.count == 2,
            let firstStart = dateFromTimeString(String(firstHalfTimes[0])),
            let firstEnd = dateFromTimeString(String(firstHalfTimes[1])),
            let secondStart = dateFromTimeString(String(secondHalfTimes[0])),
            let secondEnd = dateFromTimeString(String(secondHalfTimes[1]))
        else { return false }

        return (now >= firstStart && now <= firstEnd) ||
               (now >= secondStart && now <= secondEnd)
    }
    
    private var currentSchedule: [(number: Int, firstHalf: String, secondHalf: String)] {
        switch selectedSchedule {
        case 0:
            return schedule
        case 1:
            return SaturdaySchedule
        case 2:
            return holidays
        default:
            return schedule
        }
    }
}

#Preview {
    BreaksView()
}
