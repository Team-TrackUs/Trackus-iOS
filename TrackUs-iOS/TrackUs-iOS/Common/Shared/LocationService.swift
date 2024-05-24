//
//  LocationService.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import Foundation
import CoreLocation
import UIKit

final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    let locationManager = CLLocationManager()
    var currentLocation : CLLocationCoordinate2D?
    weak var userLocationDelegate: UserLocationDelegate?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 가장 높은수준의 정확도
        locationManager.distanceFilter = 10 // 특정거리를 이동할때마다 업데이트 받도록 filter
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.location?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
        
        if userLocationDelegate != nil {
            userLocationDelegate?.userLocationUpated(location: locations.first!)
        }
    }
}
