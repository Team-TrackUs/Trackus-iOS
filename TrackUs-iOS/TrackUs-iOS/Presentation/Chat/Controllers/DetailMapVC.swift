//
//  DetailMapVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 7/12/24.
//

import UIKit
import MapKit
import CoreLocation

class DetailMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var coordinate: CLLocationCoordinate2D?
    private var locationManager: CLLocationManager!
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private lazy var locationMarker: UIImageView = {
        let ImageView = UIImageView(image: UIImage(named: "MarkerPin"))
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        return ImageView
    }()
    
    private lazy var currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "location_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        addCustomPin()
        setupNavigationBar()
        setupCurrentLocationButton()
        configureLocationServices()
        if let coordinate = coordinate {
            showLocationOnMap(coordinate: coordinate)
        }
        
        // 스와이프로 이전 화면 갈 수 있도록 추가
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    // 네비게이션바 세팅
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(dismissDetailViewController))
        backButton.tintColor = .gray1
        
        navigationItem.title = "위치 상세보기"
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        //view.addSubview(locationMarker)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCurrentLocationButton() {
        view.addSubview(currentLocationButton)
        
        NSLayoutConstraint.activate([
            currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            //currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
            //currentLocationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureLocationServices() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func updateMarkerPosition() {
        guard let coordinate = coordinate else { return }
        let point = mapView.convert(coordinate, toPointTo: mapView)
        locationMarker.center = point
    }
        
    // MKMapViewDelegate method to update marker position when the map is panned or zoomed
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let reuseId = "test"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.addSubview(locationMarker)
        NSLayoutConstraint.activate([
            locationMarker.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
            locationMarker.bottomAnchor.constraint(equalTo: annotationView!.centerYAnchor),
            locationMarker.widthAnchor.constraint(equalToConstant: 36),
            locationMarker.heightAnchor.constraint(equalToConstant: 52)
        ])
        return annotationView
    }
    
    private func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        //updateMarkerPosition()
    }
    
    private func addCustomPin() {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate!
        pin.title = "새싹 영등포캠퍼스"
        pin.subtitle = "전체 3층짜리 건물"
        mapView.addAnnotation(pin)
    }
    
    @objc private func currentLocationButtonTapped() {
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func dismissDetailViewController() {
        //dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}
