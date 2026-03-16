//
//  LatestUploadWidget.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import SwiftUI
import WidgetKit

struct LatestUploadWidget: Widget {
    static let kind = "LatestUpload"

    let kind: String = Self.kind

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectChannelIntent.self,
            provider: LatestUploadTimelineProvider(),
            content: { entry in
                LatestUploadEntryView(entry: entry)
            }
        )
        .configurationDisplayName("Latest Upload")
        .description("View stats for your channel's latest upload")
        .supportedFamilies([.systemMedium])
    }
}
