//
//  RunInfoDetailVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/27/24.
//

import UIKit

class RunInfoDetailVC: UIViewController {
    // MARK: - Properties
    var runModel: Running? {
        didSet {
            setTableData()
        }
    }
    private var runInfo: [RunInfoModel] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2024.05.27 오후 러닝"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "12:32 - 13:22"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.isScrollEnabled = false
        return tb
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setTableView()
        setConstraint()
    }
    
    // MARK: - Helpers
    func setTableView() {
        tableView.dataSource = self
        tableView.register(RunInfoCell.self, forCellReuseIdentifier: RunInfoCell.identifier)
    }
    
    func setConstraint() {
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            tableView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setTableData() {
        guard let runModel = runModel else { return }
        runInfo = [
            RunInfoModel(title: "시간", result: runModel.seconds.toMMSSTimeFormat),
            RunInfoModel(title: "거리(킬로미터)", result: runModel.distance.asString(style: .km)),
            RunInfoModel(title: "칼로리", result: runModel.calorie.asString(style: .kcal) + " kcal"),
            RunInfoModel(title: "페이스(분)", result: runModel.pace.asString(style: .pace)),
            RunInfoModel(title: "고도(상승)", result: "+ \(Int(runModel.maxAltitude))" + "m"),
            RunInfoModel(title: "고도(하강)", result: " \(Int(runModel.minAltitude))" + "m"),
            RunInfoModel(title: "케이던스", result: "\(runModel.cadance)"),
        ]
        tableView.reloadData()
    }
}

extension RunInfoDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RunInfoCell.identifier, for: indexPath) as? RunInfoCell else { return UITableViewCell()
        }
        cell.runInfo = runInfo[indexPath.row]
        return cell
    }
    
    
}
