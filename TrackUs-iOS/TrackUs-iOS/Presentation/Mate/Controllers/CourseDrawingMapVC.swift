//
//  CourseDrawingMapVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/13/24.
//

import UIKit
import MapKit
import CoreLocation

class CourseDrawingMapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    var drawMapView: MKMapView!
    var locationManager = CLLocationManager()
    var testcoords: [CLLocationCoordinate2D] = []
    var pinAnnotations: [MKPointAnnotation] = []
    var isRegionSet = false
    
    var distance: CLLocationDistance = 0
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .blue
        label.textColor = .white
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 46)
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        label.layer.shadowRadius = 6
        
        return label
    }()
    
    let myLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "location_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(myLocationButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let courseClearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "trash_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(courseClearButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let oneStepBackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "revert_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(oneStepBackButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let finishDrawCourseButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.setTitle("코스 완성", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 398, height: 56)
        button.layer.cornerRadius = 56 / 2
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        
        button.addTarget(self, action: #selector(finishDrawCourseButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        
        if gestureRecognizer.state == .ended {
            let touchLocation = gestureRecognizer.location(in: drawMapView)
            let locationCoordinate = drawMapView.convert(touchLocation, toCoordinateFrom: drawMapView)
            
            // pin 설정
            let myPin = MKPointAnnotation()
            myPin.coordinate = locationCoordinate
            myPin.title = "\(testcoords.count + 1)"
            
            drawMapView?.addAnnotation(myPin)
            
            // latitude & longitude 저장
            testcoords.append(locationCoordinate)
            pinAnnotations.append(myPin)
            
            print(testcoords)
            
            if testcoords.count >= 2 {
                let previousLocation = CLLocation(latitude: testcoords[testcoords.count - 2].latitude, longitude: testcoords[testcoords.count - 2].longitude)
                let currentLocation = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                let distance = previousLocation.distance(from: currentLocation)
                
                self.distance += distance
                
                let coordinates = [testcoords[testcoords.count - 2], locationCoordinate]
                let polyline = MKPolyline(coordinates: coordinates, count: 2)
                drawMapView?.addOverlay(polyline)
                
                self.calculateDistanceAndUpdateLabel()
            }
        }
    }
    
    @objc func myLocationButtonTapped() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = drawMapView.userLocation.coordinate
        mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        drawMapView?.setRegion(mapRegion, animated: true)
    }
    
    @objc func courseClearButtonTapped() {
        DispatchQueue.main.async {
            self.drawMapView?.removeOverlays(self.drawMapView?.overlays ?? [])
            self.drawMapView?.removeAnnotations(self.pinAnnotations)
            self.testcoords.removeAll()
            
            self.distance = 0
            self.updateDistanceLabel()
        }
    }
    
    @objc func oneStepBackButtonTapped() {
        DispatchQueue.main.async {
            guard !self.testcoords.isEmpty else { return }
            
            if let lastOverlay = self.drawMapView?.overlays.last {
                self.drawMapView?.removeOverlay(lastOverlay)
            }

            let lastAnnotation = self.pinAnnotations.popLast()
            self.drawMapView?.removeAnnotation(lastAnnotation!)
            self.testcoords.removeLast()
            
            self.calculateDistanceAndUpdateLabel()
        }
    }
    
    @objc func finishDrawCourseButtonTapped() {
        print("Next CourseMakeView")
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
        
        self.drawMapView = MKMapView(frame: CGRectMake(0, 20, (self.window?.frame.width)!, (self.window?.frame.height)!))
        self.view.addSubview(self.drawMapView!)
        
        MapConfigureUI()
        
        view.addSubview(myLocationButton)
        myLocationButton.translatesAutoresizingMaskIntoConstraints = false
        myLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(finishDrawCourseButton)
        finishDrawCourseButton.translatesAutoresizingMaskIntoConstraints = false
        finishDrawCourseButton.widthAnchor.constraint(equalToConstant: 398).isActive = true
        finishDrawCourseButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        finishDrawCourseButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        finishDrawCourseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        finishDrawCourseButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [oneStepBackButton, courseClearButton])
        stack.axis = .vertical
        stack.spacing = 6
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.bottomAnchor.constraint(equalTo: finishDrawCourseButton.topAnchor, constant: -20).isActive = true
        stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        updateDistanceLabel()
        view.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints =  false
        distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: 46).isActive = true
        distanceLabel.layer.cornerRadius = 46 / 2
        distanceLabel.clipsToBounds = true
        distanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        distanceLabel.text = "0.00 km"
        configureDistanceLabel()
        
    }
    
    func MapConfigureUI() {
        self.locationManager = CLLocationManager() // 사용자 위치를 가져오는데 필요한 객체
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization() // 앱을 처음 열 때 사용자의 위치를 얻을 수 있는 권한을 팝업으로 요청
        locationManager.startUpdatingLocation()
        drawMapView?.delegate = self
        drawMapView?.mapType = MKMapType.standard
        drawMapView?.isZoomEnabled = true
        drawMapView?.isScrollEnabled = true
        drawMapView?.center = view.center
        drawMapView?.showsUserLocation = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gestureRecognizer: )))
        tapGesture.delegate = self
        
        self.drawMapView?.addGestureRecognizer(tapGesture)
        
        for coord in testcoords {
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            pin.title = "Coordinate: \(coord.latitude), \(coord.longitude)"
            drawMapView.addAnnotation(pin)
            pinAnnotations.append(pin)
        }
    }
    
    func updateDistanceLabel() {
        DispatchQueue.main.async {
            self.distanceLabel.text = "\(String(format: "%.2f", self.distance)) km"
        }
    }
    
    func calculateDistanceAndUpdateLabel() {
        guard testcoords.count >= 2 else {
            self.distance = 0
            updateDistanceLabel()
            return
        }
        
        var totalDistance: CLLocationDistance = 0
        
        for i in 1..<testcoords.count {
            let previousLocation = CLLocation(latitude: testcoords[i - 1].latitude, longitude: testcoords[i - 1].longitude)
            let currentLocation = CLLocation(latitude: testcoords[i].latitude, longitude: testcoords[i].longitude)
            totalDistance += previousLocation.distance(from: currentLocation)
        }
        
        self.distance = totalDistance / 1000
        
        updateDistanceLabel()
    }
    
    func configureDistanceLabel() {
        // bold + italic
        let font = UIFont.boldSystemFont(ofSize: 16)
        let italicFontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)
        let boldItalicFont = UIFont(descriptor: italicFontDescriptor!, size: 16)
        
        distanceLabel.font = boldItalicFont
    }
    
    // MARK: - MapKit
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // adding map region
        if !isRegionSet {
            let userLocation: CLLocation = locations[0]
            
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            drawMapView?.setRegion(region, animated: true) // 위치를 사용자의 위치로
            
            isRegionSet = true
        }
    }
    
    // Polyline 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 5.0
            return testlineRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "pinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        // Annotation pin의 모양 설정
        if let pin = annotation as? MKPointAnnotation {
            let label = UILabel(frame: CGRect(x: -8, y: -8, width: 20, height: 20))
            label.text = pin.title ?? ""
            label.textColor = .blue
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 12)
            
            label.backgroundColor = .white
            label.layer.borderColor = UIColor.blue.cgColor
            label.layer.borderWidth = 2.0
            label.layer.cornerRadius = label.frame.size.width / 2
            
            label.clipsToBounds = true
            annotationView?.addSubview(label)
        }
        
        return annotationView
    }
    
}
