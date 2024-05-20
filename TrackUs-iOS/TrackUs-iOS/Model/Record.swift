//
//  Record.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/17/24.
//

import Foundation
import Firebase
import CoreLocation

struct Record {
    var address: String = ""
    var calorie: Double = 0.0
    var distance: Double = 0.0
    var pace: Double = 0.0
    var seconds: Int = 0
    var coordinates: [GeoPoint] = []
    var isGroup: Bool = false
    var routeImageUrl: String = ""
    var createdAt: Date = .now
}
