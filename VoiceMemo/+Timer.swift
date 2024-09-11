//
//  +Timer.swift
//  VoiceMemo
//
//  Created by Joaquim Pessoa Filho on 11/09/24.
//

import Foundation

extension TimeInterval {
    func toString() -> String {
        let minutes = Int(self) / 60
        let seconds = self - Double(minutes) * 60
        let secondsFraction = seconds - Double(Int(seconds))
        return String(format:"%02i:%02i.%01i",minutes,Int(seconds),Int(secondsFraction * 10.0))
    }
}
