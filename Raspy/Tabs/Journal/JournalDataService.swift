import Foundation
import SwiftSoup

// MARK: - Subject Model

struct Subject: Codable, Identifiable {
    let id = UUID()
    let name: String
    let avgMark: Float
    let marks: [String]
}

// MARK: - FetchStatus

enum FetchStatus {
    case success
    case authError
    case serverError
    case timeout
    case generalError
}

// MARK: - JournalDataService

class JournalDataService {
    private let baseURL = "https://journal.uc.osu.ru"
    private let journalEndpoint = "/region_pou_secured/region.cgi/journal_och?page=1&marks=1&compact=1&period_id=1744"

    private let defaults = UserDefaults.standard
    private let savedSubjectsKey = "saved_subjects"

    private let authService = JournalAuthService()

    // MARK: - Fetch Subjects

    func fetchSubjects() async -> ([Subject], FetchStatus) {
        let cachedSubjects = getSavedSubjects()

        guard isAuthValid() else {
            authService.logout()
            return (cachedSubjects, .authError)
        }

        do {
            guard let url = URL(string: baseURL + journalEndpoint) else {
                return (cachedSubjects, .serverError)
            }

            var request = URLRequest(url: url)

            let cookies = authService.getAuthCookies()
            let cookieHeader = cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
            request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ... 299).contains(httpResponse.statusCode)
            else {
                return (cachedSubjects, .serverError)
            }

            // Декодируем ответ в кодировке Windows‑1251 (сервер отдает именно её)
            let bodyEncoding = String.Encoding.windowsCP1251
            let body = String(data: data, encoding: bodyEncoding) ?? ""

            if body.contains("необходимо пройти авторизацию") || !body.contains("Дисциплина") {
                authService.logout()
                return (cachedSubjects, .authError)
            }

            // DEBUG: выводим первые 200 символов тела, чтобы увидеть, что получили
            print("🔍 Body preview (first 200 chars): \(body.prefix(200))")
            if body.contains("необходимо пройти авторизацию") || !body.contains("Дисциплина") {
                authService.logout()
                return (cachedSubjects, .authError)
            }
            let subjects = parseHtmlToSubjects(html: body)
            print("✅ Parsed \(subjects.count) subjects")
            saveSubjects(subjects)
            return (subjects, .success)

        } catch {
            return (cachedSubjects, .generalError)
        }
    }

    // MARK: - Saved Subjects

    func getSavedSubjects() -> [Subject] {
        guard let data = defaults.data(forKey: savedSubjectsKey) else { return [] }
        return (try? JSONDecoder().decode([Subject].self, from: data)) ?? []
    }

    private func saveSubjects(_ subjects: [Subject]) {
        if let data = try? JSONEncoder().encode(subjects) {
            defaults.set(data, forKey: savedSubjectsKey)
        }
    }

    // MARK: - Private

    private func isAuthValid() -> Bool {
        authService.getAuthCookies()["SESSION_ID"]?.isEmpty == false
    }

    private func parseHtmlToSubjects(html: String) -> [Subject] {
        var subjects: [Subject] = []

        do {
            let doc = try SwiftSoup.parse(html)
            if let table = try doc.select("table:has(td.header:contains(Дисциплина))").first() {
                for row in try table.select("tr") {
                    if try row.select("td.header:contains(Дисциплина)").first() != nil { continue }

                    let cells = try row.select("td")
                    guard cells.count >= 3 else { continue }

                    let name = try cells[0].text().trimmingCharacters(in: .whitespacesAndNewlines)
                    let marksText = try cells[1].text().trimmingCharacters(in: .whitespacesAndNewlines)
                    let marks = marksText.split(separator: " ").map { String($0) }.filter { !$0.isEmpty }

                    let avgText = try cells[2].text().trimmingCharacters(in: .whitespacesAndNewlines)
                    let avgMatch = try NSRegularExpression(pattern: "(\\d+[.,]\\d+)").firstMatch(in: avgText, range: NSRange(avgText.startIndex..., in: avgText))

                    let avgMark: Float
                    if let match = avgMatch, let range = Range(match.range(at: 1), in: avgText) {
                        avgMark = Float(avgText[range].replacingOccurrences(of: ",", with: ".")) ?? 0
                    } else {
                        avgMark = 0
                    }

                    if !name.isEmpty, !marks.isEmpty {
                        subjects.append(Subject(name: name, avgMark: avgMark, marks: marks))
                    }
                }
            }
        } catch {
            print("Error parsing HTML: \(error)")
        }

        return subjects
    }
}
