//
//  MapResultVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/29/24.
//

import UIKit
import MapKit

class MapResultVC: UIViewController {
    // MARK: - Properties
    var runModel: Running?
    private var myMapView: MyMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setConstraint()
        setData()
    }
    
    // MARK: - Helpers
    func setConstraint() {
        myMapView = MyMapView(frame: view.frame)
        
        view.addSubview(myMapView)
        
        NSLayoutConstraint.activate([
            myMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myMapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            myMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setData() {
        myMapView.setCoordinate(runModel?.coordinates)
    }
    
    func setupNavBar() {
        self.navigationItem.title = "지도 보기"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
