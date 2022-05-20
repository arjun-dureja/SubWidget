//
//  SubWidgetIntentTimelineProvider.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-15.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let channel: YouTubeChannel?
}

struct SubWidgetIntentTimelineProvider: IntentTimelineProvider {
    
    typealias Entry = SimpleEntry
    typealias Intent = SelectChannelIntent

    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "PewDiePie", profileImage: "https://yt3.ggpht.com/ytc/AAUvwnga3eXKkQgGU-3j1_jccZ0K9m6MbjepV0ksd7eBEw=s800-c-k-c0x00ffffff-no-rj", subCount: "100000000", channelId: "UC-lHJZR3Gqxm24_Vd_AJ5Yw"))
    }
    
    func getSnapshot(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        if configuration.channel == nil {
            return
        }

        Task {
            let result = try await fetchChannel(for: configuration.channel ?? YouTubeChannelParam.global)
            completion(result)
        }
    }
    
    func getTimeline(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        if configuration.channel == nil {
            let timeline = Timeline(entries: [SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: nil)], policy: .never)
            completion(timeline)
            return
        }

        Task {
            let result = try await fetchChannel(for: configuration.channel ?? YouTubeChannelParam.global)
            let timeline = Timeline(entries: [result], policy: .after(Date().addingTimeInterval(60 * 30)))
            completion(timeline)
        }
    }
    
    private func fetchChannel(for param: YouTubeChannelParam) async throws -> SimpleEntry {
        guard let id = param.identifier else { throw SubWidgetError.invalidURL }

        let viewModel = await ViewModel()
        let channels = try await viewModel.fetchChannels()
        for channel in channels {
            if channel.id == id {
                let resultChannel = try await viewModel.getChannelDetailsFromId(for: channel.channelId)
                var finalChannel = resultChannel
                finalChannel.bgColor = channel.bgColor
                return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: finalChannel)
            }
        }

        throw SubWidgetError.invalidURL
    }
}

struct SubscriberCountEntryView : View {
    var entry: SubWidgetIntentTimelineProvider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidget(entry: entry.channel)
        default:
            MediumWidget(entry: entry.channel)
        }
    }
}

@main
struct SubscriberCount: Widget {
    let kind: String = "SubscriberCount"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectChannelIntent.self, provider: SubWidgetIntentTimelineProvider(), content: { (entry) in
            SubscriberCountEntryView(entry: entry)
        })
        .configurationDisplayName("Subscriber Count")
        .description("View your YouTube subscriber count in realtime")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
