//
//  WidgetTestLiveActivity.swift
//  WidgetTest
//
//  Created by 석기권 on 6/3/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
struct WidgetTestLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetTestAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text(context.state.isActive ? "러닝중 🔥" : "휴식중 😓")
                    }
                                      
                    HStack(spacing: 17) {
                        VStack(alignment: .leading) {
                            Text(context.state.kilometer)
                                .font(.system(size: 32, weight: .bold))
                            Text("킬로미터")
                        }
                       
                        VStack(alignment: .center) {
                            Spacer()
                            Text(context.state.time)
                                .font(.system(size: 24, weight: .bold))
                            Text("시간")
                        }
                      
                        
                        VStack(alignment: .center) {
                            Spacer()
                            Text(context.state.pace)
                                .font(.system(size: 24, weight: .bold))
                            Text("페이스")
                                
                        }
                       
                    }
                    Spacer()
                }
                .padding(.vertical, 15)
            }
            .contentTransition(.identity)
            .foregroundStyle(.white)
            .activityBackgroundTint(Color.black.opacity(0.5))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                    // more content
                }
            } compactLeading: {
                EmptyView()
            } compactTrailing: {
                EmptyView()
            } minimal: {
                EmptyView()
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WidgetTestAttributes {
    fileprivate static var preview: WidgetTestAttributes {
        WidgetTestAttributes(name: "World")
    }
}

extension WidgetTestAttributes.ContentState {
    fileprivate static var smiley: WidgetTestAttributes.ContentState {
        WidgetTestAttributes.ContentState(time: "00:00", pace: "", kilometer: "", isActive: false)
     }
     
     fileprivate static var starEyes: WidgetTestAttributes.ContentState {
         WidgetTestAttributes.ContentState(time: "00:00", pace: "", kilometer: "", isActive: false)
     }
}

//#Preview("Notification", as: .content, using: WidgetTestAttributes.preview) {
//   WidgetTestLiveActivity()
//} contentStates: {
//    WidgetTestAttributes.ContentState.smiley
//    WidgetTestAttributes.ContentState.starEyes
//}
