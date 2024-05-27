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
    var runManager: RunTrackingManager? {
        didSet {
            setupUI()
        }
    }
    private var runInfo: [RunInfoModel] = []
    
    private var mapView: MKMapView!
    private lazy var saveButton: UIButton = {
        let bt = MainButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = .mainBlue
        bt.title = "기록저장"
        bt.addTarget(self, action: #selector(goToRoot), for: .touchUpInside)
        return bt
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🏃‍♂️ 종로3가 에서 러닝 - 오후 12:32"
        label.textColor = .gray1
        return label
    }()
    
    private lazy var kmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3.33 KM"
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
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray3
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupMapView()
        setConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Helpers
    func setConstraint() {
        view.addSubview(titleLabel)
        view.addSubview(kmLabel)
        view.addSubview(tableView)
        view.addSubview(detailButton)
        view.addSubview(mapView)
        view.addSubview(saveButton)
        view.addSubview(divider)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            kmLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            kmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: kmLabel.bottomAnchor, constant: 20),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(runInfo.count) * 50),
            
            detailButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            detailButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            mapView.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 20),
            mapView.heightAnchor.constraint(equalToConstant: 250),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(RunInfoCell.self, forCellReuseIdentifier: RunInfoCell.identifier)
    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = false
    }
    
    func setupUI() {
        guard let runModel = runManager?.runModel else { return }
        kmLabel.text = runModel.distance.asString(style: .km) // 킬로미터
        
        // 테이블뷰 설정
        runInfo = [
            RunInfoModel(title: "칼로리", result: "\(runModel.calorie.asString(style: .kcal)) kcal"),
            RunInfoModel(title: "러닝 타임", result: runModel.seconds.toMMSSTimeFormat),
            RunInfoModel(title: "페이스", result: runModel.pace.asString(style: .pace)),
            RunInfoModel(title: "상승고도", result: "+ \(Int(runModel.maxAltitude))m"),
        ]
        tableView.reloadData()
    }
    
    // MARK: - objc
    @objc func goToDetailVC() {
        let detailVC = RunInfoDetailVC()
        detailVC.modalPresentationStyle = .fullScreen
        detailVC.runModel = runManager?.runModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc func goToRoot() {
        view.window!.rootViewController?.dismiss(animated: true)
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
