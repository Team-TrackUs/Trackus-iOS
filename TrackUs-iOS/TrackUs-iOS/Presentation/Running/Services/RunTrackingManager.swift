//
//  RunTrackingManager.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/17/24.
//

import Foundation
import CoreLocation
import CoreMotion

/**
 러닝트래킹 매니저
 */
final public class RunTrackingManager {
    private let coreMotionService = CoreMotionService.shared
    private var runningModel = Running()
    private var currentAltitude = 0.0
    private var maxAltitude = -99999.0
    private var minAltitude = 99999.0
    private var savedData: [String: Any] = ["distance": 0.0, "steps": 0]
  
    var coordinates: [CLLocationCoordinate2D] {
        get { runningModel.coordinates }
        set { runningModel.coordinates = newValue }
    }
    
    var seconds: Double {
        get { runningModel.seconds }
        set { runningModel.seconds = newValue }
    }
    
    /// 운동정보감지 업데이트 핸들러
    func updateRunInfo(completion: @escaping (Running) -> Void) {
        coreMotionService.pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            
            guard let self = self else { return }
            guard let pedometerData = pedometerData, error == nil else {
                return
            }
            let currentDistance = pedometerData.distance?.doubleValue ?? 0.0
            let currentSteps = pedometerData.numberOfSteps.intValue
            guard let savedSteps = savedData["steps"] as? Int else { return }
            
            runningModel.steps = currentSteps + savedSteps
            runningModel.distance = currentDistance + (savedData["distance"] as? Double ?? 0.0)
            runningModel.cadance = Int((Double(currentSteps + savedSteps)) / (runningModel.seconds / 60))
            runningModel.calorie = Double(runningModel.steps) * 0.04
            runningModel.pace = (runningModel.seconds / 60) / (runningModel.distance / 1000.0)
        }
        
        coreMotionService.altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self]  altitudeData, error in
            guard let self = self else { return }
            guard let altitudeData = altitudeData, error == nil else {
                return
            }
            let measuredAlti = altitudeData.relativeAltitude.doubleValue
            if measuredAlti > 0 {
                runningModel.maxAltitude = max(maxAltitude, measuredAlti)
            } else {
                runningModel.minAltitude = min(minAltitude, measuredAlti)
            }
            completion(runningModel)
        }
    }
    
    /// 핸들러 중지
    func stopRecord() {
        coreMotionService.pedometer.stopUpdates()
        coreMotionService.altimeter.stopRelativeAltitudeUpdates()
        savedData["distance"] = runningModel.distance
        savedData["steps"] = runningModel.steps
    }
}
