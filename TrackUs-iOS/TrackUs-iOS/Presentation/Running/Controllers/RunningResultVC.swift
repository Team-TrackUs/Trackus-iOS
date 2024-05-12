//
//  RunningResultVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit

class RunningResultVC: UIViewController {
    private lazy var moveRootButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("Go to Root", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(moveRootButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
        self.view.addSubview(moveRootButton)
        moveRootButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        moveRootButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    @objc func moveRootButtonTapped() {
        self.view.window!.rootViewController?.dismiss(animated: true)
    }
}
