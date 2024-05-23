//
//  RunTrackingManager.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/17/24.
//

import Foundation
import CoreLocation
import CoreMotion

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
    
    func addPath(withCoordinate coordinate: CLLocationCoordinate2D) {
        self.runningModel.coordinates.append(coordinate)
    }
}
