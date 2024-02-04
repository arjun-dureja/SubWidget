//
//  WidgetConfiguration.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-02-03.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit
import Foundation

struct ViewCount: Widget {
    let kind: String = "ViewCount"

    var body: some WidgetConfiguration {
        return IntentConfiguration(
            kind: kind,
            intent: SelectChannelIntent.self,
            provider: SubWidgetIntentTimelineProvider(widgetType: .views),
            content: { (entry) in
                SubscriberCountEntryView(entry: entry)
            }
        )
        .configurationDisplayName("View Count")
        .description("View your YouTube view count in realtime")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}
