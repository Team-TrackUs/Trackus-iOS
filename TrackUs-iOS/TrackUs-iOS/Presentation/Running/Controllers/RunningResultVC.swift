//
//  RunningResultVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit
import MapKit
class RunningResultVC: UIViewController {
    // MARK: - Properties
    private let recordService = RecordService.shared
    var runModel: Running? {
        didSet {
            setupUI()
        }
    }
    private var runInfo: [RunInfoModel] = []
    private var polyline: MKPolyline?
    private var annotation: MKPointAnnotation?
    private var mapView: MKMapView!
    
    private lazy var saveButton: UIButton = {
        let bt = MainButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = .mainBlue
        bt.title = "기록저장"
        bt.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        return bt
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray1
        return label
    }()
    
    private lazy var kmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if let descriptor = UIFont.systemFont(ofSize: 40, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        } else {
            label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        }
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.isScrollEnabled = false
        return tb
    }()
    
    private lazy var detailButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        bt.semanticContentAttribute = .forceRightToLeft
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bt.setTitle("상세보기", for: .normal)
        bt.setTitleColor(.gray1, for: .normal)
        bt.addTarget(self, action: #selector(goToDetailVC), for: .touchUpInside)
        return bt
    }()
    
    private lazy var buttonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.addSubview(saveButton)
        return view
    }()
    
    private lazy var mapDetailBtn: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .gray2
        config.image = UIImage(systemName: "map.fill")
        config.imagePadding = 7
        var titleAttr = AttributedString("지도뷰")
        titleAttr.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        config.attributedTitle = titleAttr
        let bt = UIButton(configuration: config)
        bt.translatesAutoresizingMaskIntoConstraints = false
        
        bt.addTarget(self, action: #selector(goToMapView), for: .touchUpInside)
        return bt
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupMapView()
        setConstraint()
        displayPath()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonContainer.layer.addTopBorder()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    //    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    //    }
    
    // MARK: - Helpers
    func setupNavBar() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "기록"
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: closeButton)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 16).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 16).isActive = true
        navigationItem.leftBarButtonItem = menuBarItem
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func drawPath() {
        guard let runModel = runModel else {
            return
        }
        
        let coordinates = runModel.coordinates
        annotation = MKPointAnnotation()
        polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        guard coordinates.count >= 1, let annotation = annotation else { return }
        annotation.coordinate = coordinates.first!
        mapView.addAnnotation(annotation)
        
        guard coordinates.count >= 2, let polyline = polyline else { return }
        mapView.addOverlay(polyline)
    }
    
    func setConstraint() {
        view.addSubview(titleLabel)
        view.addSubview(kmLabel)
        view.addSubview(tableView)
        view.addSubview(detailButton)
        view.addSubview(mapView)
        view.addSubview(mapDetailBtn)
        view.addSubview(buttonContainer)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            kmLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            kmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: kmLabel.bottomAnchor, constant: 20),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(runInfo.count) * 40),
            
            detailButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            detailButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            mapView.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 20),
            mapView.heightAnchor.constraint(equalToConstant: 250),
            
            mapDetailBtn.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10),
            mapDetailBtn.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: 66),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 10),
        ])
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.register(RunInfoCell.self, forCellReuseIdentifier: RunInfoCell.identifier)
    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = false
        mapView.isUserInteractionEnabled = false
        mapView.layer.cornerRadius = 6
        mapView.delegate = self
    }
    
    func displayPath() {
        if let region = runModel?.coordinates.makeRegionToFit() {
            mapView.setRegion(region, animated: false)
            drawPath()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 20,
                                                                                        left: 20,
                                                                                        bottom: 20,
                                                                                        right: 20), animated: false)
        }
    }
    
    func setupUI() {
        guard let runModel = runModel else { return }
        kmLabel.text = runModel.distance.asString(style: .km) // 킬로미터
        titleLabel.text = "🏃‍♂️ \(runModel.address) 에서 러닝 - \(runModel.startTime.timeOfDay) \(runModel.startTime.currentTime)"
        // 테이블뷰 설정
        runInfo = [
            RunInfoModel(title: "칼로리", result: "\(runModel.calorie.asString(style: .kcal)) kcal"),
            RunInfoModel(title: "러닝 타임", result: runModel.seconds.toMMSSTimeFormat),
            RunInfoModel(title: "페이스", result: runModel.pace.asString(style: .pace)),
            RunInfoModel(title: "상승고도", result: "+ \(Int(runModel.maxAltitude))m"),
        ]
        tableView.reloadData()
    }
    
    func goToRootView() {
        view.window!.rootViewController?.dismiss(animated: true)
    }
    
    // MARK: - objc
    @objc func goToDetailVC() {
        let detailVC = RunInfoDetailVC()
        detailVC.modalPresentationStyle = .fullScreen
        detailVC.runModel = runModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc func goToMapView() {
        let mapResultVC = MapResultVC()
        mapResultVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(mapResultVC, animated: true)
    }
    
    @objc func uploadButtonTapped() {
        guard let runModel = runModel else { return }
        recordService.uploadRecord(record: runModel) {
            self.goToRootView()
        }
    }
    
    @objc func closeButtonTapped() {
        self.goToRootView()
    }
}

extension RunningResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RunInfoCell.identifier, for: indexPath) as? RunInfoCell else {
            return UITableViewCell()
        }
        cell.runInfo = runInfo[indexPath.row]
        return cell
    }
}

extension CALayer {
    func addTopBorder() {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: frame.width, height: 1)
        border.backgroundColor = UIColor.gray3.cgColor
        self.addSublayer(border)
    }
}

extension RunningResultVC: MKMapViewDelegate {
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
