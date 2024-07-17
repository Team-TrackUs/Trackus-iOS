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
    
    private lazy var mainButton: MainButton = {
        let button = MainButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = "이 위치 전송하기"
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupNavigationBar()
        setupView()
        configureLocationServices()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        backButton.tintColor = .gray1

        navigationItem.title = "위치전송"
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupView() {
        view.addSubview(mapView)
        view.addSubview(centerMarker)
        view.addSubview(currentLocationButton)
        view.addSubview(mainButton)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            centerMarker.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            centerMarker.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            centerMarker.widthAnchor.constraint(equalToConstant: 36),
            centerMarker.heightAnchor.constraint(equalToConstant: 52),
            
            currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            currentLocationButton.bottomAnchor.constraint(equalTo: mainButton.topAnchor, constant: -16),
            
            mainButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            mainButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mainButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
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

extension SendLocationVC: MKMapViewDelegate {
    
    // 맵 드래그 시작할때
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.mainButton.isEnabled = false
        }
    }
    
    // 맵 드래그가 종료되고 관성이 있을 때 관성이 끝난 후
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.mainButton.isEnabled = true
        }
    }
}
