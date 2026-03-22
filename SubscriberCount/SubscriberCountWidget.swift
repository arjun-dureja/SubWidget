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

struct SubscriberCount: Widget {
    let kind: String = "SubscriberCount"

    var body: some WidgetConfiguration {
        return AppIntentConfiguration(
            kind: kind,
            intent: SelectChannelAppIntent.self,
            provider: SubWidgetIntentTimelineProvider(widgetType: .subscribers),
            content: { (entry) in
                SubscriberCountEntryView(entry: entry)
            }
        )
        .configurationDisplayName("Subscriber Count")
        .description("View your YouTube subscriber count in realtime")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}
