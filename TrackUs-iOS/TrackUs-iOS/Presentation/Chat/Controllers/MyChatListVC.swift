//
//  MyChatListVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit

class MyChatListVC: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
    }

    private func setupNavBar() {
        title = "채팅 목록"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

}
