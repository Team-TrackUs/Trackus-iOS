//
//  RunActivityVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//
// TODO: - 스와이프 구현
// tanslation x값을 측정
// 버튼의 center.x값을 이동한 값만큼 추가
// TODO: - 라이브트래킹
// 타이머 설정
// TODO: - 디자인변경 적용
// 러닝중지시 고도, 케이던스 정보추가
// blurView의 bottomInset을 runInfoStackView + 50으로 설정

import UIKit
import MapKit

final class RunActivityVC: UIViewController {
    // MARK: - Properties
    private let locationService = LocationService.shared
    private let runTrackingManager = RunTrackingManager()
    private var mapView: MKMapView!
    private var isActive = true
    private var timer: Timer?
    private var count = 3
    private var polyline: MKPolyline?
    private var annotation: MKPointAnnotation?
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.count.asString
        label.font = UIFont.boldSystemFont(ofSize: 58)
        label.textColor = .white
        return label
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 20
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "잠시 후 러닝이 시작됩니다!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        [countLabel, label].forEach {st.addArrangedSubview($0)}
        view.addSubview(st)
        st.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        st.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    private lazy var swipeBox: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.layer.cornerRadius = 35
        let label = UILabel()
        label.text = "밀어서 러닝 종료"
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(actionButton)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.isHidden = true
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.layer.cornerRadius = 25
        btn.backgroundColor = .white
        let image = UIImage(systemName: "pause.fill")
        
        btn.setImage(image, for: .normal)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pangestureHandler))
        btn.addGestureRecognizer(panGesture)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var kilometerLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0 km"
        label.font = UIFont.italicSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isLayoutMarginsRelativeArrangement = true // margin 적용
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        sv.layer.cornerRadius = 30
        
        let label = UILabel()
        label.text = "🏃‍♂️ 현재까지 거리"
        sv.backgroundColor = .white
        sv.isHidden = true
        [label, kilometerLabel].forEach {sv.addArrangedSubview($0)}
        return sv
    }()
    
    private let calorieValue: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        return label
    }()
    
    private let paceValue: UILabel = {
        let label = UILabel()
        label.text = "-'--''"
        return label
    }()
    
    private let timeValue: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        return label
    }()
    
    private let altitudeValue: UILabel = {
        let label = UILabel()
        label.text = "0.0m"
        return label
    }()
    
    private let cadenceValue: UILabel = {
        let label = UILabel()
        label.text = "-"
        return label
    }()
    
    private lazy var runInfoStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing
        let calorieStackVIew = makeCircleStView()
        let calorieImage = UIImageView()
        calorieImage.image = UIImage(resource: .fireIcon)
        
        let calorieLabel = UILabel()
        calorieLabel.text = "소모 칼로리"
        calorieLabel.font = UIFont.systemFont(ofSize: 12)
        [calorieImage, calorieLabel, calorieValue].forEach {calorieStackVIew.addArrangedSubview($0)}
        
        let paceStackVIew = makeCircleStView()
        let paceImage = UIImageView()
        paceImage.image = UIImage(resource: .pulseIcon)
        
        let paceLabel = UILabel()
        paceLabel.font = UIFont.systemFont(ofSize: 12)
        paceLabel.text = "페이스"
        [paceImage, paceLabel, paceValue].forEach {paceStackVIew.addArrangedSubview($0)}
        
        let timeStackVIew = makeCircleStView()
        let timeImage = UIImageView()
        timeImage.image = UIImage(resource: .stopwatchIcon)
        let timeLabel = UILabel()
        
        timeLabel.text = "경과 시간"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        [timeImage, timeLabel, timeValue].forEach {timeStackVIew.addArrangedSubview($0)}
        
        [calorieStackVIew, paceStackVIew, timeStackVIew].forEach { sv.addArrangedSubview($0) }
        sv.isHidden = true
        return sv
    }()
    
    private lazy var runInfoStackView2: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        
        sv.distribution = .equalSpacing
        let altitudeStackView = makeCircleStView()
        let altitudeImage = UIImageView()
        altitudeImage.image = UIImage(resource: .altitudeIcon)
        
        let paltitudeLabel = UILabel()
        paltitudeLabel.font = UIFont.systemFont(ofSize: 12)
        paltitudeLabel.text = "고도"
        [altitudeImage, paltitudeLabel, altitudeValue].forEach {altitudeStackView.addArrangedSubview($0)}
        
        let cadanceStackVIew = makeCircleStView()
        let cadanceImage = UIImageView()
        cadanceImage.image = UIImage(resource: .footprintIcon)
        let cadanceLabel = UILabel()
        
        cadanceLabel.text = "케이던스"
        cadanceLabel.font = UIFont.systemFont(ofSize: 12)
        
        [cadanceImage, cadanceLabel, cadenceValue].forEach {cadanceStackVIew.addArrangedSubview($0)}
        
        [UIView(), altitudeStackView, UIView(), cadanceStackVIew, UIView()].forEach { sv.addArrangedSubview($0) }
        sv.isHidden = true
        return sv
    }()
    
    private lazy var blurView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setMapRegion()
        setConstraint()
        setTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGradientLayer()
    }
    
    // MARK: - UI Methods
    func setConstraint() {
        self.view.addSubview(overlayView)
        self.view.addSubview(blurView)
        self.view.addSubview(swipeBox)
        self.view.addSubview(topStackView)
        self.view.addSubview(runInfoStackView)
        self.view.addSubview(runInfoStackView2)
        
        NSLayoutConstraint.activate([
            swipeBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            swipeBox.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            swipeBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            swipeBox.heightAnchor.constraint(equalToConstant: 70),
            
            actionButton.leadingAnchor.constraint(equalTo: swipeBox.leadingAnchor, constant: 10),
            actionButton.topAnchor.constraint(equalTo: swipeBox.topAnchor, constant: 10),
            actionButton.bottomAnchor.constraint(equalTo: swipeBox.bottomAnchor, constant: -10),
            
            topStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            topStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -20),
            
            runInfoStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            runInfoStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            runInfoStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 20),
            
            runInfoStackView2.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            runInfoStackView2.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            runInfoStackView2.topAnchor.constraint(equalTo: self.runInfoStackView.bottomAnchor, constant: 20),
            
            blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func setMapRegion(animated: Bool = true) {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        if let currentLocation = locationService.currentLocation {
            mapView.setRegion(.init(center: currentLocation, span: defaultSpanValue), animated: animated)
        }
    }
    
    func setMapRegion(center: CLLocationCoordinate2D, animated: Bool = true) {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        mapView.setRegion(.init(center: center, span: defaultSpanValue), animated: animated)
    }
    
    func updatedOnStart() {
        self.startTracking()
        self.startTimer()
        self.setCameraOnTrackingMode()
        
        self.overlayView.isHidden = true
        self.swipeBox.isHidden = false
        self.topStackView.isHidden = false
        self.runInfoStackView.isHidden = false
        self.blurView.isHidden = true
        self.runInfoStackView2.isHidden = true
        self.actionButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        UIView.animate(withDuration: 0.2) {
            self.topStackView.axis = .horizontal
            self.topStackView.spacing = 0
            self.kilometerLabel.font = UIFont.italicSystemFont(ofSize: 24)
        }
    }
    
    func updatedOnPause() {
        self.stopTracking()
        self.stopTimer()
        self.setCameraOnPauseMode()
        
        self.actionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.blurView.isHidden = false
        self.runInfoStackView2.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.topStackView.axis = .vertical
            self.topStackView.spacing = 20
            self.kilometerLabel.font = UIFont.italicSystemFont(ofSize: 32)
        }
    }
    
    func addGradientLayer() {
        let maskLayer = CAGradientLayer()
        let shadowRadius: CGFloat = 45
        maskLayer.frame = blurView.bounds
        maskLayer.shadowRadius = shadowRadius
        // bottom값이 적으면 그림자효과가 길어짐
        // bounds.inset으로 안쪽에 마진을 생성
        maskLayer.shadowPath = CGPath(roundedRect: self.blurView.bounds.inset(by: UIEdgeInsets(top: -shadowRadius, left: -shadowRadius, bottom: self.runInfoStackView2.frame.maxY - 50, right: -shadowRadius)), cornerWidth: 0, cornerHeight: 0, transform: nil)
        maskLayer.shadowOpacity = 1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        blurView.layer.mask = maskLayer
    }
    
    func goToResultVC() {
        let resultVC = RunningResultVC()
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    }
    
    // MARK: - Helpers
    func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.count == 1 {
                self.timer?.invalidate()
                self.updatedOnStart()
            }
            self.count -= 1
            self.countLabel.text = self.count.asString
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            self.countLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.runTrackingManager.seconds += 1
            self.timeValue.text = self.runTrackingManager.seconds.toMMSSTimeFormat
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func setCameraOnPauseMode() {
        self.setMapRegionMinimum()
        self.drawLine()
    }
    
    func setCameraOnTrackingMode() {
        self.removeLine()
        self.setMapRegion()
    }
    
    func drawLine() {
        let coordinates = self.runTrackingManager.coordinates
        guard coordinates.count >= 1 else { return }
        
        polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        annotation = MKPointAnnotation()
        guard let polyline = polyline, let annotation = annotation else { return }
        self.mapView.addOverlay(polyline)
        
        annotation.coordinate = coordinates.first!
        self.mapView.addAnnotation(annotation)
    }
    
    func removeLine() {
        guard let polyline = polyline, let annotation = annotation else { return }
        self.mapView.removeOverlay(polyline)
        self.mapView.removeAnnotation(annotation)
    }
    
    func setMapRegionMinimum() {
        if let center = self.runTrackingManager.coordinates.centerPosition {
            setMapRegion(center: center, animated: false)
        } else {
            setMapRegion(animated: false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: self.runInfoStackView2.frame.maxY, left: 20, bottom: 20, right: 20), animated: false)
        }
    }
    
    // MARK: - objc Methods
    @objc func pangestureHandler(sender: UIPanGestureRecognizer) {
        let minX = actionButton.bounds.width / 2 + 10
        let translation = sender.translation(in: actionButton)
        
        let newX = actionButton.center.x + translation.x
        let maxX = swipeBox.bounds.maxX - CGFloat(35)
        actionButton.center.x = max(minX, min(newX, maxX))
        sender.setTranslation(CGPoint.zero, in: actionButton)
        
        if sender.state == .ended && newX > maxX * 0.9 {
            HapticManager.shared.hapticImpact(style: .medium)
            goToResultVC()
        } else if sender.state == .ended  {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.actionButton.center.x = minX
            }
        }
    }
    
    @objc func buttonTapped() {
        if isActive {
            updatedOnPause()
        } else {
            updatedOnStart()
        }
        HapticManager.shared.hapticImpact(style: .light)
        isActive.toggle()
    }
}

// MARK: - Extentions
extension RunActivityVC {
    func makeCircleStView() -> UIStackView {
        let circleDiameter: CGFloat = 88.0
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = circleDiameter / 2.0
        view.clipsToBounds = true
        view.distribution = .equalSpacing
        view.alignment = .center
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        view.isLayoutMarginsRelativeArrangement = true
        view.widthAnchor.constraint(equalToConstant: circleDiameter).isActive = true
        view.heightAnchor.constraint(equalToConstant: circleDiameter).isActive = true
        return view
    }
}

extension RunActivityVC: UserLocationDelegate {
    func userLocationUpated(location: CLLocation) {
        self.runTrackingManager.addPath(withCoordinate: location.coordinate)
    }
    
    func startTracking() {
        self.locationService.userLocationDelegate = self
    }
    
    func stopTracking() {
        self.locationService.userLocationDelegate = nil
    }
}

extension RunActivityVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("can't draw polyline")
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .green
        renderer.lineWidth = 6.0
        renderer.alpha = 1.0
        return renderer
    }
}
