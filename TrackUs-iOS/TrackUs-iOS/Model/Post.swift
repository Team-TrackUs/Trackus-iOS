//
//  Post.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/23/24.
//

import Foundation
import Firebase
import CoreLocation

struct Post {
    var uid: String
    var title: String
    var content: String
    var courseRoutes: [GeoPoint]
    var distance: Double
    var isEdit: Bool
    var numberOfPeoples: Int
    var routeImageUrl: String
    var startDate: Date
    var address: String
    var whoReportMe: [String]
    var createdAt: Date
    var runningStyle: Int
    var members: [String]
    
    init(uid: String, title: String, content: String, courseRoutes: [GeoPoint], distance: Double, isEdit: Bool, numberOfPeoples: Int, routeImageUrl: String, startDate: Date, address: String, whoReportMe: [String], createdAt: Date, runningStyle: Int, members: [String]) {
        self.uid = uid
        self.title = title
        self.content = content
        self.courseRoutes = courseRoutes
        self.distance = distance
        self.isEdit = isEdit
        self.numberOfPeoples = numberOfPeoples
        self.routeImageUrl = routeImageUrl
        self.startDate = startDate
        self.address = address
        self.whoReportMe = whoReportMe
        self.createdAt = createdAt
        self.runningStyle = runningStyle
        self.members = members
    }
    
    mutating func updateRouteImageUrl(newUrl: String) {
        self.routeImageUrl = newUrl
    }
}
