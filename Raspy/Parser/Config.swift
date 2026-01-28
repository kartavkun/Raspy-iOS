//
//  Config.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 17.04.2025.
//

// import Foundation

enum Config {
    // baseURL это строка
    // либо "https://{ip}:{port}", либо "https://{name.domain}"
    // обязательно иметь HTTPS. Если нет возможности для https, то задайте строку NSExceptionDomains в Info.plist. См. CONTRIBUTING.md
    static let baseURL = "https://"
}
