import SwiftUI

enum AppTheme: String, CaseIterable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Тёмная"
}

class AppSettings: ObservableObject {
    @AppStorage("appTheme") private var theme: String = AppTheme.system.rawValue

    var currentTheme: AppTheme {
        get { AppTheme(rawValue: theme) ?? .system }
        set { theme = newValue.rawValue }
    }
}
