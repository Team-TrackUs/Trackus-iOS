//
//  MateDetailVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit

class MateDetailVC: UIViewController {
    private lazy var moveButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("move2", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        title = "메이트 모집2"

        self.view.addSubview(moveButton)
        moveButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        moveButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    @objc func moveButtonTapped() {
        let mateDetailVC = MateDetailVC2()
        mateDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(mateDetailVC, animated: true)
    }
}
