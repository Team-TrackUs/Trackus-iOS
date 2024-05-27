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
    var runModel = Running()
    private let coreMotionService = CoreMotionService.shared    
    private var currentAltitude = 0.0
    private var maxAltitude = -99999.0
    private var minAltitude = 99999.0
    private var savedData: [String: Any] = ["distance": 0.0, "steps": 0]
  
    
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
            
            runModel.steps = currentSteps + savedSteps
            runModel.distance = currentDistance + (savedData["distance"] as? Double ?? 0.0)
            runModel.cadance = Int((Double(currentSteps + savedSteps)) / (runModel.seconds / 60))
            runModel.calorie = Double(runModel.steps) * 0.04
            runModel.pace = (runModel.seconds / 60) / (runModel.distance / 1000.0)
        }
        
        coreMotionService.altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self]  altitudeData, error in
            guard let self = self else { return }
            guard let altitudeData = altitudeData, error == nil else {
                return
            }
            let measuredAlti = altitudeData.relativeAltitude.doubleValue
            if measuredAlti > 0 {
                runModel.maxAltitude = max(maxAltitude, measuredAlti)
            }
            if measuredAlti < 0 {
                runModel.minAltitude = min(minAltitude, measuredAlti)
            }
            completion(runModel)
        }
    }
    
    /// 핸들러 중지
    func stopRecord() {
        coreMotionService.pedometer.stopUpdates()
        coreMotionService.altimeter.stopRelativeAltitudeUpdates()
        savedData["distance"] = runModel.distance
        savedData["steps"] = runModel.steps
    }
}
