//
//  Running.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/20/24.
//

import Foundation
import Firebase
import CoreLocation

struct Running: Codable {
    var address: String = ""
    var calorie: Double = 0.0
    var distance: Double = 0.0
    var pace: Double = 0.0
    var seconds: Double = 0.0
    var cadance: Int = 0
    var steps: Int = 0
    var maxAltitude: Double = 0.0
    var minAltitude: Double = 0.0
    var geoPoints: [GeoPoint] = []
    var routeImageUrl: String = ""
    var startTime: Date!
    var endTime: Date!
    var createdAt: Timestamp!
    
    var coordinates: [CLLocationCoordinate2D] {
        get {
            geoPoints.asCLCoordinate2D
        }
        set(newCoord) {
            geoPoints = newCoord.asGeoPoints
        }
    }
    
    var timestamp: Date {
        get {
            createdAt!.dateValue()
        }
        set {
            createdAt = Timestamp(date: newValue)
        }
    }
    
    mutating func setStartTime() {
        startTime = Date()
    }
    
    mutating func setEndTime() {
        endTime = Date()
    }
    
    mutating func setTime() {
        timestamp = Date()
    }
    
    mutating func setUrl(_ url: String) {
        routeImageUrl = url
    }
}
