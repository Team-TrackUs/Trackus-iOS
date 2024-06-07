//
//  ReportPostVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 6/5/24.
//

import UIKit

class ReportPostVC: UIViewController {
    
    // MARK: - Properties
    
    var postUid = ""
    var userUid = ""
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let postLabel: UILabel = {
        let label = UILabel()
        label.text = "신고 게시물"
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.text = "신고 사유"
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "신고 내용"
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let alertText: UILabel = {
        let label = UILabel()
        label.text = "허위 신고 적발시 허위 신고 유저에게 불이익이 발생할 수 있습니다."
        label.textColor = .gray2
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = { // 포스트 이미지
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 87).isActive = true
        view.heightAnchor.constraint(equalToConstant: 87).isActive = true
        view.layer.cornerRadius = 12
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = { // 포스트 제목
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reasonButton: UIButton = {
        let button = UIButton()
        button.setTitle("커뮤니티 위반사례", for: .normal)
        button.setTitleColor(UIColor.gray1, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray2.cgColor
        button.addTarget(self, action: #selector(reasonButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        label.text = "신고 사유에 대한 내용을 자세히 입력해주세요."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
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
    
    var reportReason: String = "" {
        didSet {
            updateReportButton()
        }
    }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Selectors
    
    @objc func reasonButtonTapped() {
        let action1 = UIAlertAction(title: "욕설, 비방, 혐오표현을 해요", style: .default) { action in
            self.reasonButton.setTitle("욕설, 비방, 혐오표현을 해요", for: .normal)
            self.reportReason = "욕설, 비방, 혐오표현을 해요"
            self.reasonButton.setTitleColor(.black, for: .normal)
        }
        
        let action2 = UIAlertAction(title: "연애 목적의 대화를 시도해요", style: .default) { action in
            self.reasonButton.setTitle("연애 목적의 대화를 시도해요", for: .normal)
            self.reportReason = "연애 목적의 대화를 시도해요"
            self.reasonButton.setTitleColor(.black, for: .normal)
        }
        
        let action3 = UIAlertAction(title: "갈등 조장 및 허위 사실을 유포해요", style: .default) { action in
            self.reasonButton.setTitle("갈등 조장 및 허위 사실을 유포해요", for: .normal)
            self.reportReason = "갈등 조장 및 허위 사실을 유포해요"
            self.reasonButton.setTitleColor(.black, for: .normal)
        }
        
        let action4 = UIAlertAction(title: "채팅방 도배 및 광고를 해요", style: .default) { action in
            self.reasonButton.setTitle("채팅방 도배 및 광고를 해요", for: .normal)
            self.reportReason = "채팅방 도배 및 광고를 해요"
            self.reasonButton.setTitleColor(.black, for: .normal)
        }
        
        let action5 = UIAlertAction(title: "성적 수취심이나 혐오감을 일으켜요", style: .default) { action in
            self.reasonButton.setTitle("성적 수취심이나 혐오감을 일으켜요", for: .normal)
            self.reportReason = "성적 수취심이나 혐오감을 일으켜요"
            self.reasonButton.setTitleColor(.black, for: .normal)
        }
        
        let action6 = UIAlertAction(title: "다른 문제가 있어요", style: .default) { action in
            self.reasonButton.setTitle("다른 문제가 있어요", for: .normal)
            self.reportReason = "다른 문제가 있어요"
            self.reasonButton.setTitleColor(.black, for: .normal)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        let alert = UIAlertController(title: "신고사유", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        alert.addAction(action5)
        alert.addAction(action6)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    @objc func reportButtonTapped() {
        PostService().reportPost(postUid: postUid, userUid: userUid, category: reportReason, text: reportText) { bool in
            if bool == false {
                // error alert 보여주기
                self.showAlert(title: "", message: "이미 신고완료된 모집글이거나 해당 모집글이 없습니다.", action: "실패")
            } else {
                // success alert 보여주기
                self.showAlert(title: "", message: "신고가 완료되었습니다.", action: "성공")
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
    
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(addCourseButtonContainer)
        view.addSubview(scrollView)
        addCourseButtonContainer.addSubview(divider)
        
        addCourseButtonContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        addCourseButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addCourseButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        addCourseButtonContainer.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
        addCourseButtonContainer.addSubview(reportButton)
        reportButton.topAnchor.constraint(equalTo: addCourseButtonContainer.topAnchor, constant: 10).isActive = true
        reportButton.leftAnchor.constraint(equalTo: addCourseButtonContainer.leftAnchor, constant: 16).isActive = true
        reportButton.bottomAnchor.constraint(equalTo: addCourseButtonContainer.bottomAnchor).isActive = true
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
        
        scrollView.addSubview(postLabel)
        postLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        postLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        
        scrollView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: postLabel.bottomAnchor, constant: 12).isActive = true
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        
        scrollView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        scrollView.addSubview(reasonLabel)
        reasonLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        reasonLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        
        scrollView.addSubview(reasonButton)
        reasonButton.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 12).isActive = true
        reasonButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        reasonButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        reasonButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let descriptionStack = UIStackView()
        descriptionStack.axis = .vertical
        descriptionStack.spacing = 12
        descriptionStack.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionStack.addArrangedSubview(descriptionLabel)
        
        descriptionStack.addArrangedSubview(textView)
        textView.leadingAnchor.constraint(equalTo: descriptionStack.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: descriptionStack.trailingAnchor).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        descriptionStack.addArrangedSubview(alertText)
        
        scrollView.addSubview(descriptionStack)
        descriptionStack.topAnchor.constraint(equalTo: reasonButton.bottomAnchor, constant: 20).isActive = true
        descriptionStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        descriptionStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        descriptionStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32).isActive = true
        descriptionStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32).isActive = true
        
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "모집글 신고"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    public func configure(uid: String, imageUrl: String, title: String, userUid: String) {
        self.imageView.loadImage(url: imageUrl)
        self.titleLabel.text = title
        self.postUid = uid
        self.userUid = userUid
    }
    
    func updateReportButton() {
        if reportReason == "" || reportText == "" {
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

extension ReportPostVC: UITextViewDelegate {
    
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
