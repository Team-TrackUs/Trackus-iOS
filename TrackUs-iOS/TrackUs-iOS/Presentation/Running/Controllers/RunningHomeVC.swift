//
//  RunningHomeVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import MapKit

final class RunningHomeVC: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    private var posts = [Post]()
    private var selectedPost: Post?
    private var deletedPostUIDs = [String]()
    private var mapView: MKMapView!
    private let locationService = LocationService.shared
    private var pinAnnotations = [MKPointAnnotation]()
    
    private var isSelected = false
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowOpacity = 0.8
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray3.cgColor
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let runningStyleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let locationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "locationPin_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.2, 0.9, 0.9)
        return imageView
    }()
    
    let timeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "time_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        return imageView
    }()
    
    let distanceIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "arrowBoth_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        return imageView
    }()
    
    let peopleIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "people_icon"))
        return imageView
    }()
    
    let closingLabel: UILabel = {
        let label = UILabel()
        label.text = "마감"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .gray1
        label.textAlignment = .center
        return label
    }()
    
    let endLabel: UILabel = {
        let label = UILabel()
        label.text = "종료"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .gray1
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationStatus()
        setupMapView()
        setMapRegion()
        configureUI()
        fetchPosts()
        
        self.mapView.delegate = self
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
    
    @objc func infoButtonTapped() {
        guard let selectedPost = selectedPost else { return }
        
        let courseDetailVC = CourseDetailVC()
        courseDetailVC.hidesBottomBarWhenPushed = true
        
        courseDetailVC.postUid = selectedPost.uid
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .gray1
        
        button.addTarget(courseDetailVC, action: #selector(courseDetailVC.menuButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        courseDetailVC.navigationItem.rightBarButtonItem = barButton
        
        self.navigationController?.pushViewController(courseDetailVC, animated: true)
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.addSubview(mapView)
        
        mapView.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 16).isActive = true
        infoButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -16).isActive = true
        infoButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant:
        +120).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.infoButton.addSubview(postImageView)
        postImageView.topAnchor.constraint(equalTo: self.infoButton.layoutMarginsGuide.topAnchor).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: self.infoButton.layoutMarginsGuide.bottomAnchor).isActive = true
        postImageView.leadingAnchor.constraint(equalTo: self.infoButton.layoutMarginsGuide.leadingAnchor).isActive = true
        postImageView.widthAnchor.constraint(equalTo: postImageView.heightAnchor).isActive = true
        
        postImageView.addSubview(closingLabel)
        closingLabel.translatesAutoresizingMaskIntoConstraints = false
        closingLabel.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor).isActive = true
        closingLabel.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor).isActive = true
        closingLabel.isHidden = true
        
        self.infoButton.addSubview(runningStyleLabel)
        runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        runningStyleLabel.topAnchor.constraint(equalTo: self.infoButton.layoutMarginsGuide.topAnchor).isActive = true
        runningStyleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        runningStyleLabel.widthAnchor.constraint(equalToConstant: 54).isActive = true
        runningStyleLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        
        self.infoButton.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: runningStyleLabel.bottomAnchor, constant: 3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        
        let locationStack = UIStackView(arrangedSubviews: [locationIcon, locationLabel])
        locationStack.axis = .horizontal
        locationStack.spacing = 5
        
        let timeStack = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        timeStack.axis = .horizontal
        timeStack.spacing = 5
        
        let distanceStack = UIStackView(arrangedSubviews: [distanceIcon, distanceLabel])
        distanceStack.axis = .horizontal
        distanceStack.spacing = 5
        
        let peopleStack = UIStackView(arrangedSubviews: [peopleIcon, peopleLabel])
        peopleStack.axis = .horizontal
        peopleStack.spacing = 5
        
        self.infoButton.addSubview(locationStack)
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        locationStack.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        
        self.infoButton.addSubview(timeStack)
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        timeStack.leadingAnchor.constraint(equalTo: locationStack.trailingAnchor, constant: 8).isActive = true
        
        self.infoButton.addSubview(distanceStack)
        distanceStack.translatesAutoresizingMaskIntoConstraints = false
        distanceStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        distanceStack.leadingAnchor.constraint(equalTo: timeStack.trailingAnchor, constant: 8).isActive = true
        
        self.infoButton.addSubview(peopleStack)
        peopleStack.translatesAutoresizingMaskIntoConstraints = false
        peopleStack.bottomAnchor.constraint(equalTo: infoButton.layoutMarginsGuide.bottomAnchor).isActive = true
        peopleStack.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        
        self.infoButton.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: infoButton.layoutMarginsGuide.bottomAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: self.infoButton.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    func fetchPosts() {
        let postService = PostService()
        
        postService.fetchPostTable(startAfter: nil, limit: 100) { [weak self] resultPosts, lastDocumentSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Error fetching posts = \(error.localizedDescription)")
                return
            }
            
            if let resultPosts = resultPosts {
                self.posts = resultPosts.filter { post in
                    !self.deletedPostUIDs.contains(post.uid)
                }
                
                self.posts.sort { $0.createdAt > $1.createdAt }
                
                self.addPinsForPosts()
            } else {
                print("DEBUG: No posts found")
            }
        }
    }
    
    func setupButton(post: Post) {
        postImageView.loadImage(url: post.routeImageUrl)
        
        self.runningStyleLabel.text = MateViewCell().runningStyleString(for: post.runningStyle)
        
        if post.title.count > 15 {
            self.titleLabel.text = "\(post.title.prefix(15))..."
        } else {
            self.titleLabel.text = post.title
        }
        
        self.locationLabel.text = post.address
        self.timeLabel.text = post.startDate.toString(format: "h:mm a")
        self.distanceLabel.text = "\(String(format: "%.2f", post.distance))km"
        self.peopleLabel.text = "\(post.members.count) / \(post.numberOfPeoples)"
        self.dateLabel.text = post.startDate.toString(format: "yyyy년 MM월 dd일")
        
        switch MateViewCell().runningStyleString(for: post.runningStyle) {
        case "걷기":
            self.runningStyleLabel.backgroundColor = .walking
        case "조깅":
            self.runningStyleLabel.backgroundColor = .jogging
        case "달리기":
            self.runningStyleLabel.backgroundColor = .running
        case "인터벌":
            self.runningStyleLabel.backgroundColor = .interval
        default:
            self.runningStyleLabel.backgroundColor = .mainBlue
        }
        
        if post.members.count >= post.numberOfPeoples {
            closingLabel.isHidden = false
        } else {
            closingLabel.isHidden = true
        }
    }
    
    // 맵설정
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
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
            let imageView = UIImageView()
            imageView.image = UIImage(named: "trackus_icon")?.withRenderingMode(.alwaysTemplate)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            imageView.layer.cornerRadius = 50 / 2
            imageView.backgroundColor = .white
            imageView.layer.borderColor = UIColor.mainBlue.cgColor
            imageView.layer.borderWidth = 2
            
            annotationView?.subviews.forEach { $0.removeFromSuperview() }
            
            annotationView?.frame.size = CGSize(width: 50, height: 50)
            annotationView?.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 50),
                imageView.heightAnchor.constraint(equalToConstant: 50)
            ])
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
            view.tintColor = .red
            view.layer.borderColor = UIColor.caution.cgColor
            HapticManager.shared.hapticImpact(style: .light)
            setupButton(post: selectedPost)
            self.selectedPost = selectedPost
            
            mapView.annotations.forEach { pin in
                if pin !== annotation {
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
                self.infoButton.frame.origin.y = self.mapView.frame.height - 128 - 120
            }
            
            guard let region = courseCoords.makeRegionToFit() else { return }
            mapView.setRegion(region, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: false)
            }
            
            isSelected = true
        }
    }


    // Annotaion이 선택 해제 되었을떄
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.tintColor = .mainBlue
        view.layer.borderColor = UIColor.mainBlue.cgColor
        
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
            self.infoButton.frame.origin.y = self.view.frame.height
        }
        
        isSelected = false
    }
}
