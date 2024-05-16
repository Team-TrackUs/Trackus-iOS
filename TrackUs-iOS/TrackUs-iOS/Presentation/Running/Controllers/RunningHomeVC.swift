//
//  RunningHomeVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import MapKit

final class RunningHomeVC: UIViewController {
    private var mapView: MKMapView!
    private let locationService = LocationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationStatus()
        setupMapView()
        setMapRegion()
    }
    
    // 맵설정
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    // 초기위치 설정
    func setMapRegion() {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let defaultLocation = CLLocationCoordinate2D(latitude: 37.57050030731104, longitude:  126.97888892151437)
        
        if let currentLocation = locationService.currentLocation {
            mapView.setRegion(.init(center: currentLocation, span: defaultSpanValue), animated: true)
        } else {
            mapView.setRegion(.init(center: defaultLocation, span: defaultSpanValue), animated: true)
        }
    }
    
    // 위치권한 확인
    func checkLocationStatus() {
        if LocationService.shared.locationManager.authorizationStatus != .authorizedWhenInUse {
            LocationService.shared.locationManager.requestWhenInUseAuthorization()
        }
    }
}
