//
//  MapResultVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/29/24.
//

import UIKit
import MapKit

class MapResultVC: UIViewController {
    private var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupMapView()
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    func setupNavBar() {
        self.navigationItem.title = "지도 보기"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
