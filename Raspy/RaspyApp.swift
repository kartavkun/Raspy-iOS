//
//  RaspyApp.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 12.04.2025.
//

import SwiftUI
import SwiftData

@main
struct RaspyApp: App {
    @State private var showLaunchScreen = true
    @StateObject private var settings = AppSettings()   // Создаём один экземпляр на всё приложение
    @StateObject private var selections = SelectedSchedulesStore() // Shared selections store

    // Первый запуск = онбординг ещё не завершён
    private var isFirstLaunch: Bool {
        !settings.didFinishOnboarding
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if showLaunchScreen {
                    LaunchScreenView()
                        .onAppear {
                            // Задержка для отображения LaunchScreen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showLaunchScreen = false
                                }
                            }
                        }
                } else if isFirstLaunch {
                    FirstSetupView()
                } else {
                    ContentView()
                }
            }
            .environmentObject(settings)
            .environmentObject(selections)
        }
        .modelContainer(sharedModelContainer)
    }
}
