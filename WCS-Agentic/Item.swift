//
//  Item.swift
//  WCS-Agentic
//
//  Created by Christopher Appiah-Thompson  on 16/5/2026.
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
