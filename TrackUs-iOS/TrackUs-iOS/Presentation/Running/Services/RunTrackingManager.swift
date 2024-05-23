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
    
    var seconds: Double {
        get { runningModel.seconds }
        set { runningModel.seconds = newValue }
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        get { runningModel.coordinates }
    }
    
    var distance: Double {
        get { runningModel.distance }
    }
    
    var pace: Double  {
        get { runningModel.pace } 
    }
    
    func updateRunningInfo(withCoordinate coordinate: CLLocationCoordinate2D) {
        self.addPath(withCoordinate: coordinate)
        self.updateDistance()
        self.updatePace()
    }
    
    private func addPath(withCoordinate coordinate: CLLocationCoordinate2D) {
        self.runningModel.coordinates.append(coordinate)
    }
    
    private func updateDistance() {
        guard coordinates.count >= 2 else { return }
        self.runningModel.distance += coordinates[coordinates.count - 1].distance(to: coordinates[coordinates.count - 2])
    }
    
    private func updatePace() {
        self.runningModel.pace = (runningModel.seconds / 60) / (runningModel.distance / 1000.0)
    }
}
