//
//  OtherProfileVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/21/24.
//

import UIKit
import Firebase

class OtherProfileVC: UIViewController {
    var userId: String
    private var blockingMeList = [String]()

    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        
        let imageView = UIImageView(image: UIImage(named: "profileChat_icon"))
        imageView.tintColor = .black
        stackView.addArrangedSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.text = "1:1대화"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .gray2
        stackView.addArrangedSubview(titleLabel)
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.isUserInteractionEnabled = true
        stackView.isUserInteractionEnabled = false
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
        fetchUserProfile(userId: userId)
        checkIfUserIsBlocked()
    }

    private func setupNavBar() {
        self.navigationItem.title = "프로필보기"
        
        let dotsButton = UIBarButtonItem(image: UIImage(named: "dots_icon"), style: .plain, target: self, action: #selector(dotsButtonButtonTapped))
        dotsButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = dotsButton
        
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
    @objc private func dotsButtonButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockActionTitle = blockingMeList.contains(userId) ? "차단 해제" : "차단하기"
        let blockAction = UIAlertAction(title: blockActionTitle, style: .destructive) { _ in
            if self.blockingMeList.contains(self.userId) {
                self.unblockUserTapped()
            } else {
                self.blockUser(userId: self.userId)
            }
        }
        let reportAction = UIAlertAction(title: "신고하기", style: .destructive) { _ in
            self.reportUser()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(blockAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - 채팅뷰로 이동
    @objc private func editProfileButtonTapped() {
        let myProfileEditVC = ChatListVC()
        self.navigationController?.pushViewController(myProfileEditVC, animated: true)
    }
    
    private func fetchUserProfile(userId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
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
    
    
    // MARK: - 차단된 사용자 확인
    private func checkIfUserIsBlocked() {
        let db = Firestore.firestore()
        let currentUserUid = UserManager.shared.user.uid
        
        db.collection("users").document(currentUserUid).getDocument { [weak self] document, error in
            guard let self = self, let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            if let blockingList = data?["blockingMeList"] as? [String], blockingList.contains(self.userId) {
                self.blockingMeList = blockingList
                self.updateBlockButton(toBlocked: true)
            } else {
                self.updateBlockButton(toBlocked: false)
            }
        }
    }
    
    // MARK: - 차단 버튼 업데이트
    private func updateBlockButton(toBlocked: Bool) {
        let stackView = editProfileButton.subviews.first as? UIStackView
        let imageView = stackView?.arrangedSubviews.first as? UIImageView
        let titleLabel = stackView?.arrangedSubviews.last as? UILabel
        
        if toBlocked {
            imageView?.image = UIImage(named: "profileblock_icon")
            titleLabel?.text = "차단 해제"
            editProfileButton.removeTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
            editProfileButton.addTarget(self, action: #selector(unblockUserTapped), for: .touchUpInside)
        } else {
            imageView?.image = UIImage(named: "profileChat_icon")
            titleLabel?.text = "1:1대화"
            editProfileButton.removeTarget(self, action: #selector(unblockUserTapped), for: .touchUpInside)
            editProfileButton.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        }
    }
        
   // MARK: - 차단 해제
    @objc private func unblockUserTapped() {
        let db = Firestore.firestore()
        let currentUserUid = UserManager.shared.user.uid
        
        db.collection("users").document(currentUserUid).updateData([
            "blockingMeList": FieldValue.arrayRemove([userId])
        ]) { [weak self] error in
            if let error = error {
                print("차단 해제하는 동안 오류 발생: \(error)")
            } else {
                print("사용자가 성공적으로 차단 해제됨")
                self?.updateBlockButton(toBlocked: false)
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
    
    private func reportUser() {
        let reportUserVC = ReportUserVC(userId: self.userId)
        navigationController?.pushViewController(reportUserVC, animated: true)
    }
}

extension OtherProfileVC {
    private func blockUser(userId: String) {
        let db = Firestore.firestore()
        let currentUserUid = UserManager.shared.user.uid
        
        db.collection("users").document(currentUserUid).updateData([
            "blockingMeList": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("차단하는 동안 오류 발생: \(error)")
            } else {
                print("사용자가 성공적으로 차단됨")
                self.updateBlockButton(toBlocked: true)
            }
        }
    }
}

