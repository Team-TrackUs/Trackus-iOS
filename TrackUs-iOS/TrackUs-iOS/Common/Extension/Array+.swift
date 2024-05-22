//
//  Array+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import CoreLocation
import Firebase
import MapKit

extension Array where Element == CLLocationCoordinate2D {
    var asGeoPoints: [GeoPoint] {
        self.map {GeoPoint(latitude: $0.latitude, longitude: $0.longitude)}
    }
    
    var centerPosition: CLLocationCoordinate2D? {
        guard !self.isEmpty else {
            return nil
        }
        var totalLatitude: Double = 0
        var totalLongitude: Double = 0
        
        for coordinate in self {
            totalLatitude += coordinate.latitude
            totalLongitude += coordinate.longitude
        }
        let count = Double(self.count)
        let averageLatitude = totalLatitude / count
        let averageLongitude = totalLongitude / count
        
        return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
    }
    
    var totalDistance: Double {
        var distance: Double = 0
        for i in 0..<self.count - 1 {
            distance += self[i].distance(to: self[i + 1])
        }
        return distance
    }
}

extension Array where Element == GeoPoint {
    var asCLCoordinate2D: [CLLocationCoordinate2D] {
        self.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}
