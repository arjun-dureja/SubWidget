//
//  CombinedCountWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2026-02-08.
//

import SwiftUI
import WidgetKit
import Foundation

struct CombinedCount: Widget {
    let kind: String = "CombinedCount"

    var body: some WidgetConfiguration {
        return AppIntentConfiguration(
            kind: kind,
            intent: SelectChannelAppIntent.self,
            provider: SubWidgetIntentTimelineProvider(widgetType: .combined),
            content: { entry in
                SubscriberCountEntryView(entry: entry)
            }
        )
        .configurationDisplayName("Subscribers + Views")
        .description("View both your subscriber and view counts in one widget")
        .promptsForUserConfiguration()
        .supportedFamilies([.systemMedium])
    }
}
