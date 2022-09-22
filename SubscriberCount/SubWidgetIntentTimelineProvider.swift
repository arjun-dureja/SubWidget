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
        // Arbitrary channel for placeholder - will show as redacted
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            channel: YouTubeChannel(
                channelName: "PewDiePie",
                profileImage: "https://yt3.ggpht.com/ytc/AAUvwnga3eXKkQgGU-3j1_jccZ0K9m6MbjepV0ksd7eBEw=s800-c-k-c0x00ffffff-no-rj",
                subCount: "100000000",
                channelId: "UC-lHJZR3Gqxm24_Vd_AJ5Yw"
            )
        )
    }
    
    func getSnapshot(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            // Determine if caller is from add widget screen or home screen
            if configuration.channel == nil {
                // Show first channel in add widget screen if exists
                let viewModel = await ViewModel()
                let channels = try await viewModel.fetchChannels()
                if !channels.isEmpty {
                    let entry = SimpleEntry(
                        date: Date(),
                        configuration: ConfigurationIntent(),
                        channel: channels[0]
                    )

                    completion(entry)
                }
            } else {
                let result = try await fetchChannel(for: configuration.channel ?? YouTubeChannelParam.global)
                completion(result)
            }
        }
    }
    
    func getTimeline(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Determine if user has already selected a channel or not
        if configuration.channel == nil {
            let timeline = Timeline(
                entries: [SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: nil)],
                policy: .never
            )

            completion(timeline)
        } else {
            Task {
                let result = try await fetchChannel(for: configuration.channel ?? YouTubeChannelParam.global)

                let viewModel = await ViewModel()
                let refreshFrequency: Double
                switch await viewModel.refreshFrequency {
                case .THIRTY_MIN:
                    refreshFrequency = 30
                case .ONE_HR:
                    refreshFrequency = 60
                case .SIX_HR:
                    refreshFrequency = 180
                case .TWELVE_HR:
                    refreshFrequency = 720
                }

                let timeline = Timeline(
                    entries: [result],
                    policy: .after(.now.advanced(by: refreshFrequency * 60))
                )

                completion(timeline)
            }
        }
    }
    
    private func fetchChannel(for param: YouTubeChannelParam) async throws -> SimpleEntry {
        guard let id = param.identifier else {
            throw SubWidgetError.invalidIdentifer
        }

        let viewModel = await ViewModel()
        let channels = try await viewModel.fetchChannels()
        if let channel = channels.first(where: { $0.id == id }) {
            var updatedChannel = try await viewModel.getChannelDetailsFromId(for: channel.channelId)
            updatedChannel.bgColor = channel.bgColor
            return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: updatedChannel)
        }

        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: nil)
    }
}

struct SubscriberCountEntryView : View {
    var entry: SubWidgetIntentTimelineProvider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidget(entry: entry.channel)
        case .accessoryRectangular:
            LockscreenWidget(entry: entry.channel)
        default:
            MediumWidget(entry: entry.channel)
        }
    }
}

@main
struct SubscriberCount: Widget {
    let kind: String = "SubscriberCount"

    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 16.0, *) {
            return IntentConfiguration(kind: kind, intent: SelectChannelIntent.self, provider: SubWidgetIntentTimelineProvider(), content: { (entry) in
                SubscriberCountEntryView(entry: entry)
            })
            .configurationDisplayName("Subscriber Count")
            .description("View your YouTube subscriber count in realtime")
            .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
        } else {
            return IntentConfiguration(kind: kind, intent: SelectChannelIntent.self, provider: SubWidgetIntentTimelineProvider(), content: { (entry) in
                SubscriberCountEntryView(entry: entry)
            })
            .configurationDisplayName("Subscriber Count")
            .description("View your YouTube subscriber count in realtime")
            .supportedFamilies([.systemSmall, .systemMedium])
        }
    }
}
