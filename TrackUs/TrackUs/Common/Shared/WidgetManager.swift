//
//  WidgetManager.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/11/24.
//

import ActivityKit

@available(iOS 16.2, *)
final class WidgetManager {
    static let shared = WidgetManager()
    private init() {}
    var activity: Activity<WidgetTestAttributes>!
}
