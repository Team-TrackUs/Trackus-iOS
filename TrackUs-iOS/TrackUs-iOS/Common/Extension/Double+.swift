//
//  Double+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import Foundation

extension Double {
    enum FormattedStyle {
        case pace
        case km
        case kcal
    }
    
    func asString(style: FormattedStyle) -> String {
        switch style {
        case .pace:
            guard self != 0.0 && self != .infinity && !self.isNaN  else {
                return "-'--''"
            }
            let formattedString = String(format: "%.2f", self)
            let component = formattedString.split(separator: ".")
            let firstComponent = component[0]
            let secondComponent = component[1]
            return "\(firstComponent)'\(secondComponent)"
        case .km:
            return String(format: "%.2f km", self / 1000.0)
        case .kcal:
            return ""
        }
    }
    
    var toMMSSTimeFormat: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self))!
    }
}
