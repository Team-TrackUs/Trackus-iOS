//
//  WidgetTestLiveActivity.swift
//  WidgetTest
//
//  Created by 석기권 on 6/3/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetTestLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetTestAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
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
        WidgetTestAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WidgetTestAttributes.ContentState {
         WidgetTestAttributes.ContentState(emoji: "🤩")
     }
}

//#Preview("Notification", as: .content, using: WidgetTestAttributes.preview) {
//   WidgetTestLiveActivity()
//} contentStates: {
//    WidgetTestAttributes.ContentState.smiley
//    WidgetTestAttributes.ContentState.starEyes
//}
