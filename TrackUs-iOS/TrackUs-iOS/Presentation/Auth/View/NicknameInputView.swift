//
//  NicknameInputView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/17/24.
//

import UIKit

// MARK: - 닉네임 view
class NicknameInputView: UIView {
    // MARK: - MainButtonEnable 델리게이트
    weak var delegate: MainButtonEnabledDelegate?
    
    private var isError: Bool = false {
        didSet {
            updateErrorState()
        }
    }
    
    private var availability: Bool = false {
        didSet {
            delegate?.MainButtonDidChangeEnabled(availability)
        }
    }
    
    private let textLimit = 10
    private let placeholderText = "닉네임을 입력해주세요"
    
    // MARK: - UI Components
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 48
        textField.backgroundColor = .clear
        textField.textColor = .gray1
        textField.placeholder = placeholderText
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        //textField.borderStyle = .roundedRect
        //textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
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
        addSubview(textField)
        addSubview(errorLabel)
        addSubview(characterCountLabel)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            characterCountLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            characterCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - TextField Delegate
    @objc private func textFieldDidChange() {
        let newText = textField.text ?? ""
        checkText(newText)
        checkAvailability()
        characterCountLabel.text = "\(newText.count)/\(textLimit)"
    }
    
    // MARK: - Validation
    private func checkText(_ newText: String) {
        let specialCharacters = CharacterSet(charactersIn: "!?@#$%^&*()_+=-<>,.;|/:[]{}")
        
        if newText.count > textLimit || newText.count < 2 || newText.contains(" ") || newText.rangeOfCharacter(from: specialCharacters) != nil {
            isError = true
        } else {
            isError = false
        }
    }
    
    private func checkAvailability() {
        availability = !textField.text!.isEmpty && !isError
    }
    
    // MARK: - Update UI
    private func updateErrorState() {
        if isError {
            errorLabel.text = "닉네임 형식을 확인해주세요."
            errorLabel.isHidden = false
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1
        } else {
            errorLabel.isHidden = true
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0
        }
    }
    
}

