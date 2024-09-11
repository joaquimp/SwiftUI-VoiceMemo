//
//  Item.swift
//  VoiceMemo
//
//  Created by Joaquim Pessoa Filho on 11/09/24.
//

import Foundation
import SwiftData

@Model
final class Memo {
    var timestamp: Date
    var audioData: Data
    
    init(audioData: Data) {
        self.timestamp = Date.now
        self.audioData = audioData
    }
}
