//
//  Int+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import Foundation

extension Int {
    var asString: String {
        return String(self)
    }
    
    var toMMSSTimeFormat: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self))!
    }
}


