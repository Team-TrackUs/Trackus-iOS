//
//  MyMapView.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/30/24.
//

import UIKit
import MapKit

final class MyMapView: UIView {
    var mapView: MKMapView!
    private var polyline: MKPolyline?
    private var annotation: MKPointAnnotation?
    private var annotation2: MKPointAnnotation?
    var coordinates: [CLLocationCoordinate2D]? {
        didSet {
            setRegion()
            drawPath()
        }
    }

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        initMapView()
        setupUI()
    }
    
    private func initMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCoordinate(_ coordinates: [CLLocationCoordinate2D]?) {
        self.coordinates = coordinates
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func drawPath() {
        guard let coordinates = coordinates else {
            return
        }
        annotation = MKPointAnnotation()
        annotation2 = MKPointAnnotation()
        polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        guard coordinates.count >= 1, let annotation = annotation,let annotation2 = annotation2 else { return }
        annotation.coordinate = coordinates.first!
        annotation2.coordinate = coordinates.last!
        
        mapView.addAnnotations([annotation, annotation2])
        
        guard coordinates.count >= 2, let polyline = polyline else { return }
        mapView.addOverlay(polyline)
    }
    
    private func setRegion() {
        if let region = coordinates?.makeRegionToFit() {
            mapView.setRegion(region, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 40,
                                                                                                  left: 40,
                                                                                                  bottom: 40,
                                                                                                  right: 40), animated: false)
        }
    }
}

extension MyMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            print("can't draw polyline")
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .green
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        return renderer
    }
}
