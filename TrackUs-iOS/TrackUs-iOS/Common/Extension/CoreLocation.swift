//
//  CoreLocation.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }
}
