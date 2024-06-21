//
//  CalendarVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/21/24.
//

import UIKit

class CalendarVC: UIViewController {
    
    var didSelectDate: ((Date) -> Void)?
    private let calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
    }
    
    private func setupViews() {
        view.addSubview(calendarView)
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            doneButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped() {
        let selectedDate = calendarView.date
        didSelectDate?(selectedDate)
        dismiss(animated: true, completion: nil)
    }
}
