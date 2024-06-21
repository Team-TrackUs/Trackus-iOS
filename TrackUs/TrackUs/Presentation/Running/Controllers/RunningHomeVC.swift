//
//  RunningHomeVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import MapKit

final class RunningHomeVC: UIViewController {
    
    // MARK: - Properties
    
    private var posts = [Post]()
    private var selectedPost: Post?
    private var deletedPostUIDs = [String]()
    private var mapView: MKMapView!
    private let locationService = LocationService.shared
    private var pinAnnotations = [MKPointAnnotation]()
    
    private var isSelected = false
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.register(RunningMapCell.self, forCellWithReuseIdentifier: RunningMapCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var navigationMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dots_icon"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var myLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "location_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(myLocationButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let loadingView = LoadingView()
    private var timer: Timer?
    
    private var selectedAnnotation: MKAnnotation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationStatus()
        setupMapView()
        setMapRegion()
        configureUI()
        mapView(mapView, regionDidChangeAnimated: true)
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Selectors
    
    @objc func fetchRegion() {
        self.loadingView.isHidden = false
        self.loadingView.startAnimation()
        
        for annotation in pinAnnotations {
            mapView.removeAnnotation(annotation)
        }
        
        let regionCenter = mapView.region.center
        PostService().fetchMap(regionCenter: regionCenter) { posts, lastDocument, error in
            if let error = error {
                print("Error fetching posts: \(error)")
                return
            }
            guard let posts = posts else {
                print("No posts found")
                return
            }
            
            self.posts = posts
            
            self.addPinsForPosts()
            self.collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadingView.isHidden = true
            }
        }
    }
    
    @objc func myLocationButtonTapped() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = mapView.userLocation.coordinate
        mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        mapView.setRegion(mapRegion, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.addSubview(mapView)
        self.view.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        loadingView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        loadingView.isHidden = true
        
        mapView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: mapView.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant:
                                                +110).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        mapView.addSubview(myLocationButton)
        myLocationButton.translatesAutoresizingMaskIntoConstraints = false
        myLocationButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -110).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -16).isActive = true
    }
}
    // MARK: - MapView
 
extension RunningHomeVC: MKMapViewDelegate {
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false // 회전막기
    }
    
    // 초기위치 설정
    func setMapRegion() {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let defaultLocation = CLLocationCoordinate2D(latitude: 37.57050030731104, longitude: 126.97888892151437)
        
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
            LocationService.shared.allowBackgroundUpdates = false
        }
    }
    
    // 모집글의 첫위치 핀 추가
    func addPinsForPosts() {
        for post in posts {
            guard let firstCoord = post.courseRoutes.first else { continue }
            
            let coordinate = CLLocationCoordinate2D(latitude: firstCoord.latitude, longitude: firstCoord.longitude)
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            pin.title = post.uid
            
            mapView.addAnnotation(pin)
            pinAnnotations.append(pin)
        }
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
        
        if annotation is MKPointAnnotation {
            if annotation.title == "끝" {
                let imageView = UIImageView()
                imageView.image = UIImage(systemName: "flag.circle.fill")
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                imageView.layer.cornerRadius = 40 / 2
                imageView.backgroundColor = .white
                
                annotationView?.subviews.forEach { $0.removeFromSuperview() }
                
                annotationView?.frame.size = CGSize(width: 40, height: 40)
                annotationView?.addSubview(imageView)
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 40),
                    imageView.heightAnchor.constraint(equalToConstant: 40)
                ])
            } else {
                let imageView = UIImageView()
                imageView.image = UIImage(named: "mapMarker_icon")?.withRenderingMode(.alwaysOriginal)
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                imageView.layer.cornerRadius = 40 / 2
                imageView.backgroundColor = .white
                
                annotationView?.subviews.forEach { $0.removeFromSuperview() }
                
                annotationView?.frame.size = CGSize(width: 40, height: 40)
                annotationView?.addSubview(imageView)
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 40),
                    imageView.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .mainBlue
            testlineRenderer.lineWidth = 8.0
            return testlineRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    // Annotaion이 선택되었을 떄
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MKPointAnnotation else {
            return
        }
        
        if let selectedPost = posts.first(where: { $0.uid == annotation.title }) {
            HapticManager.shared.hapticImpact(style: .light)
            self.selectedPost = selectedPost
            
            mapView.annotations.forEach { pin in
                if pin !== annotation && pin.title != "끝" {
                    mapView.view(for: pin)?.isHidden = true
                }
            }
            
            let courseCoords = selectedPost.courseRoutes.map { geoPoint in
                return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            
            if let lastCoord = courseCoords.last {
                let endAnnotation = MKPointAnnotation()
                endAnnotation.coordinate = lastCoord
                endAnnotation.title = "끝"
                mapView.addAnnotation(endAnnotation)
            }
            
            let polyline = MKPolyline(coordinates: courseCoords, count: courseCoords.count)
            mapView.addOverlay(polyline)
            
            UIView.animate(withDuration: 0.1) {
                self.collectionView.frame.origin.y = self.mapView.frame.height - 120 - 110
            }
            
            guard let region = courseCoords.makeRegionToFit() else { return }
            mapView.setRegion(region, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 200, right: 100), animated: false)
            }
            
            if let index = posts.firstIndex(where: { $0.uid == annotation.title }) {
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            }
            
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = false
            self.myLocationButton.isHidden = true
            isSelected = true
        }
    }
    
    
    // Annotaion이 선택 해제 되었을떄
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapView.annotations.forEach { pin in
            mapView.view(for: pin)?.isHidden = false
        }
        
        mapView.annotations.forEach { pin in
            if pin.title == "끝" {
                mapView.removeAnnotation(pin)
            }
        }
        
        if let overlays = mapView.overlays as? [MKPolyline] {
            mapView.removeOverlays(overlays)
        }
        
        UIView.animate(withDuration: 0.1) {
            self.collectionView.frame.origin.y = self.view.frame.height
        }
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        self.myLocationButton.isHidden = false
        isSelected = false
        selectedAnnotation = nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isSelected == false {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(fetchRegion), userInfo: nil, repeats: false)
        } else {
            timer?.invalidate()
        }
    }
}

// MARK: - CollectionViewDelegate

extension RunningHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RunningMapCell.identifier, for: indexPath) as? RunningMapCell else {
            fatalError("Unable to dequeue RunningMapCell")
        }
        
        let post = posts[indexPath.row]
        cell.configure(post: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let courseDetailVC = CourseDetailVC(isBack: true)
        courseDetailVC.hidesBottomBarWhenPushed = true
        courseDetailVC.postUid = post.uid
        
        navigationMenuButton.addTarget(courseDetailVC, action: #selector(courseDetailVC.menuButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: navigationMenuButton)
        courseDetailVC.navigationItem.rightBarButtonItem = barButton
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: courseDetailVC, action: #selector(courseDetailVC.backButtonTapped))
        backButton.tintColor = .black
        courseDetailVC.navigationItem.leftBarButtonItem = backButton
        
        self.navigationController?.pushViewController(courseDetailVC, animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameSize = collectionView.frame.size
        return CGSize(width: frameSize.width - 16, height: frameSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    // 컬렉션뷰 페이징
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let rect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let point = CGPoint(x: rect.midX, y: rect.midY)
        
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let post = posts[indexPath.row]
            
            if indexPath.row != 0 && indexPath.row != posts.count - 1 {
                if let currentAnnotation = selectedAnnotation {
                    mapView.deselectAnnotation(currentAnnotation, animated: true)
                }
            }
            
            if let newAnnotation = mapView.annotations.first(where: { ($0 as? MKPointAnnotation)?.title == post.uid }) {
                mapView.selectAnnotation(newAnnotation, animated: true)
                selectedAnnotation = newAnnotation
                isSelected = true
                mapView.annotations.forEach { pin in
                    if pin !== newAnnotation && pin.title != "끝" {
                        mapView.view(for: pin)?.isHidden = true
                    }
                }
            }
        }
    }
}
