//
//  RunningResultVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit

class RunningResultVC: UIViewController {
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🏃‍♂️ 종로3가 에서 러닝 - 오후 12:32"
        label.textColor = .gray1
        return label
    }()
    
    private lazy var kmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3.33 KM"
        if let descriptor = UIFont.systemFont(ofSize: 40, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
                 label.font = UIFont(descriptor: descriptor, size: 0)
             } else {
                 label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
             }
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setConstraint()
    }
    
    // MARK: - Helpers
    func setConstraint() {
        view.addSubview(titleLabel)
        view.addSubview(kmLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            kmLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            kmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
    }
    
}
