//
//  AskusVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 6/18/24.
//

import UIKit

class AskusVC: UIViewController {
    
    // MARK: - Properties
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "문의사항 & 개선사항"
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = """
        1. 앱 사용 시 불편사항 혹은 개선사항을 입력해주세요.
        
        2. 답변을 받으실 이메일을 기재해 주세요.
        
        """
        label.textColor = .gray1
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let alertLabel: UILabel = {
        let label = UILabel()
        label.text = "소중한 피드백을 반영하여, 더 나은 TrackUs가 되도록 노력하겠습니다."
        label.textColor = .gray2
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var toolBarKeyboard: UIToolbar = {
        let toolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(btnDoneBarTapped))
        toolbar.sizeToFit()
        toolbar.items = [flexBarButton, doneButton]
        toolbar.tintColor = .mainBlue
        return toolbar
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 16)
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.gray2.cgColor
        view.textContainerInset = UIEdgeInsets(top: 16, left: 4, bottom: 16, right: 4)
        view.isScrollEnabled = false
        view.inputAccessoryView = toolBarKeyboard
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textViewPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "문의사항과 이메일을 입력해주세요."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("문의하기", for: .normal)
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 56 / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addCourseButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray3
        return view
    }()

    var reportText: String = "" {
        didSet {
            updateReportButton()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        setupNavBar()
        configureUI()
        setupPlaceholder()
        hideKeyboardWhenTappedAround()
        updateReportButton()
        backGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Selectors
    
    @objc func reportButtonTapped() {
        let userUid = User.currentUid
        
        AskService().askus(userUid: userUid, text: reportText) { error in
            if let error = error {
                self.showAlert(title: "", message: "오류가 발생하였습니다.", action: "실패")
            } else {
                self.showAlert(title: "", message: "문의가 접수되었습니다.", action: "성공")
            }
        }
    }
    
    @objc func btnDoneBarTapped(sender: Any) {
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(addCourseButtonContainer)
        view.addSubview(scrollView)
        addCourseButtonContainer.addSubview(divider)
        
        addCourseButtonContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        addCourseButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addCourseButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        addCourseButtonContainer.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        addCourseButtonContainer.addSubview(reportButton)
        reportButton.topAnchor.constraint(equalTo: addCourseButtonContainer.topAnchor, constant: 10).isActive = true
        reportButton.leftAnchor.constraint(equalTo: addCourseButtonContainer.leftAnchor, constant: 16).isActive = true
        reportButton.bottomAnchor.constraint(equalTo: addCourseButtonContainer.bottomAnchor, constant: -2).isActive = true
        reportButton.rightAnchor.constraint(equalTo: addCourseButtonContainer.rightAnchor, constant: -16).isActive = true
        
        divider.topAnchor.constraint(equalTo: addCourseButtonContainer.topAnchor).isActive = true
        divider.leadingAnchor.constraint(equalTo: addCourseButtonContainer.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: addCourseButtonContainer.trailingAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: divider.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subTitleLabel)
        stack.addArrangedSubview(textView)
        textView.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        stack.addArrangedSubview(alertLabel)
        
        scrollView.addSubview(stack)
        stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        stack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        stack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32).isActive = true
        stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32).isActive = true
    }
    
    private func setupNavBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.title = "문의하기"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func updateReportButton() {
        if reportText == "" {
            reportButton.backgroundColor = .systemGray
            reportButton.isEnabled = false
        } else {
            reportButton.backgroundColor = .mainBlue
            reportButton.isEnabled = true
        }
    }
    
    func showAlert(title: String, message: String, action: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        switch action {
        case "성공":
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            
        case "실패":
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                
            }
            alertController.addAction(okAction)
            
        default:
            break
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AskusVC: UITextViewDelegate {
    
    func setupPlaceholder() {
        textView.addSubview(textViewPlaceholder)
        
        textViewPlaceholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: 16).isActive = true
        textViewPlaceholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8).isActive = true
        textViewPlaceholder.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8).isActive = true
        
        textViewPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceholder.isHidden = !textView.text.isEmpty
        reportText = textView.text
        
        // 텍스트뷰 스크롤 없이 height 길어지게끔..
        let size = CGSize(width: scrollView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
            if estimatedSize.height <= 180 {
                
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.black.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.gray2.cgColor
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

extension AskusVC: UIGestureRecognizerDelegate {
    // 스와이프로 이전 화면 갈 수 있도록 추가
    func backGesture() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}
