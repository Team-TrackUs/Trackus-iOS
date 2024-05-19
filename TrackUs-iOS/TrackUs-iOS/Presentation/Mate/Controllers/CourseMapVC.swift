//
//  CourseMapVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/18/24.
//

import UIKit
import MapKit

class CourseMapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    // MARK: - Properties
    
    lazy var testcoords: [CLLocationCoordinate2D] = [] // 좌표배열
    lazy var distance: CLLocationDistance = 0 // 거리
    
    var isRegionSet = false // mapkit
    var locationManager = CLLocationManager() // mapkit
    var pinAnnotations: [MKPointAnnotation] = [] // mapkit
    
    var window: UIWindow?
    var drawMapView: MKMapView = {
        let mapview = MKMapView()
        return mapview
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .mainBlue
        label.text = "\(String(format: "%.2f", distance)) km"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 46)
        label.layer.cornerRadius = 40 / 2
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        label.layer.shadowRadius = 6
        label.clipsToBounds = true
        
        return label
    }()
    
    let myLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "location_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(myLocationButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupNavBar()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func myLocationButtonTapped() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = drawMapView.userLocation.coordinate
        mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        drawMapView.setRegion(mapRegion, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
        
        self.drawMapView = MKMapView(frame: CGRectMake(0, 20, (self.window?.frame.width)!, (self.window?.frame.height)!))
        self.view.addSubview(self.drawMapView)
        
        MapConfigureUI()
        
        view.addSubview(myLocationButton)
        myLocationButton.translatesAutoresizingMaskIntoConstraints = false
        myLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: 46).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        distanceLabel.clipsToBounds = true
    }
    
    // 맵 세팅
    func MapConfigureUI() {
        self.locationManager = CLLocationManager() // 사용자 위치를 가져오는데 필요한 객체
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization() // 앱을 처음 열 때 사용자의 위치를 얻을 수 있는 권한을 팝업으로 요청
        locationManager.startUpdatingLocation()
        drawMapView.delegate = self
        drawMapView.mapType = MKMapType.standard
        drawMapView.isZoomEnabled = true
        drawMapView.isScrollEnabled = true
        drawMapView.center = view.center
        drawMapView.showsUserLocation = true
        
        for (index, coord) in testcoords.enumerated() {
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            let pinTitle = "\(index + 1)" // 핀의 제목을 인덱스로 설정
            pin.title = pinTitle
            drawMapView.addAnnotation(pin)
            pinAnnotations.append(pin)
        }
        
        addPolylineToMap()
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "코스 상세보기"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - MapKit
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // adding map region
        if testcoords.count > 0 {
            if !isRegionSet {
                
                let center = CLLocationCoordinate2D(latitude: testcoords[0].latitude, longitude: testcoords[0].longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                drawMapView.setRegion(region, animated: true) // 위치를 사용자의 위치로
                
                isRegionSet = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .mainBlue
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
        
        if let pin = annotation as? MKPointAnnotation {
            let label = UILabel(frame: CGRect(x: -8, y: -8, width: 20, height: 20))
//            label.text = pin.title ?? ""
            label.text = pin.title ?? "\(testcoords.count + 1)"
            label.textColor = .mainBlue
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 12)
            
            label.backgroundColor = .white
            label.layer.borderColor = UIColor.mainBlue.cgColor
            label.layer.borderWidth = 2.0
            label.layer.cornerRadius = label.frame.size.width / 2
            
            label.clipsToBounds = true
            annotationView?.addSubview(label)
        }
        
        return annotationView
    }
    
    func addPolylineToMap() {
        let polyline = MKPolyline(coordinates: testcoords, count: testcoords.count)
        drawMapView.addOverlay(polyline)
    }
    
}
