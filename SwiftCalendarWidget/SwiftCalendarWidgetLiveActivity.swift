//
//  SwiftCalendarWidgetLiveActivity.swift
//  SwiftCalendarWidget
//
//  Created by Matias Martinelli on 16/02/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SwiftCalendarWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SwiftCalendarWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SwiftCalendarWidgetAttributes.self) { context in
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

extension SwiftCalendarWidgetAttributes {
    fileprivate static var preview: SwiftCalendarWidgetAttributes {
        SwiftCalendarWidgetAttributes(name: "World")
    }
}

extension SwiftCalendarWidgetAttributes.ContentState {
    fileprivate static var smiley: SwiftCalendarWidgetAttributes.ContentState {
        SwiftCalendarWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SwiftCalendarWidgetAttributes.ContentState {
         SwiftCalendarWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SwiftCalendarWidgetAttributes.preview) {
   SwiftCalendarWidgetLiveActivity()
} contentStates: {
    SwiftCalendarWidgetAttributes.ContentState.smiley
    SwiftCalendarWidgetAttributes.ContentState.starEyes
}
