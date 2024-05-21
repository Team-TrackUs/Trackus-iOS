//
//  Array+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import CoreLocation
import Firebase

extension Array where Element == CLLocationCoordinate2D {
    var asGeoPoints: [GeoPoint] {
        self.map {GeoPoint(latitude: $0.latitude, longitude: $0.longitude)}
    }
}

extension Array where Element == GeoPoint {
    var asCLCoordinate2D: [CLLocationCoordinate2D] {
        self.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}
