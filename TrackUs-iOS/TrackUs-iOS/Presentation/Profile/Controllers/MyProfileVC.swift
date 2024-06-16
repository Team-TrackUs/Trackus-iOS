//
//  MyProfileVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import Firebase

class MyProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

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

    private func createRunningInfoText(header: String, main: String, sub: String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: "\(header)\n", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        text.append(NSAttributedString(string: "\(main)\n", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]))
        text.append(NSAttributedString(string: sub, attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular)]))
        return text
    }

    private lazy var distanceLabel: UILabel = {
        let text = createRunningInfoText(header: "러닝 거리(km)", main: "12.7", sub: "0.0")
        return createLabel(withText: text)
    }()

    private lazy var timeLabel: UILabel = {
        let text = createRunningInfoText(header: "시간", main: "00:00:00", sub: "00:00:00")
        return createLabel(withText: text)
    }()

    private lazy var countLabel: UILabel = {
        let text = createRunningInfoText(header: "러닝 횟수", main: "11", sub: "0")
        return createLabel(withText: text)
    }()

    private lazy var paceLabel: UILabel = {
        let text = createRunningInfoText(header: "페이스", main: "0'00''", sub: "0'00''")
        return createLabel(withText: text)
    }()
    
    
    private func fetchRunningStats() {
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
            
            var latestDistance = 0.0
            var latestTime = 0.0
            var latestCount = 0
            var latestPace = 0.0
            
            var previousDistance = 0.0
            var previousTime = 0.0
            var previousCount = 0
            var previousPace = 0.0
            
            if let snapshot = querySnapshot {
                var latestRecord: QueryDocumentSnapshot?
                snapshot.documents.forEach { document in
                    let data = document.data()
                    let distance = data["distance"] as? Double ?? 0.0
                    let time = data["seconds"] as? Double ?? 0.0
                    let pace = data["pace"] as? Double ?? 0.0
                    
                    totalDistance += distance
                    totalTime += time
                    totalCount += 1
                    totalPace += pace
                    
                    if latestRecord == nil {
                        latestRecord = document
                        latestDistance = distance
                        latestTime = time
                        latestCount = 1
                        latestPace = pace
                    } else {
                        let documentTimestamp = document["timestamp"] as? Timestamp ?? Timestamp()
                        let latestTimestamp = latestRecord?["timestamp"] as? Timestamp ?? Timestamp()
                        if documentTimestamp.seconds > latestTimestamp.seconds {
                            latestRecord = document
                            previousDistance = latestDistance
                            previousTime = latestTime
                            previousCount = latestCount
                            previousPace = latestPace
                            
                            latestDistance = distance
                            latestTime = time
                            latestCount = 1
                            latestPace = pace
                        } else {
                            previousDistance = distance
                            previousTime = time
                            previousCount = 1
                            previousPace = pace
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.distanceLabel.attributedText = self.createRunningInfoText(header: "러닝 거리(km)", main: String(format: "%.1f", totalDistance), sub: String(format: "%.1f", latestDistance - previousDistance))
                self.timeLabel.attributedText = self.createRunningInfoText(header: "시간", main: self.formatTime(totalTime), sub: self.formatTime(latestTime - previousTime))
                self.countLabel.attributedText = self.createRunningInfoText(header: "러닝 횟수", main: "\(totalCount)", sub: "1")
                self.paceLabel.attributedText = self.createRunningInfoText(header: "페이스", main: self.formatPace(totalPace), sub: self.formatPace(latestPace - previousPace))
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

    private func formatPace(_ secondsPerKm: Double) -> String {
        let minutes = Int(secondsPerKm / 60)
        let seconds = Int(secondsPerKm.truncatingRemainder(dividingBy: 60))
        return String(format: "%d'%02d''", minutes, seconds)
    }

    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["기록", "글 목록"])
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segment
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
    
    private var posts: [Post] = []
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
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
            fetchPosts()
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
        setupConstraints()
        fetchUserProfile()
        setupTableView()
        fetchPosts()
        fetchRunningStats()
    }
    
    private func setupTableView() {
        postsView.addSubview(tableView)
        tableView.register(MateViewCell.self, forCellReuseIdentifier: MateViewCell.identifier)

        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: postsView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: postsView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: postsView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: postsView.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableViewDataSource
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MateViewCell.identifier, for: indexPath) as! MateViewCell

        let post = posts[indexPath.row]
        cell.configure(post: post)
        return cell
    }
        
    // MARK: - UITableViewDelegate
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func fetchPosts() {
        let db = Firestore.firestore()
        
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("posts")
            .whereField("startDate", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("startDate", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.posts = querySnapshot?.documents.compactMap { document in
                        do {
                            let post = try document.data(as: Post.self)
                            return post
                        } catch {
                            print("Error decoding post: \(error)")
                            return nil
                        }
                    } ?? []
                    
                    self.posts = self.posts.filter { self.shouldIncludePost($0) }

                    self.tableView.reloadData()
                }
            }
    }

    private func shouldIncludePost(_ post: Post) -> Bool {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return false
        }

        if post.members.contains(currentUserUID) || post.ownerUid == currentUserUID {
            return true
        } else {
            return false
        }
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
        
        view.addSubview(segmentControl)
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
            
            
            segmentControl.topAnchor.constraint(equalTo: runningStatsContainerView.bottomAnchor, constant: 22),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            previousDateButton.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),
            previousDateButton.trailingAnchor.constraint(equalTo: dateButton.leadingAnchor, constant: -10),
            
            dateButton.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 27),
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
        myProfileEditVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myProfileEditVC, animated: true)
    }
    
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        UserManager.shared.checkUserData(uid: currentUser.uid) { [weak self] exists in
            guard let self = self else { return }
            if exists {
                let user = UserManager.shared.user
                if let profileImageUrl = user.profileImageUrl {
                    self.profileImageView.loadImage(url: profileImageUrl)
                } else {
                    self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                }
                
                self.nameLabel.text = user.name
            } else {
                self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                self.nameLabel.text = "No Name"
            }
        }
    }
    
    @objc private func segmentChanged() {
        if segmentControl.selectedSegmentIndex == 0 {
            recordsView.isHidden = false
            postsView.isHidden = true
        } else {
            recordsView.isHidden = true
            postsView.isHidden = false
            tableView.reloadData()
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
    // MARK: - 최신 정보 유지
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
    }
}
