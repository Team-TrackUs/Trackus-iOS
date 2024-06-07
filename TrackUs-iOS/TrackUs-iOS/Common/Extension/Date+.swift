//
//  Date+.swift
//  TrackUs-iOS

import Foundation
import UIKit

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
    
    func timeAgoFormat(numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let date = self
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if components.year! >= 2 {
            return "\(components.year!)년 전"
        } else if components.year! >= 1 {
            if numericDates {
                return "1년 전"
            } else {
                return "작년"
            }
        } else if components.month! >= 2 {
            return "\(components.month!)달 전"
        } else if components.month! >= 1 {
            if numericDates {
                return "1달 전"
            } else {
                return "지난달"
            }
        } else if components.weekOfYear! >= 2 {
            return "\(components.weekOfYear!)주 전"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                return "1주 전"
            } else {
                return "지난주"
            }
        } else if components.day! >= 2 {
            return "\(components.day!)일 전"
        } else if components.day! >= 1 {
            if numericDates {
                return "1일 전"
            } else {
                return "어제"
            }
        } else if components.hour! >= 2 {
            return "\(components.hour!)시간 전"
        } else if components.hour! >= 1 {
            if numericDates {
                return "1시간 전"
            } else {
                return "1시간 전"
            }
        } else if components.minute! >= 2 {
            return "\(components.minute!)분 전"
        } else if components.minute! >= 1 {
            if numericDates {
                return "1분 전"
            } else {
                return "조금 전"
            }
        } else {
            return "지금"
        }
    }
    
    enum Format {
        case full // yyyy.mm.dd
        case time // hh:mm
    }
    
    /// 채팅 날짜, 시간 반환용 >> .full : 날짜, .tiem : 시간
    func formattedString(style: Date.Format = .full) -> String {
        let dateFormatter = DateFormatter()
        switch style {
            case .full:
                dateFormatter.dateFormat = "yyyy.MM.dd"
            case .time:
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                dateFormatter.amSymbol = "AM"
                dateFormatter.pmSymbol = "PM"
        }
        return dateFormatter.string(from: self)
    }
    
    
}
