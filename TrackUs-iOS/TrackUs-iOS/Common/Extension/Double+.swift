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
            return ""
        case .km:
            return String(format: "%.2f km", self / 1000.0)
        case .kcal:
            return ""
        }
    }
}
