//
//  RunActivityVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit
import MapKit

final class RunActivityVC: UIViewController {
    private var mapView: MKMapView!
    private let locationService = LocationService.shared
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3"
        label.font = UIFont.boldSystemFont(ofSize: 58)
        label.textColor = .white
        return label
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 20
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "잠시 후 러닝이 시작됩니다!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        [countLabel, label].forEach {st.addArrangedSubview($0)}
        view.addSubview(st)
        st.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        st.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setMapRegion()
        setConstraint()
        setTimer()
    }
    
    func setConstraint() {
        self.view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            
        ])
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    func setMapRegion() {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        if let currentLocation = locationService.currentLocation {
            mapView.setRegion(.init(center: currentLocation, span: defaultSpanValue), animated: true)
        }
    }
    
    func updateOnStart() {
        self.overlayView.isHidden = true
    }
    
    func setTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let number = self.countLabel.text!.asNumber
            if number == 1 {
                self.updateOnStart()
                return
            }
            self.countLabel.text = (number - 1).asString
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            self.countLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
extension String {
    var asNumber: Int {
        guard let number = Int(self) else { return 0 }
        return number
    }
}
