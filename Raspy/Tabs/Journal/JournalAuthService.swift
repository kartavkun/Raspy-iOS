import CryptoKit
import Foundation
// import SwiftSoup (removed unused)

// MARK: - AuthResult

enum AuthResult {
    case success
    case failed(message: String)
    case serverError(message: String)
}

// MARK: - JournalAuthService

class JournalAuthService {
    // MARK: Constants

    private enum Keys {
        static let username = "username"
        static let password = "password"
        static let sessionID = "session_id"
        static let currUch = "curr_uch"
        static let region = "region"
        static let uch = "uch"
        static let usernameCookie = "username_cookie"
        static let authDate = "auth_date"
        static let isLoggedIn = "is_logged_in"
    }

    private let authLifetime: TimeInterval = 7 * 24 * 60 * 60
    private let baseURL = "https://journal.uc.osu.ru"
    private let loginEndpoint = "/region_pou_secured/region.cgi/login"

    private let defaults = UserDefaults.standard

    // MARK: - Public Methods

    func isUserLoggedIn() -> Bool {
        let isLogged = defaults.bool(forKey: Keys.isLoggedIn)
        let authDate = defaults.double(forKey: Keys.authDate)
        return isLogged && (Date().timeIntervalSince1970 - authDate) < authLifetime
    }

    func getSavedCredentials() -> (username: String, password: String)? {
        guard
            let username = defaults.string(forKey: Keys.username),
            let password = defaults.string(forKey: Keys.password),
            !username.isEmpty,
            !password.isEmpty
        else { return nil }
        return (username, password)
    }

    func getAuthCookies() -> [String: String] {
        return [
            "SESSION_ID": defaults.string(forKey: Keys.sessionID) ?? "",
            "CURR_UCH": defaults.string(forKey: Keys.currUch) ?? "",
            "REGION": defaults.string(forKey: Keys.region) ?? "",
            "UCH": defaults.string(forKey: Keys.uch) ?? "",
            "USERNAME": defaults.string(forKey: Keys.usernameCookie) ?? "",
        ]
    }

    func logout() {
        defaults.set(false, forKey: Keys.isLoggedIn)
        defaults.set("", forKey: Keys.sessionID)
        defaults.set("", forKey: Keys.currUch)
        defaults.set("", forKey: Keys.region)
        defaults.set("", forKey: Keys.uch)
        defaults.set("", forKey: Keys.usernameCookie)
        // additionally clear saved credentials
        defaults.removeObject(forKey: Keys.username)
        defaults.removeObject(forKey: Keys.password)
    }

    // MARK: - Login

    func login(username: String, password: String) async -> AuthResult {
        do {
            let encryptedPass = password.sha1

            guard let url = URL(string: baseURL + loginEndpoint) else {
                return .serverError(message: "Invalid URL")
            }

            var request = URLRequest(url: url)
        // request.timeoutInterval = 30 // timeout disabled per request
        request.setValue("Raspy/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let bodyString = "username=\(username)&userpass=\(encryptedPass)&%C2%F5%EE%E4=%C2%F5%EE%E4"
            request.httpBody = bodyString.data(using: .utf8)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .serverError(message: "Invalid response")
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                return .failed(message: "Ошибка сервера: \(httpResponse.statusCode)")
            }

            let bodyEncoding = String.Encoding.windowsCP1251
        let body = String(data: data, encoding: bodyEncoding) ?? ""

            if body.contains("Здравствуйте") {
                saveAuthData(response: httpResponse, username: username, password: password)
                return .success
            } else {
                return .failed(message: "Ошибка авторизации")
            }

        } catch {
            return .serverError(message: error.localizedDescription)
        }
    }

    // MARK: - Private Methods

    private func saveAuthData(response: HTTPURLResponse, username: String, password: String) {
        if let headerFields = response.allHeaderFields as? [String: String],
           let url = response.url
        {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            for cookie in cookies {
                switch cookie.name {
                case "CURR_UCH": defaults.set(cookie.value, forKey: Keys.currUch)
                case "REGION": defaults.set(cookie.value, forKey: Keys.region)
                case "SESSION_ID": defaults.set(cookie.value, forKey: Keys.sessionID)
                case "UCH": defaults.set(cookie.value, forKey: Keys.uch)
                case "USERNAME": defaults.set(cookie.value, forKey: Keys.usernameCookie)
                default: break
                }
            }
        }

        defaults.set(username, forKey: Keys.username)
        defaults.set(password, forKey: Keys.password)
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.authDate)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }
}

// MARK: - SHA1 Extension

extension String {
    var sha1: String {
        let data = Data(utf8)
        let hash = Insecure.SHA1.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
