//
//  Date+.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/30/24.
//

import Foundation
import UIKit

extension Date {
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
}
