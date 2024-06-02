//
//  OtherProfileVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/21/24.
//

import UIKit
import Firebase

class OtherProfileVC: UIViewController {

    // MARK: - 사용자 프로필
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 편집", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray3
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - 나의 러닝 정보
    private let runningTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 러닝"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runningStatsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let runningStatsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func createRunningInfoView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray3.cgColor
        view.layer.shadowColor = UIColor.gray2.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private lazy var distanceView: UIView = createRunningInfoView()
    private lazy var timeView: UIView = createRunningInfoView()
    private lazy var countView: UIView = createRunningInfoView()
    private lazy var paceView: UIView = createRunningInfoView()

    
    private func createLabel(withText text: NSMutableAttributedString) -> UILabel {
        let label = UILabel()
        label.attributedText = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createRunningInfoText(header: String, main: String, sub: String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: "\(header)\n", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        text.append(NSAttributedString(string: "\(main)\n", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]))
        text.append(NSAttributedString(string: sub, attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular)]))
        return text
    }

    private lazy var distanceLabel: UILabel = {
        let text = createRunningInfoText(header: "러닝 거리(km)", main: "12.7", sub: "2.8")
        return createLabel(withText: text)
    }()

    private lazy var timeLabel: UILabel = {
        let text = createRunningInfoText(header: "시간", main: "00:00:00", sub: "2.8")
        return createLabel(withText: text)
    }()

    private lazy var countLabel: UILabel = {
        let text = createRunningInfoText(header: "러닝 횟수", main: "11", sub: "1")
        return createLabel(withText: text)
    }()

    private lazy var paceLabel: UILabel = {
        let text = createRunningInfoText(header: "페이스", main: "0'00''", sub: "2'08''")
        return createLabel(withText: text)
    }()

    private let recordsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let postsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - 날짜 표시
    private let dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    }()

    private var currentDate: Date = Date()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    private func updateDateButton() {
        dateButton.setTitle("\(dateFormatter.string(from: currentDate))", for: .normal)
    }

    @objc private func dateButtonTapped() {
        let calendarVC = CalendarVC()
        if #available(iOS 13.0, *) {
            calendarVC.modalPresentationStyle = .pageSheet
        }
        calendarVC.didSelectDate = { [weak self] selectedDate in
            self?.currentDate = selectedDate
            self?.updateDateButton()
        }
        present(calendarVC, animated: true, completion: nil)
    }
    
    private let previousDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("<", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(previousDateButtonTapped), for: .touchUpInside)
        return button
    }()
        
    private let nextDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(">", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextDateButtonTapped), for: .touchUpInside)
        return button
    }()
        
    @objc private func previousDateButtonTapped() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        updateDateButton()
    }
        
    @objc private func nextDateButtonTapped() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        updateDateButton()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        view.backgroundColor = .white
        setupViews()
        currentDate = Date()
        updateDateButton()
        profileImageView.layer.cornerRadius = 35
        setupConstraints()
        fetchUserProfile()
    }

    private func setupNavBar() {
        self.navigationItem.title = "마이페이지"
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "setting_icon"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        settingsButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = settingsButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(editProfileButton)
        view.addSubview(runningTitleLabel)
        view.addSubview(runningStatsContainerView)
        
        [distanceView, timeView, countView, paceView].forEach { view in
            view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }
        
        distanceView.addSubview(distanceLabel)
        timeView.addSubview(timeLabel)
        countView.addSubview(countLabel)
        paceView.addSubview(paceLabel)
        
        view.addSubview(previousDateButton)
        view.addSubview(dateButton)
        view.addSubview(nextDateButton)
        
        let horizontalStackView1: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        let horizontalStackView2: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        horizontalStackView1.addArrangedSubview(distanceView)
        horizontalStackView1.addArrangedSubview(timeView)
        
        horizontalStackView2.addArrangedSubview(countView)
        horizontalStackView2.addArrangedSubview(paceView)
        
        runningStatsView.addArrangedSubview(horizontalStackView1)
        runningStatsView.addArrangedSubview(horizontalStackView2)
        
        runningStatsContainerView.addSubview(runningStatsView)

        view.addSubview(recordsView)
        view.addSubview(postsView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 23),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9),
            
            editProfileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            editProfileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            editProfileButton.widthAnchor.constraint(equalToConstant: 80),
            editProfileButton.heightAnchor.constraint(equalToConstant: 30),
            
            runningTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 42),
            runningTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            runningStatsContainerView.topAnchor.constraint(equalTo: runningTitleLabel.bottomAnchor, constant: 8),
            runningStatsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            runningStatsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            runningStatsView.topAnchor.constraint(equalTo: runningStatsContainerView.topAnchor, constant: 22),
            runningStatsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            runningStatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            runningStatsView.bottomAnchor.constraint(equalTo: runningStatsContainerView.bottomAnchor, constant: -22),
            
            
            previousDateButton.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),
            previousDateButton.trailingAnchor.constraint(equalTo: dateButton.leadingAnchor, constant: -10),
            
            dateButton.topAnchor.constraint(equalTo: runningStatsContainerView.bottomAnchor, constant: 25),
            dateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextDateButton.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),
            nextDateButton.leadingAnchor.constraint(equalTo: dateButton.trailingAnchor, constant: 10),
            
            recordsView.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 20),
            recordsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            postsView.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 20),
            postsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // MARK: - 설정뷰로 이동
    @objc private func settingsButtonTapped() {
        let settingVC = SettingVC()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    // MARK: - 프로필편집뷰로 이동
    @objc private func editProfileButtonTapped() {
        let myProfileEditVC = MyProfileEditVC()
        self.navigationController?.pushViewController(myProfileEditVC, animated: true)
    }
    
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("user").document(currentUser.uid)
        
        userRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            if let profileImageUrl = data?["profileImageUrl"] as? String {
                self.profileImageView.loadImage(url: profileImageUrl)
            } else {
                self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            }
            
            if let userName = data?["name"] as? String {
                self.nameLabel.text = userName
            }
        }
    }

    
    private func setupConstraints() {
        let labelsAndViews: [(UILabel, UIView)] = [
            (distanceLabel, distanceView),
            (timeLabel, timeView),
            (countLabel, countView),
            (paceLabel, paceView)
        ]
        
        labelsAndViews.forEach { label, view in
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
}
