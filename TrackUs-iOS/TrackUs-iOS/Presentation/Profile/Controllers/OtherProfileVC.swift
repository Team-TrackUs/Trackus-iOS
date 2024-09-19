//
//  OtherProfileVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/21/24.
//

import UIKit
import Firebase

class OtherProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userId: String
    private var blockedUserList = [String]() // 내가 상대방
    private var blockingMeList = [String]() // 상대방이 나
    
    private var user: User?

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
    
    private let privateProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "privateLock_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let privateProfileLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .gray1
        label.text = "프로필 비공개 유저입니다."
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let privateProfileLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .gray2
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "비공개 유저의 러닝 기록은 열람할 수 없습니다."
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
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - 나의 러닝 정보
    private let runningTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "너의 러닝"
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
    private var userRecordsCollection: CollectionReference {
        return Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("records")
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

    private func createRunningInfoText(header: String, main: String, sub: String, todayCount: Int, maxPace: Double? = nil, todayPace: Double? = nil) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: "\(header)\n", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        text.append(NSAttributedString(string: "\(main)\n", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]))
        
        if header == "페이스", let maxPace = maxPace, let todayPace = todayPace, todayCount != 0 {
            let imageAttachment = NSTextAttachment()
            if todayPace > maxPace {
                imageAttachment.image = UIImage(named: "profilePlus_icon")
            } else {
                imageAttachment.image = UIImage(named: "profileMinus_icon")
            }
            let imageString = NSMutableAttributedString(attachment: imageAttachment)
            imageString.append(NSAttributedString(string: " \(sub)", attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular)]))
            text.append(imageString)
        } else if todayCount != 0 {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: "profilePlus_icon")
            let imageString = NSMutableAttributedString(attachment: imageAttachment)
            imageString.append(NSAttributedString(string: " \(sub)", attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular)]))
            text.append(imageString)
        } else {
            text.append(NSAttributedString(string: sub, attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular)]))
        }
        
        return text
    }


    private lazy var distanceLabel: UILabel = {
        let text = createRunningInfoText(header: "러닝 거리(km)", main: "12.7", sub: "0.0" ,todayCount: 0)
        return createLabel(withText: text)
    }()

    private lazy var timeLabel: UILabel = {
        let text = createRunningInfoText(header: "시간", main: "00:00:00", sub: "00:00:00",todayCount: 0)
        return createLabel(withText: text)
    }()

    private lazy var countLabel: UILabel = {
        let text = createRunningInfoText(header: "러닝 횟수", main: "11", sub: "0",todayCount: 0)
        return createLabel(withText: text)
    }()

    private lazy var paceLabel: UILabel = {
        let text = createRunningInfoText(header: "페이스", main: "0'00''", sub: "0'00''",todayCount: 0)
        return createLabel(withText: text)
    }()
    
    private func fetchRunningStats(userId: String) {
        let userRecordsCollection = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("records")

        let today = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)

        userRecordsCollection.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching running stats: \(error)")
                return
            }

            var totalDistance = 0.0
            var totalTime = 0.0
            var totalCount = 0
            var totalPace = 0.0

            var todayDistance = 0.0
            var todayTime = 0.0
            var todayCount = 0
            var todayPace = 0.0
            
            var maxPace = 0.0

            if let snapshot = querySnapshot {
                snapshot.documents.forEach { document in
                    let data = document.data()
                    let distance = data["distance"] as? Double ?? 0.0
                    let time = data["seconds"] as? Double ?? 0.0
                    let pace = data["pace"] as? Double ?? 0.0
                    let timestamp = data["createdAt"] as? Timestamp ?? Timestamp()
                    let recordDate = calendar.startOfDay(for: timestamp.dateValue())

                    totalDistance += distance
                    totalTime += time
                    totalPace += pace
                    totalCount += 1

                    if calendar.isDate(recordDate, inSameDayAs: startOfDay) {
                        todayDistance += distance
                        todayTime += time
                        todayPace += pace
                        todayCount += 1
                    }
                    if pace > maxPace {
                        maxPace = pace
                    }
                }
            }

            DispatchQueue.main.async {
                self.distanceLabel.attributedText = self.createRunningInfoText(
                    header: "러닝 거리(km)",
                    main: totalDistance.asString(style: .km),
                    sub: todayDistance.asString(style: .km),
                    todayCount: todayCount
                )
                self.timeLabel.attributedText = self.createRunningInfoText(
                    header: "시간",
                    main: totalTime.toMMSSTimeFormat,
                    sub: todayTime.toMMSSTimeFormat,
                    todayCount: todayCount
                )
                self.countLabel.attributedText = self.createRunningInfoText(
                    header: "러닝 횟수",
                    main: "\(totalCount)",
                    sub: "\(todayCount)",
                    todayCount: todayCount
                )
                
                let averageTotalPace = totalCount != 0 ? Double(totalPace) / Double(totalCount) : 0.0
                let averageTodayPace = todayTime != 0 ? Double(todayPace) / Double(todayCount) : 0.0
                self.paceLabel.attributedText = self.createRunningInfoText(
                    header: "페이스",
                    main: averageTotalPace.asString(style: .pace),
                    sub: averageTodayPace.asString(style: .pace),
                    todayCount: todayCount,
                    maxPace: maxPace,
                    todayPace: averageTodayPace
                )
            }
        }
    }


    private func formatTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "00:00:00"
    }

    private let recordsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let recordService = RecordService.shared
    private var listener: ListenerRegistration?
    private var records: [Running] = []
    private lazy var recordsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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

    private var currentDate: Date = Date() {
        didSet {
            updateDateButton()
            fetchRecords()
        }
    }

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
        setupTableView()
        setupConstraints()
        fetchUserProfile(userId: userId)
        fetchRunningStats(userId: userId)
        checkIfUserIsBlocked()
        fetchRecords()
    }
    
    private func setupTableView() {
        recordsView.addSubview(recordsTableView)
        recordsTableView.delegate = self
        recordsTableView.dataSource = self
        recordsTableView.register(ProfileRecordsCell.self, forCellReuseIdentifier: ProfileRecordsCell.identifier)

        
        NSLayoutConstraint.activate([
            recordsTableView.topAnchor.constraint(equalTo: recordsView.topAnchor),
            recordsTableView.leadingAnchor.constraint(equalTo: recordsView.leadingAnchor),
            recordsTableView.trailingAnchor.constraint(equalTo: recordsView.trailingAnchor),
            recordsTableView.bottomAnchor.constraint(equalTo: recordsView.bottomAnchor)
        ])
        
        recordsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableViewDataSource
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recordsTableView {
            return records.count
        }
        return 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recordsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileRecordsCell.identifier, for: indexPath) as! ProfileRecordsCell
            
            let record = records[indexPath.row]
            cell.configure(running: record)
            return cell
        }
        return UITableViewCell()
    }


        
    // MARK: - UITableViewDelegate
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        
        let runningResultVC = RunningResultVC()
        runningResultVC.runModel = record
        runningResultVC.setSaveButtonHidden(true)
        runningResultVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(runningResultVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fetchRecords() {
        let db = Firestore.firestore()
        let startTimeField = "startTime"
        
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("users").document(userId).collection("records")
            .whereField(startTimeField, isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField(startTimeField, isLessThan: Timestamp(date: endOfDay))
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.records = querySnapshot?.documents.compactMap { document in
                        do {
                            let record = try document.data(as: Running.self)
                            return record
                        } catch {
                            print("Error decoding record: \(error)")
                            return nil
                        }
                    } ?? []
                    
                    DispatchQueue.main.async {
                        self.recordsTableView.reloadData()
                    }
                }
            }
    }


    private func setupNavBar() {
        self.navigationItem.title = "프로필보기"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton

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
        view.addSubview(privateProfileImageView)
        view.addSubview(privateProfileLabel)
        view.addSubview(privateProfileLabel2)
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
        recordsView.addSubview(recordsTableView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 23),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9),
            
            privateProfileImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 236),
            privateProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            privateProfileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 387),
            privateProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            privateProfileLabel2.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 424),
            privateProfileLabel2.centerXAnchor.constraint(equalTo: view.centerXAnchor),

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
            
        ])
    }
    // MARK: - 설정뷰로 이동
    @objc private func dotsButtonButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockActionTitle = blockedUserList.contains(userId) ? "차단 해제" : "차단하기"
        let blockAction = UIAlertAction(title: blockActionTitle, style: .destructive) { _ in
            if self.blockedUserList.contains(self.userId) {
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
        ChatManager.shared.joinChatRoom(opponentUid: userId) { chat, newChat in
            
            let chatRoomVC = ChatRoomVC(chat: chat, newChat: newChat)
            self.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }
    
    private func fetchUserProfile(userId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            if let isProfilePublic = data?["isProfilePublic"] as? Bool, !isProfilePublic {
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                    if let userName = data?["name"] as? String {
                        self.nameLabel.text = userName
                    }
                    self.privateProfileLabel.isHidden = false
                    self.hideNonPublicProfileElements()
                }
            } else {
                DispatchQueue.main.async {
                    self.privateProfileImageView.isHidden = true
                    self.privateProfileLabel.isHidden = true
                    self.privateProfileLabel2.isHidden = true
                    
                    self.profileImageView.loadProfileImage(url: data?["profileImageUrl"] as? String, borderWidth: 5) {}
                    
                    if let userName = data?["name"] as? String {
                        self.nameLabel.text = userName
                        self.runningTitleLabel.text = "\(userName)님의 러닝"
                    }
                }
            }
        }
    }
    // MARK: - 프로필 비공ㄱ개 일 경우 숨김 목록
    private func hideNonPublicProfileElements() {
        DispatchQueue.main.async {
            self.runningTitleLabel.isHidden = true
            self.runningStatsContainerView.isHidden = true
            self.previousDateButton.isHidden = true
            self.dateButton.isHidden = true
            self.nextDateButton.isHidden = true
            self.recordsView.isHidden = true
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
            if let blockedList = data?["blockedUserList"] as? [String], blockedList.contains(self.userId) {
                self.blockedUserList = blockedList
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
        
        let batch = db.batch()
        
        let currentUserRef = db.collection("users").document(currentUserUid)
        batch.updateData(["blockedUserList": FieldValue.arrayRemove([userId])], forDocument: currentUserRef)
        
        let blockedUserRef = db.collection("users").document(userId)
        batch.updateData(["blockingMeList": FieldValue.arrayRemove([currentUserUid])], forDocument: blockedUserRef)
        
        batch.commit { [weak self] error in
            if let error = error {
            } else {
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
        reportUserVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(reportUserVC, animated: true)
        
    }
}

extension OtherProfileVC {
    private func blockUser(userId: String) {
        let db = Firestore.firestore()
        let currentUserUid = UserManager.shared.user.uid
        
        let batch = db.batch()

        let currentUserRef = db.collection("users").document(currentUserUid)
        batch.updateData(["blockedUserList": FieldValue.arrayUnion([userId])], forDocument: currentUserRef)

        let blockedUserRef = db.collection("users").document(userId)
        batch.updateData(["blockingMeList": FieldValue.arrayUnion([currentUserUid])], forDocument: blockedUserRef)
        
        batch.commit { error in
            if let error = error {
            } else {
                self.updateBlockButton(toBlocked: true)
            }
        }
    }
}
