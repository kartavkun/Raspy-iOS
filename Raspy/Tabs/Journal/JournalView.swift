//
//  JournalView.swift
//  Raspy
//
//  Created by Nikita Robezhko on 22.10.2025.
//

import Foundation
import SwiftUI

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var username = ""
    @Published var password = ""
    @Published var isLoggedIn = false

    private let dataService = JournalDataService()
    private let authService = JournalAuthService()

    init() {
        // Если есть сохранённые учётные данные – пытаемся войти автоматически
        if let creds = authService.getSavedCredentials() {
            username = creds.username
            password = creds.password
            // Попытка автоматической авторизации
            Task {
                let result = await authService.login(username: username, password: password)
                switch result {
                case .success:
                    isLoggedIn = true
                    load()
                case .failed(let msg), .serverError(let msg):
                    errorMessage = "Авто‑вход не удался: \(msg)"
                }
            }
        } else {
            // Нет сохранённых данных – пользователь вводит их вручную
            username = ""
            password = ""
            isLoggedIn = false
        }
    }

    func logout() {
        // Очищаем всё локальное состояние и удаляем cookie‑ы/креды
        authService.logout()
        username = ""
        password = ""
        isLoggedIn = false
        subjects = []
        errorMessage = nil
    }

    func login() {
        isLoading = true
        errorMessage = nil

        Task {
            let result = await authService.login(username: username, password: password)
            isLoading = false

            switch result {
            case .success:
                isLoggedIn = true
                load() // загружаем данные после успешного логина

            case let .failed(message), let .serverError(message):
                errorMessage = message
            }
        }
    }

    func load() {
        guard isLoggedIn else { return }

        isLoading = true
        errorMessage = nil

        Task {
            let (subjects, status) = await dataService.fetchSubjects()
            isLoading = false

            switch status {
            case .success:
                self.subjects = subjects
                print("🚀 Loaded \(subjects.count) subjects")

            case .authError:
                errorMessage = "Сессия истекла. Нужно войти заново."
                isLoggedIn = false // возвращаем на экран логина

            case .timeout:
                errorMessage = "Сервер не отвечает (таймаут)."

            case .serverError:
                errorMessage = "Ошибка сервера."

            case .generalError:
                errorMessage = "Не удалось загрузить данные."
            }
        }
    }
}

struct SubjectRow: View {
    let subject: Subject
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(subject.name)
                .font(.headline)
            HStack {
                Text("Средний:")
                Text(String(format: "%.2f", subject.avgMark))
                    .bold()
            }
            .font(.subheadline)
            if !subject.marks.isEmpty {
                Text(subject.marks.joined(separator: "  "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct JournalView: View {
    @StateObject private var vm = JournalViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Журнал")
                .toolbar {
                    // Кнопка выхода показывается только когда пользователь залогинен
                    if vm.isLoggedIn {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Выйти") {
                                vm.logout()
                            }
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !vm.isLoggedIn {
            // Экран логина
            VStack(spacing: 16) {
                TextField("Логин", text: $vm.username)
                    .textFieldStyle(.roundedBorder)

                SecureField("Пароль", text: $vm.password)
                    .textFieldStyle(.roundedBorder)

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Войти") {
                    vm.login()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.username.isEmpty || vm.password.isEmpty)
            }
            .padding()
        } else if vm.isLoading {
            ProgressView("Загрузка оценок…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let error = vm.errorMessage {
            VStack(spacing: 12) {
                Text(error)
                    .foregroundColor(.secondary)

                Button("Повторить") {
                    vm.load()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            VStack {
                Text("Всего предметов: \(vm.subjects.count)")
                List(vm.subjects) { subject in
                    SubjectRow(subject: subject)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    JournalView()
}
