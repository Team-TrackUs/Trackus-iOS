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
// TODO: - 이동경로가 전부 보이도록 zoom level 설정


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
    
    private lazy var slideBox: UIView = {
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
    
    private let kilometerLabel: UILabel = {
        let label = UILabel()
        label.text = "0.00 km"
        label.font = UIFont.italicSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 14, trailing: 14)
        sv.isLayoutMarginsRelativeArrangement = true // margin 적용
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        sv.layer.cornerRadius = 15
        
        let label = UILabel()
        label.text = "🏃‍♂️ 현재까지 거리"
        
        sv.backgroundColor = .white
        sv.isHidden = true
        
        [label, kilometerLabel].forEach {sv.addArrangedSubview($0)}
        
        return sv
    }()
    
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        return label
    }()
    
    private let paceLabel: UILabel = {
        let label = UILabel()
        label.text = "-'--''"
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        return label
    }()
    
    private let altitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        return label
    }()
    
    private let cadenceLabel: UILabel = {
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
        calorieImage.image = UIImage(resource: .caloriesIcon)
        calorieImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        calorieImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let calorieInfoLabel = UILabel()
        calorieInfoLabel.text = "소모 칼로리"
        calorieInfoLabel.font = UIFont.systemFont(ofSize: 12)
        [calorieImage, calorieInfoLabel, calorieLabel].forEach {calorieStackVIew.addArrangedSubview($0)}
        
        let paceStackVIew = makeCircleStView()
        let paceImage = UIImageView()
        paceImage.image = UIImage(resource: .pulseIcon)
        paceImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        paceImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let paceInfoLabel = UILabel()
        paceInfoLabel.font = UIFont.systemFont(ofSize: 12)
        paceInfoLabel.text = "페이스"
        [paceImage, paceInfoLabel, paceLabel].forEach {paceStackVIew.addArrangedSubview($0)}
        
        let timeStackVIew = makeCircleStView()
        let timeImage = UIImageView()
        timeImage.image = UIImage(resource: .stopwatchIcon)
        timeImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        timeImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let timeInfoLabel = UILabel()
        
        timeInfoLabel.text = "경과 시간"
        timeInfoLabel.font = UIFont.systemFont(ofSize: 12)
        [timeImage, timeInfoLabel, timeLabel].forEach {timeStackVIew.addArrangedSubview($0)}
        
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
        
        let altitudeInfoLabel = UILabel()
        altitudeInfoLabel.font = UIFont.systemFont(ofSize: 12)
        altitudeInfoLabel.text = "고도"
        [altitudeImage, altitudeInfoLabel, altitudeLabel].forEach {altitudeStackView.addArrangedSubview($0)}
        
        let cadanceStackVIew = makeCircleStView()
        let cadanceImage = UIImageView()
        cadanceImage.image = UIImage(resource: .footprintIcon)
        let cadanceInfoLabel = UILabel()
        
        cadanceInfoLabel.text = "케이던스"
        cadanceInfoLabel.font = UIFont.systemFont(ofSize: 12)
        
        [cadanceImage, cadanceInfoLabel, cadenceLabel].forEach {cadanceStackVIew.addArrangedSubview($0)}
        
        [UIView(), altitudeStackView, UIView(), cadanceStackVIew, UIView()].forEach { sv.addArrangedSubview($0) }
        sv.isHidden = true
        return sv
    }()
    
    private let blurView: UIView = {
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
    
    // MARK: - Helpers
    func setConstraint() {
        self.view.addSubview(overlayView)
        self.view.addSubview(blurView)
        self.view.addSubview(slideBox)
        self.view.addSubview(topStackView)
        self.view.addSubview(runInfoStackView)
        self.view.addSubview(runInfoStackView2)
        
        NSLayoutConstraint.activate([
            slideBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            slideBox.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            slideBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            slideBox.heightAnchor.constraint(equalToConstant: 70),
            
            actionButton.leadingAnchor.constraint(equalTo: slideBox.leadingAnchor, constant: 10),
            actionButton.topAnchor.constraint(equalTo: slideBox.topAnchor, constant: 10),
            actionButton.bottomAnchor.constraint(equalTo: slideBox.bottomAnchor, constant: -10),
            
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
            blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
         
        ])
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.frame)
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        self.view.addSubview(mapView)
    }
    
    func setMapRegion(animated: Bool = true) {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    // latitudinalMeters 남북범위
    // longitudinalMeters 동서범위
    func setMapRange(center: CLLocationCoordinate2D, animated: Bool = true) {
        let range = runTrackingManager.coordinates.totalDistance + 1000
        let region = MKCoordinateRegion(center: center, latitudinalMeters: CLLocationDistance(floatLiteral: range), longitudinalMeters: range)
        mapView.setRegion(region, animated: animated)
    }
    
    func updatedOnStart() {
        startTracking()
        startTimer()
        setCameraOnTrackingMode()
        setStartModeUI()
    }
    
    func updatedOnPause() {
        stopTracking()
        stopTimer()
        setCameraOnPauseMode()
        setPauseModeUI()
    }
    
    func setStartModeUI() {
        overlayView.isHidden = true
        slideBox.isHidden = false
        topStackView.isHidden = false
        runInfoStackView.isHidden = false
        blurView.isHidden = true
        runInfoStackView2.isHidden = true
        actionButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        UIView.animate(withDuration: 0.2) {
            self.topStackView.axis = .horizontal
            self.topStackView.spacing = 0
            self.kilometerLabel.font = UIFont.italicSystemFont(ofSize: 24)
        }
    }
    
    func setPauseModeUI() {
        actionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        blurView.isHidden = false
        runInfoStackView2.isHidden = false
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
        HapticManager.shared.hapticImpact(style: .medium)
        let resultVC = RunningResultVC()
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    }
    
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
            runTrackingManager.seconds += 1
            timeLabel.text = runTrackingManager.seconds.toMMSSTimeFormat
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func setCameraOnPauseMode() {
        setMapPreview()
        drawPath()
    }
    
    func setCameraOnTrackingMode() {
        setMapRegion()
        removePath()
    }
    
    func drawPath() {
        let coordinates = self.runTrackingManager.coordinates
        annotation = MKPointAnnotation()
        polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        guard coordinates.count >= 1, let annotation = annotation else { return }
        annotation.coordinate = coordinates.first!
        mapView.addAnnotation(annotation)
        
        guard coordinates.count >= 2, let polyline = polyline else { return }
        mapView.addOverlay(polyline)
    }
    
    func removePath() {
        guard let polyline = polyline, let annotation = annotation else { return }
        mapView.removeOverlay(polyline)
        mapView.removeAnnotation(annotation)
    }
    
    func setMapPreview() {
        if let center = runTrackingManager.coordinates.centerPosition, runTrackingManager.coordinates.count >= 2 {
            setMapRange(center: center, animated: false)
        } else {
            setMapRegion(animated: false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: runInfoStackView2.frame.maxY, left: 20, bottom: 20, right: 20), animated: false)
        }
    }
    
    // MARK: - objc Methods
    @objc func pangestureHandler(sender: UIPanGestureRecognizer) {
        let minX = actionButton.bounds.width / 2 + 10
        let translation = sender.translation(in: actionButton)
        
        let newX = actionButton.center.x + translation.x
        let maxX = slideBox.bounds.maxX - CGFloat(35)
        actionButton.center.x = max(minX, min(newX, maxX))
        sender.setTranslation(CGPoint.zero, in: actionButton)
        
        if sender.state == .ended && newX > maxX * 0.9 {
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
        runTrackingManager.coordinates.append(location.coordinate)
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func startTracking() {
        locationService.userLocationDelegate = self
        // 움직임이 감지될때마다 호출되는 핸들러
        runTrackingManager.updateRunInfo { [weak self] runningModel in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                kilometerLabel.text = runningModel.distance.asString(style: .km)
                paceLabel.text = runningModel.pace.asString(style: .pace)
                calorieLabel.text = runningModel.calorie.asString(style: .kcal)
                cadenceLabel.text = String(runningModel.cadance)
                guard Int(runningModel.maxAltitude) >= 1 else {
                    return
                }
                altitudeLabel.text = "+ \(Int(runningModel.maxAltitude))m"
            }
        }
    }
    
    func stopTracking() {
        self.locationService.userLocationDelegate = nil
        runTrackingManager.stopRecord()
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
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        return renderer
    }
}
