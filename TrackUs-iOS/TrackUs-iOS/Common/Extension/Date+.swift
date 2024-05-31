//
//  Date+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/29/24.
//

import Foundation

extension Date {
    var fullYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var currentTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let str = dateFormatter.string(from: self)
        return str
    }
    
    var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "오전" : "오후"
    }
}
