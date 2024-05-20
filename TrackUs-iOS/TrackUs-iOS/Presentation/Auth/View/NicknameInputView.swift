//
//  NicknameInputView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/17/24.
//

import UIKit

// MARK: - 닉네임 view
class NicknameInputView: UIView, UITextFieldDelegate {
    // MARK: - MainButtonEnable 델리게이트
    weak var delegate: MainButtonEnabledDelegate?
    
    // 닉네임 조건 확인 여부
    private var isError: Bool = false {
        didSet {
            if isError {
                guidelabel.textColor = .red
            } else {
                guidelabel.textColor = .gray2
            }
        }
    }
    
    // 메인 버튼 활성화 여부
    private var availability: Bool = false {
        didSet {
            delegate?.MainButtonDidChangeEnabled(availability)
        }
    }
    
    private let textLimit = 10
    private let placeholderText = "닉네임을 입력해주세요"
    
    // MARK: - UI Components
    private lazy var label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "닉네임"
        label.textColor = .gray2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var textField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.textColor = .gray1
        textField.placeholder = placeholderText
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.returnKeyType = .next
        textField.clearButtonMode = .whileEditing
        // textField 입력 활성화 - 키보드 자동 열림
        textField.becomeFirstResponder()
        //textField.borderStyle = .roundedRect
        //textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.layer.zPosition = 999
        return textField
    }()
    
    // 구분선
    private lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray3
        return view
    }()
    
    private lazy var guidelabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "특수문자, 공백 제외 2~10자리"
        label.textColor = .gray2
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray2
        return label
    }()
    
    private lazy var stackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [label, textField, lineView, guidelabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAutoLayout()
    }
    
    // MARK: - Setup AutoLayout
    private func setupAutoLayout() {
        textField.delegate = self
        
        addSubview(stackView)
        addSubview(characterCountLabel)
        
        
        NSLayoutConstraint.activate([
            
            textField.heightAnchor.constraint(equalToConstant: 32),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            characterCountLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            characterCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - TextField Delegate
    @objc private func textFieldDidChange() {
        let newText = textField.text ?? ""
        checkText(newText)
        checkAvailability()
        textCountCheck(text: newText)
    }
    
    // MARK: - 닉네임 문구 충족 여부 확인
    private func checkText(_ newText: String) {
        let specialCharacters = CharacterSet(charactersIn: "!?@#$%^&*()_+=-<>,.;|/:[]{}")
        
        if newText.count > textLimit || newText.count < 2 || newText.contains(" ") || newText.rangeOfCharacter(from: specialCharacters) != nil {
            isError = true
            guidelabel.textColor = .red
            lineView.backgroundColor = .red
        } else {
            isError = false
            guidelabel.textColor = .gray2
            lineView.backgroundColor = .gray3
        }
    }
    
    // 닉네임 입력 조건 여부 확인
    private func checkAvailability() {
        availability = !textField.text!.isEmpty && !isError
    }
    
    // 닉네임 입력 갯수 확인
    private func textCountCheck(text: String) {
        characterCountLabel.text = "\(text.count)/\(textLimit)"
        if text.count > textLimit {
            characterCountLabel.textColor = .red
        } else {
            characterCountLabel.textColor = .gray2
        }
    }
    
    // 엔터키 누를 경우 실행 함수
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if availability {
//            textField.resignFirstResponder() // 키보드 숨기기
//        }
//        return true
//    }
}

