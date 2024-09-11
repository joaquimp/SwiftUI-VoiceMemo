//
//  Item.swift
//  VoiceMemo
//
//  Created by Joaquim Pessoa Filho on 11/09/24.
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
