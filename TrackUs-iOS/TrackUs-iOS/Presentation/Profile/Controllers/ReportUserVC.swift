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
    
    private let reasons = ["커뮤니티 위반 사례", "부정행위", "사기 행위"]
    
    private let reasonPicker = UIPickerView()
    
    private let reasonTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .gray2
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let arrowImageView = UIImageView(image: UIImage(named: "arrowUpward_icon"))
        arrowImageView.tintColor = .black
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor)
            
        ])
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
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
    
    private let reportButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("신고하기", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25.0
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
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "신고하기"
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
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
    
    private func setupViews() {
        view.addSubview(reportTargetLabel)
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(reasonLabel)
        view.addSubview(reasonTextField)
        view.addSubview(reportContentLabel)
        view.addSubview(reportTextView)
        view.addSubview(confirmationLabel)
        view.addSubview(reportButton)
        
        NSLayoutConstraint.activate([
            reportTargetLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            reportTargetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: reportTargetLabel.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 116),
            profileImageView.heightAnchor.constraint(equalToConstant: 116),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            reasonLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            reasonLabel.leadingAnchor.constraint(equalTo: reasonTextField.leadingAnchor, constant: 16),
            
            reasonTextField.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 10),
            reasonTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reasonTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reasonTextField.heightAnchor.constraint(equalToConstant: 40),
            
            reportContentLabel.topAnchor.constraint(equalTo: reasonTextField.bottomAnchor, constant: 20),
            reportContentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            reportTextView.topAnchor.constraint(equalTo: reportContentLabel.bottomAnchor, constant: 10),
            reportTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportTextView.heightAnchor.constraint(equalToConstant: 150),
            
            confirmationLabel.topAnchor.constraint(equalTo: reportTextView.bottomAnchor, constant: 14),
            confirmationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            reportButton.heightAnchor.constraint(equalToConstant: 58),
            reportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        reasonTextField.text = reasons[0]
    }
    
    private func setupPicker() {
        reasonPicker.delegate = self
        reasonPicker.dataSource = self
        
        reasonTextField.inputView = reasonPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([doneButton], animated: true)
        
        reasonTextField.inputAccessoryView = toolbar
    }
    
    @objc private func doneTapped() {
        let selectedRow = reasonPicker.selectedRow(inComponent: 0)
        reasonTextField.text = reasons[selectedRow]
        reasonTextField.resignFirstResponder()
    }
    
    private func setupTextView() {
        reportTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "신고 사유에 대한 내용을 자세히 입력해주세요." {
            textView.text = ""
            textView.textColor = .gray2
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "신고 사유에 대한 내용을 자세히 입력해주세요."
            textView.textColor = .gray2
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "신고 사유에 대한 내용을 자세히 입력해주세요."
            textView.textColor = .gray2
            textView.selectedRange = NSMakeRange(0, 0)
        } else if textView.textColor == .lightGray && textView.text.count > 0 {
            textView.text = String(textView.text.dropFirst())
            textView.textColor = .black
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reasons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reasons[row]
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
    
    @objc private func reportButtonTapped() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let reportId = UUID().uuidString
        let reportRef = db.collection("report_user").document(reportId)
        
        let report = report_user(
            uid: reportId,
            toUser: nameLabel.text ?? "Unknown User",
            toUserUid: userId,
            category: reasonTextField.text ?? "",
            text: reportTextView.text ?? "",
            fromUser: currentUser.uid,
            createdAt: Timestamp()
        )
        
        do {
            try reportRef.setData(from: report) { error in
                if let error = error {
                    print("Error saving report: \(error.localizedDescription)")
                } else {
                    print("Report successfully saved.")
                    let alert = UIAlertController(title: "신고 완료", message: "신고가 성공적으로 접수되었습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } catch let error {
            print("Error encoding report: \(error.localizedDescription)")
        }
    }
}
