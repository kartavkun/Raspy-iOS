//
//  Item.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 16.04.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
