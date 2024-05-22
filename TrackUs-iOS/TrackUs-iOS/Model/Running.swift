//
//  Running.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/20/24.
//

import Foundation
import Firebase
import CoreLocation

struct Running {
    var address: String = ""
    var calorie: Double = 0.0
    var distance: Double = 0.0
    var pace: Double = 0.0
    var seconds: Double = 0.0
    var geoPoints: [GeoPoint] = []
    var isGroup: Bool = false
    var routeImageUrl: String = ""
    var createdAt: Date = .now
    
    var coordinates: [CLLocationCoordinate2D] {
        get {
            geoPoints.asCLCoordinate2D
        }
        set(newCoord) {
            geoPoints = newCoord.asGeoPoints
        }
    }
}
