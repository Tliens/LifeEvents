//
//  Item.swift
//  LifeEvents
//
//  Created by Quinn Von on 2024/3/8.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date?
    var data:Data?
    init(timestamp: Date = .now, data:Data) {
        self.timestamp = timestamp
        self.data = data
    }
}
