//
//  UserLocationDelegate.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import Foundation
import MapKit

protocol UserLocationDelegate {
    func userLocationUpated(location: CLLocation)
}
