//
//  RunTrackingManager.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/17/24.
//

import Foundation
import CoreLocation

final public class RunTrackingManager {
    private var runningModel = Running()
    
    var seconds: Int {
        get { runningModel.seconds }
        set { runningModel.seconds = newValue }
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        get { runningModel.coordinates }
    }
    
    var distance: Double {
        get { runningModel.distance }
    }
    
    /// 좌표 추가
    func addPath(withCoordinate coordinate: CLLocationCoordinate2D) {
        self.runningModel.coordinates.append(coordinate)
        guard coordinates.count >= 2 else { return }
        self.runningModel.distance += coordinate.distance(to: coordinates[coordinates.count - 2])
    }
}
