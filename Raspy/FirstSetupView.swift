//
//  FirstSetupView.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 24.10.2025.
//

import SwiftUI

struct FirstSetupView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var selections: SelectedSchedulesStore
    @State private var step: Int = 1
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAddScheduleSheet = false

    var body: some View {
        VStack(spacing: 24) {
            switch step {
            case 1:
                welcomeScreen
            case 2:
                addScheduleScreen
            case 3:
                swipeHintScreen
            default:
                EmptyView()
            }
        }
        .padding()
        .sheet(isPresented: $showingAddScheduleSheet) {
            AddScheduleSheet()
                .environmentObject(selections)
        }
    }

    private var welcomeScreen: some View {
        VStack(spacing: 16) {
            Image("Rasp_logo_noBG") // добавь логотип в ассеты с таким именем
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text("Здравствуй, студент!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Я — Raspy, помощник твоей студенческой жизни.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            Button("Продолжить") {
                withAnimation {
                    step = 2
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
        }
    }

    private var addScheduleScreen: some View {
        VStack(spacing: 16) {
            Text("Добавь расписание своей группы")
                .font(.title2)
                .fontWeight(.semibold)

            Button {
                showingAddScheduleSheet = true
            } label: {
                Label("Добавить расписание", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)

            if hasAnySelectedSchedules {
                Button("Продолжить") {
                    withAnimation {
                        step = 3
                    }
                }
                .padding(.top, 12)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var swipeHintScreen: some View {
        VStack(spacing: 20) {
            Text("Отлично!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Теперь ты можешь свайпами влево и вправо переключать дни расписания.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 240)
                .overlay(Text("Здесь будет скриншот интерфейса"))
                .cornerRadius(12)
                .padding(.top, 20)

            Button("Начать пользоваться") {
                Task { await finishSetup() }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
        }
    }

    private var hasAnySelectedSchedules: Bool {
        !selections.selectedNames(forType: "group").isEmpty ||
        !selections.selectedNames(forType: "teacher").isEmpty ||
        !selections.selectedNames(forType: "room").isEmpty
    }

    private func finishSetup() async {
        isLoading = true
        defer { isLoading = false }

        // Помечаем онбординг завершенным
        settingsDidFinishOnboarding()
    }

    private func settingsDidFinishOnboarding() {
        settings.didFinishOnboarding = true
    }
}

#Preview {
    FirstSetupView()
        .environmentObject(AppSettings())
        .environmentObject(SelectedSchedulesStore())
}
