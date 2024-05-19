//
//  RunningMateVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit

class RunningMateVC: UIViewController {
    
    // MARK: - Properties
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = true
        tableView.register(MateViewCell.self, forCellReuseIdentifier: MateViewCell.identifier)
        return tableView
    }()
    
    private lazy var moveButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "plus_icon"), for: .normal)
        btn.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 40 / 2
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.gray2.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withTintColor(.gray2, renderingMode: .alwaysOriginal))
    
    let searchLabel: UILabel = {
        let label = UILabel()
        label.text = "검색어를 입력해주세요"
        label.textColor = UIColor.gray2
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Selectors
    
    @objc func moveButtonTapped() {
        let mateDetailVC = CourseRegisterVC()
        mateDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(mateDetailVC, animated: true)
        
    }
    
    @objc func searchButtonTapped() {
        print("DEBUG: 검색 버튼 클릭")
        let searchVC = SearchVC()
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        self.view.addSubview(searchButton)
        searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        searchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        searchButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        searchButton.addSubview(searchIcon)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
//        searchIcon.topAnchor.constraint(equalTo: searchButton.topAnchor, constant: 8).isActive = true
        searchIcon.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor).isActive = true
        searchIcon.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor, constant: -16).isActive = true
        
        searchButton.addSubview(searchLabel)
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor).isActive = true
        searchLabel.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: 16).isActive = true
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.view.addSubview(moveButton)
        moveButton.bottomAnchor.constraint(equalTo: tableView.bottomAnchor,constant: -17).isActive = true
        moveButton.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -16).isActive = true
        moveButton.widthAnchor.constraint(equalToConstant: 52).isActive = true
        moveButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "메이트 모집"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
}

extension RunningMateVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MateViewCell.identifier, for: indexPath) as? MateViewCell else {
            fatalError("The tableView could not dequeue a MateViewCell in ViewController")
        }
        
        cell.configure(image: UIImage(named: "profile_img") ?? UIImage(imageLiteralResourceName: "profile_img"), runningStyleLabel: "인터벌", titleLabel: "광명시 러닝 메이트 구합니다", locationLabel: "서울숲카페거리", timeLabel: "10:01 AM", distanceLabel: "1.54km", peopleLimit: 5, peopleIn: 2, dateLabel: "2024년 5월 18일")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courseDetailVC = CourseDetailVC()
        courseDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(courseDetailVC, animated: true)
    }
}
