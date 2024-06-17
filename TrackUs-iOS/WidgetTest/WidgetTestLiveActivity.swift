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
            ZStack(alignment: .topTrailing) {
                Image(.trackusIcon)
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .topTrailing)
                    .padding(10)
                    
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(context.state.kilometer)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.black)
                            Text("킬로미터")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.gray1)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(context.state.time)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.black)
                            Text("시간")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.gray1)
                        }
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(context.state.pace)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.black)
                            Text("평균 페이스")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.gray1)
                        }
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(context.state.cadance)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.black)
                            Text("케이던스")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.gray1)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
                .contentTransition(.identity)
                .activitySystemActionForegroundColor(Color.white)
                .foregroundStyle(.white)
                .activityBackgroundTint(Color.white.opacity(0.3))
            }
            
            
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
        WidgetTestAttributes.ContentState(time: "00:00", pace: "", kilometer: "", cadance: "")
    }
    
    fileprivate static var starEyes: WidgetTestAttributes.ContentState {
        WidgetTestAttributes.ContentState(time: "00:00", pace: "", kilometer: "", cadance: "")
    }
}

//#Preview("Notification", as: .content, using: WidgetTestAttributes.preview) {
//   WidgetTestLiveActivity()
//} contentStates: {
//    WidgetTestAttributes.ContentState.smiley
//    WidgetTestAttributes.ContentState.starEyes
//}
