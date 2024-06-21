//
//  CoreLocation.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    var asCLLocation: CLLocation {
        CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }
}
