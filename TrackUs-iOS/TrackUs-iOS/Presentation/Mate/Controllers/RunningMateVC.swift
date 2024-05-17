//
//  RunningMateVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit

class RunningMateVC: UIViewController {
    private lazy var moveButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("move", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        view.backgroundColor = .red
        setupNavBar()
        self.view.addSubview(moveButton)
        moveButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        moveButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "메이트 모집"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc func moveButtonTapped() {
//        let mateDetailVC = MateDetailVC()
        let mateDetailVC = CourseRegisterVC()
        mateDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(mateDetailVC, animated: true)
        
    }
    
    
}

