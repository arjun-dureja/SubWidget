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
            channel: .preview
        )
    }
    
    func getSnapshot(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            let channelStorageService = ChannelStorageService()
            
            // Determine if caller is from add widget screen or home screen
            if configuration.channel == nil {
                // Show first channel in add widget screen if exists
                let channels = channelStorageService.getChannels()
                if !channels.isEmpty {
                    let entry = SimpleEntry(
                        date: Date(),
                        configuration: ConfigurationIntent(),
                        channel: channels[0]
                    )
                    
                    completion(entry)
                }
            } else {
                let result = try await fetchChannel(
                    for: configuration.channel ?? YouTubeChannelParam.global,
                    channelStorageService: channelStorageService
                )
                
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
                let channelStorageService = ChannelStorageService()
                let refreshFrequency = channelStorageService.getRefreshFrequency().rawValue
                let result = try await fetchChannel(
                    for: configuration.channel ?? YouTubeChannelParam.global,
                    channelStorageService: channelStorageService
                )
                
                let timeline = Timeline(
                    entries: [result],
                    policy: .after(.now.advanced(by: refreshFrequency * 60))
                )
                
                completion(timeline)
            }
        }
    }
    
    private func fetchChannel(for param: YouTubeChannelParam, channelStorageService: ChannelStorageService) async throws -> SimpleEntry {
        guard let id = param.identifier else {
            throw SubWidgetError.invalidIdentifer
        }
        
        let channels = channelStorageService.getChannels()
        if let channel = channels.first(where: { $0.id == id }) {
            let youtubeService = YouTubeService()
            var updatedChannel = try await youtubeService.getChannelDetailsFromId(for: channel.channelId)
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
        return IntentConfiguration(kind: kind, intent: SelectChannelIntent.self, provider: SubWidgetIntentTimelineProvider(), content: { (entry) in
            SubscriberCountEntryView(entry: entry)
        })
        .configurationDisplayName("Subscriber Count")
        .description("View your YouTube subscriber count in realtime")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}
