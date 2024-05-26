//
//  SearchVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/20/24.
//

import UIKit

class SearchVC: UIViewController {
    
    // MARK: - Properties
    
    private lazy var searchBar: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.backgroundColor = .white
        textField.frame = CGRect(x: 0, y: 0, width: 300, height: 48)
        textField.inputAccessoryView = toolBarKeyboard
        return textField
    }()
    
    private lazy var toolBarKeyboard: UIToolbar = {
        let toolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "검색", style: .done, target: self, action: #selector(btnDoneBarTapped))
        toolbar.sizeToFit()
        toolbar.items = [flexBarButton, doneButton]
        toolbar.tintColor = .mainBlue
        return toolbar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = true
        tableView.register(MateViewCell.self, forCellReuseIdentifier: MateViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Selectors
    
    @objc func btnDoneBarTapped(sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "검색"
        self.navigationItem.titleView = searchBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MateViewCell.identifier, for: indexPath) as? MateViewCell else {
            fatalError("The tableView could not dequeue a MateViewCell in ViewController")
        }
        
        cell.configure(image: "gs://newtrackus.appspot.com/posts_image/5CDF87FE-DB10-4640-B82E-8BA587445E7D1716663607.288651", runningStyleLabel: "인터벌", titleLabel: "광명시 러닝 메이트 구합니다", locationLabel: "서울숲카페거리", timeLabel: "10:01 AM", distanceLabel: "1.54km", peopleLimit: 5, peopleIn: 2, dateLabel: "2024년 5월 18일")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courseDetailVC = CourseDetailVC()
        courseDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(courseDetailVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
