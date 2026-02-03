import Foundation

final class AppServices {
    static let shared = AppServices()

    let auth: JournalAuthService
    let data: JournalDataService

    private init() {
        // Если конструкторы сервисов без параметров — просто создаём их
        auth = JournalAuthService()
        data = JournalDataService()
    }
}
