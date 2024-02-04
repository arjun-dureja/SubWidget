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

enum WidgetType: String {
    case subscribers, views
}

struct SimpleEntry: TimelineEntry {
    let date: Date = Date()
    let configuration: ConfigurationIntent = ConfigurationIntent()
    let channel: YouTubeChannel?
    let widgetType: WidgetType
}

struct SubWidgetIntentTimelineProvider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = SelectChannelIntent

    let widgetType: WidgetType

    func placeholder(in context: Context) -> SimpleEntry {
        // Arbitrary channel for placeholder - will show as redacted
        return SimpleEntry(
            channel: .preview,
            widgetType: widgetType
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
                        channel: channels[0],
                        widgetType: widgetType
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
                entries: [
                    SimpleEntry(
                        channel: nil,
                        widgetType: widgetType
                    )
                ],
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
            return SimpleEntry(
                channel: updatedChannel,
                widgetType: widgetType
            )
        }

        return SimpleEntry(
            channel: nil,
            widgetType: widgetType
        )
    }
}

struct SubscriberCountEntryView: View {
    var entry: SubWidgetIntentTimelineProvider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidget(entry: entry)
        case .accessoryRectangular:
            LockscreenWidget(entry: entry)
        default:
            MediumWidget(entry: entry)
        }
    }
}
