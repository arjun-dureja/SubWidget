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
    case subscribers, views, combined
}

struct SimpleEntry: TimelineEntry {
    let date: Date = Date()
    let channel: YouTubeChannel?
    let channelImage: UIImage
    let widgetType: WidgetType

    init(
        channel: YouTubeChannel?,
        channelImage: UIImage = UIImage(systemName: "person.circle")!,
        widgetType: WidgetType
    ) {
        self.channel = channel
        self.channelImage = channelImage
        self.widgetType = widgetType
    }
}

private enum WidgetDeepLink {
    static func paywall(source: String) -> URL? {
        var components = URLComponents()
        components.scheme = "subwidget"
        components.host = "paywall"
        components.queryItems = [URLQueryItem(name: "source", value: source)]
        return components.url
    }
}

struct SubWidgetIntentTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = SelectChannelAppIntent

    let widgetType: WidgetType

    private var retryPolicy: TimelineReloadPolicy {
        .after(.now.advanced(by: 15 * 60))
    }

    func placeholder(in context: Context) -> SimpleEntry {
        // Arbitrary channel for placeholder - will show as redacted
        return SimpleEntry(
            channel: .preview,
            widgetType: widgetType
        )
    }

    func snapshot(for configuration: SelectChannelAppIntent, in context: Context) async -> SimpleEntry {
        let channelStorageService = ChannelStorageService()

        // Determine if caller is from add widget screen or home screen
        if configuration.channel == nil {
            // Show first channel in add widget screen if exists
            let channels = channelStorageService.getChannels()
            if channels.isEmpty {
                return SimpleEntry(
                    channel: nil,
                    widgetType: widgetType
                )
            } else {
                return SimpleEntry(
                    channel: channels[0],
                    channelImage: await getImageForUrl(channels[0].profileImage),
                    widgetType: widgetType
                )
            }
        }

        return await fetchChannel(
            for: configuration.channel,
            channelStorageService: channelStorageService
        )
    }

    func timeline(for configuration: SelectChannelAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let channelStorageService = ChannelStorageService()
        let refreshFrequency = channelStorageService.getRefreshFrequency().rawValue

        // Determine if user has already selected a channel or not
        if configuration.channel == nil {
            return Timeline(
                entries: [
                    SimpleEntry(
                        channel: nil,
                        widgetType: widgetType
                    )
                ],
                policy: retryPolicy
            )
        } else {
            let result = await fetchChannel(
                for: configuration.channel,
                channelStorageService: channelStorageService
            )

            return Timeline(
                entries: [result],
                policy: result.channel == nil
                    ? retryPolicy
                    : .after(.now.advanced(by: refreshFrequency * 60))
            )
        }
    }

    private func fetchChannel(
        for channelEntity: YouTubeChannelParam?,
        channelStorageService: ChannelStorageService
    ) async -> SimpleEntry {
        do {
            guard let id = channelEntity?.identifier else {
                throw SubWidgetError.invalidIdentifer
            }

            let channels = channelStorageService.getChannels()
            if let channel = channels.first(where: { $0.id == id }) {
                let youtubeService = YouTubeService()
                var updatedChannel = try await youtubeService.getChannelDetailsFromId(for: channel.channelId)
                updatedChannel.bgColor = channel.bgColor
                updatedChannel.accentColor = channel.accentColor
                updatedChannel.numberColor = channel.numberColor
                updatedChannel.milestoneEnabled = channel.milestoneEnabled

                if channel.milestoneEnabled {
                    await MilestoneNotificationService.shared.checkAndNotifyMilestone(channel: updatedChannel)
                }

                return SimpleEntry(
                    channel: updatedChannel,
                    channelImage: await getImageForUrl(updatedChannel.profileImage),
                    widgetType: widgetType
                )
            }
        } catch {
            AnalyticsService.shared.logWidgetChannelFetchFailed(error.localizedDescription)
        }

        return SimpleEntry(
            channel: nil,
            widgetType: widgetType
        )
    }

    private func getImageForUrl(_ urlString: String) async -> UIImage {
        guard let url = URL(string: urlString) else {
            return UIImage(systemName: "person.circle")!
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            return downsampleImage(from: data, to: CGSize(width: 200, height: 200))
                ?? UIImage(systemName: "person.circle")!

        } catch {
            AnalyticsService.shared.logWidgetImageFetchFailed(
                url: url.absoluteString,
                error: error.localizedDescription
            )
        }

        return UIImage(systemName: "person.circle")!
    }

    private func downsampleImage(from data: Data, to size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return nil
        }

        let maxDimension = max(size.width, size.height)

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            downsampleOptions as CFDictionary
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

struct SubscriberCountEntryView: View {
    var entry: SubWidgetIntentTimelineProvider.Entry
    @Environment(\.widgetFamily) private var widgetFamily
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false

    private var isPreview: Bool {
        entry.channel?.channelName == "SubWidgetPrev"
    }

    private var isLocked: Bool {
        guard entry.channel != nil else { return false }
        guard !hasProAccess else { return false }
        guard !isPreview else { return false }
        return isProOnlyWidgetKind
    }

    private var isProOnlyWidgetKind: Bool {
        switch widgetFamily {
        case .systemSmall:
            return entry.widgetType != .subscribers
        case .accessoryRectangular:
            return true
        default:
            return true
        }
    }

    private var widgetTypeString: String {
        return "\(entry.widgetType.rawValue)_\(widgetFamily.description)"
    }

    private var deepLink: URL? {
        if !hasProAccess {
            return WidgetDeepLink.paywall(source: isProOnlyWidgetKind ? "widget_locked" : "widget_free")
        }

        guard let baseUrl = entry.channel?.deeplinkUrl else { return nil }
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        let queryItem = URLQueryItem(name: "widgetType", value: widgetTypeString)
        components?.queryItems = [queryItem]
        return components?.url
    }

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                if isLocked {
                    LockedWidgetContainer {
                        SmallWidget(entry: entry)
                    }
                } else {
                    SmallWidget(entry: entry)
                }
            case .accessoryRectangular:
                if isLocked {
                    LockedLockscreenWidget()
                } else {
                    LockscreenWidget(entry: entry)
                }
            default:
                if isLocked {
                    LockedWidgetContainer {
                        MediumWidget(entry: entry)
                    }
                } else {
                    MediumWidget(entry: entry)
                }
            }
        }
        .widgetURL(isPreview ? nil : deepLink)
    }
}
