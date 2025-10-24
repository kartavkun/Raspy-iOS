//
//  ContentView.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 16.04.2025.
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @StateObject private var settings = AppSettings()
    
    var body: some View {
        TabView {
            // Вкладка "Пары"
            ScheduleView()
                .tabItem {
                    Label("Пары", systemImage: "calendar")
                }
            
            // Вкладка "Звонки"
            BreaksView()
                .tabItem {
                    Label("Звонки", systemImage: "clock")
                }
            
            // Вкладка "Оценки"
            // GradeBookView()
            //     .tabItem {
            //         Label("Оценки", systemImage: "book")
            //     }
            
            // Вкладка "Настройки"
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .preferredColorScheme(settings.currentTheme == .system ? nil : 
                            (settings.currentTheme == .dark ? .dark : .light))
    }
}

#Preview {
    ContentView()
}
