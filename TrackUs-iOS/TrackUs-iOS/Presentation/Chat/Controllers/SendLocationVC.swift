//
//  SendMapVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 7/10/24.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationSelectionDelegate: AnyObject {
    func didSelectLocation(latitude: Double, longitude: Double)
}

class SendLocationVC: UIViewController, CLLocationManagerDelegate {
    
    weak var delegate: LocationSelectionDelegate?
    private let locationManager = CLLocationManager()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private lazy var centerMarker: UIImageView = {
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
    private var zoomInButton: UIButton!
    private var zoomOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        configureLocationServices()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "위치전송"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward")?.withTintColor(.gray1),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "전송",
            style: .done,
            target: self,
            action: #selector(sendButtonTapped)
        )
    }
    
    private func setupView() {
        view.addSubview(mapView)
        view.addSubview(centerMarker)
        view.addSubview(currentLocationButton)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            centerMarker.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            centerMarker.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            centerMarker.widthAnchor.constraint(equalToConstant: 36),
            centerMarker.heightAnchor.constraint(equalToConstant: 52),
            
            currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func configureLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendButtonTapped() {
        let centerCoordinate = mapView.centerCoordinate
        delegate?.didSelectLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func currentLocationButtonTapped() {
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
