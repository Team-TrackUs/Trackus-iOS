//
//  MyChatListVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit

class MyChatListVC: UIViewController {
    
//    private lazy var imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.memoryloadImage(url: <#T##String#>)
//        //... 추가 필요 코드 작성 ...
//        return imageView
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        view.backgroundColor = .green
        setupAutoLayout()
    }

    private func setupNavBar() {
        self.navigationItem.title = "채팅 목록"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - 오토레이아웃 세팅
    private func setupAutoLayout() {
//        self.view.addSubview(imageView)
//        
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//        ])
    }

}
