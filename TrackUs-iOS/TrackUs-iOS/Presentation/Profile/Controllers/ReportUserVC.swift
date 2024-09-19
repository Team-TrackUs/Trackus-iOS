//
//  ReportUserVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 6/3/24.
//

import UIKit
import Firebase

class ReportUserVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    var userId: String
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
        
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reportTargetLabel: UILabel = {
        let label = UILabel()
        label.text = "신고대상"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.text = "신고사유"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectedReasonLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray2
        label.text = "선택된 사유"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let arrowIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowUpward_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var reasonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.cornerRadius = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(selectedReasonLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(arrowIconImageView)

        selectedReasonLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true

        arrowIconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        arrowIconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        arrowIconImageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true

        return stackView
    }()

    
    private let reasons = ["커뮤니티 위반 사례", "부정행위", "사기 행위"]
    
    private let reasonPicker = UIPickerView()
    
    private let reportContentLabel: UILabel = {
        let label = UILabel()
        label.text = "신고 내용"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reportTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 10
        textView.text = "신고 사유에 대한 내용을 자세히 입력해주세요."
        textView.textColor = .gray2
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 16, bottom: 0, right: 0)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let confirmationLabel: UILabel = {
        let label = UILabel()
        label.text = "허위 신고 적발시 허위 신고 유저에게 불이익이 발생할 수 있습니다."
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainButton: MainButton = {
        let button = MainButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = "신고하기"
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        view.backgroundColor = .white
        setupViews()
        fetchUserProfile(userId: userId)
        setupPicker()
        setupTextView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let reasonLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(reasonLabelTapped))
        reasonStackView.addGestureRecognizer(reasonLabelTapGesture)
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "신고하기"
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func reasonLabelTapped() {
        reasonPicker.isHidden = false
        selectedReasonLabel.becomeFirstResponder()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(reportTargetLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(reasonLabel)
        contentView.addSubview(reasonStackView)
        contentView.addSubview(reportContentLabel)
        contentView.addSubview(reportTextView)
        contentView.addSubview(confirmationLabel)
        contentView.addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            reportTargetLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            reportTargetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: reportTargetLabel.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 116),
            profileImageView.heightAnchor.constraint(equalToConstant: 116),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            reasonLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            reasonLabel.leadingAnchor.constraint(equalTo: reasonStackView.leadingAnchor, constant: 16),
            
            reasonStackView.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 10),
            reasonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reasonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            reasonStackView.heightAnchor.constraint(equalToConstant: 40),
            
            reportContentLabel.topAnchor.constraint(equalTo: reasonStackView.bottomAnchor, constant: 20),
            reportContentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            reportTextView.topAnchor.constraint(equalTo: reportContentLabel.bottomAnchor, constant: 10),
            reportTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reportTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            reportTextView.heightAnchor.constraint(equalToConstant: 216),
            
            confirmationLabel.topAnchor.constraint(equalTo: reportTextView.bottomAnchor, constant: 10),
            confirmationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            mainButton.topAnchor.constraint(equalTo: confirmationLabel.bottomAnchor, constant: 30),
            mainButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainButton.heightAnchor.constraint(equalToConstant: 56),
            mainButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupPicker() {
        reasonPicker.delegate = self
        reasonPicker.dataSource = self
        reasonPicker.translatesAutoresizingMaskIntoConstraints = false
        reasonPicker.backgroundColor = .white
        contentView.addSubview(reasonPicker)
        reasonPicker.isHidden = true
        NSLayoutConstraint.activate([
            reasonPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reasonPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reasonPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            reasonPicker.heightAnchor.constraint(equalToConstant: 216)
        ])
    }
    
    private func setupTextView() {
        reportTextView.delegate = self
    }
    
    private func fetchUserProfile(userId: String) {
        Firestore.firestore().collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to fetch user profile: \(error)")
                return
            }
            guard let data = snapshot?.data(),
                  let userName = data["name"] as? String,
                  let profileImageUrl = data["profileImageUrl"] as? String else {
                print("No user data found")
                return
            }
            self.nameLabel.text = userName
            if let url = URL(string: profileImageUrl) {
                self.profileImageView.loadImage(from: url)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reasons.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reasons[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedReasonLabel.text = reasons[row]
        reasonPicker.isHidden = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray2 {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "신고 사유에 대한 내용을 자세히 입력해주세요."
            textView.textColor = .gray2
        }
    }
    
    @objc private func reportButtonTapped() {
        guard let reason = selectedReasonLabel.text, reason != "선택된 사유" else {
            showAlert(message: "신고 사유를 선택해 주세요.")
            return
        }
        guard let reportText = reportTextView.text, !reportText.isEmpty, reportText != "신고 사유에 대한 내용을 자세히 입력해주세요." else {
            showAlert(message: "신고 내용을 입력해 주세요.")
            return
        }
        
        let reportData: [String: Any] = [
            "reportedUserId": userId,
            "reason": reason,
            "details": reportText,
            "timestamp": Timestamp()
        ]
        
        Firestore.firestore().collection("report_user").addDocument(data: reportData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to report user: \(error)")
                self.showAlert(message: "신고에 실패했습니다. 다시 시도해 주세요.")
            } else {
                self.showAlert(message: "신고가 성공적으로 접수되었습니다.", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
