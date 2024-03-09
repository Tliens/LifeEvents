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
    var mid: String?
    var data:Data?
    init(mid: String = UUID().uuidString, data:Data) {
        self.mid = mid
        self.data = data
    }
}
