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

@Model
final class Meaning {
    var mid: String?
    var content:String?
    init(mid: String = UUID().uuidString, content:String = "") {
        self.mid = mid
        self.content = content
    }
}
