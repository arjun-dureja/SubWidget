//
//  LatestUploadTimelineProvider.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import Foundation
import WidgetKit
import SwiftUI

struct LatestUploadEntry: TimelineEntry {
    let date: Date = Date()
    let configuration: ConfigurationIntent = ConfigurationIntent()
    let channel: YouTubeChannel?
    let latestUpload: LatestUploadVideo?
    let thumbnailImage: UIImage

    init(
        channel: YouTubeChannel?,
        latestUpload: LatestUploadVideo?,
        thumbnailImage: UIImage = UIImage(systemName: "play.rectangle.fill") ?? UIImage()
    ) {
        self.channel = channel
        self.latestUpload = latestUpload
        self.thumbnailImage = thumbnailImage
    }
}

private enum LatestUploadDeepLink {
    static let paywall = URL(string: "subwidget://paywall")
}

struct LatestUploadTimelineProvider: IntentTimelineProvider {
    typealias Entry = LatestUploadEntry
    typealias Intent = SelectChannelIntent

    func placeholder(in context: Context) -> LatestUploadEntry {
        LatestUploadEntry(
            channel: .preview,
            latestUpload: .preview
        )
    }

    func getSnapshot(
        for configuration: SelectChannelIntent,
        in context: Context,
        completion: @escaping (LatestUploadEntry) -> Void
    ) {
        Task {
            let channelStorageService = ChannelStorageService()

            if configuration.channel == nil {
                let channels = channelStorageService.getChannels()
                guard let firstChannel = channels.first else {
                    completion(LatestUploadEntry(channel: nil, latestUpload: nil))
                    return
                }

                completion(await fetchLatestUpload(for: firstChannel))
            } else {
                completion(
                    await fetchLatestUpload(
                        for: configuration.channel ?? YouTubeChannelParam.global,
                        channelStorageService: channelStorageService
                    )
                )
            }
        }
    }

    func getTimeline(
        for configuration: SelectChannelIntent,
        in context: Context,
        completion: @escaping (Timeline<LatestUploadEntry>) -> Void
    ) {
        if configuration.channel == nil {
            let timeline = Timeline(
                entries: [LatestUploadEntry(channel: nil, latestUpload: nil)],
                policy: .never
            )

            completion(timeline)
        } else {
            Task {
                let channelStorageService = ChannelStorageService()
                let refreshFrequency = channelStorageService.getRefreshFrequency().rawValue
                let entry = await fetchLatestUpload(
                    for: configuration.channel ?? YouTubeChannelParam.global,
                    channelStorageService: channelStorageService
                )

                completion(
                    Timeline(
                        entries: [entry],
                        policy: .after(.now.advanced(by: refreshFrequency * 60))
                    )
                )
            }
        }
    }

    private func fetchLatestUpload(
        for param: YouTubeChannelParam,
        channelStorageService: ChannelStorageService
    ) async -> LatestUploadEntry {
        guard let id = param.identifier else {
            return LatestUploadEntry(channel: nil, latestUpload: nil)
        }

        let channels = channelStorageService.getChannels()
        guard let channel = channels.first(where: { $0.id == id }) else {
            return LatestUploadEntry(channel: nil, latestUpload: nil)
        }

        return await fetchLatestUpload(for: channel)
    }

    private func fetchLatestUpload(for channel: YouTubeChannel) async -> LatestUploadEntry {
        do {
            let youtubeService = YouTubeService()
            let latestUpload = try await youtubeService.getLatestUpload(for: channel.channelId)

            return LatestUploadEntry(
                channel: channel,
                latestUpload: latestUpload,
                thumbnailImage: await WidgetImageLoader.getImageForUrl(
                    latestUpload.thumbnailUrl,
                    fallbackSystemName: "play.rectangle.fill",
                    size: CGSize(width: 400, height: 225)
                )
            )
        } catch {
            AnalyticsService.shared.logWidgetChannelFetchFailed(error.localizedDescription)
        }

        return LatestUploadEntry(
            channel: channel,
            latestUpload: nil
        )
    }
}

struct LatestUploadEntryView: View {
    var entry: LatestUploadTimelineProvider.Entry
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false

    private var isPreview: Bool {
        entry.channel?.channelName == YouTubeChannel.preview.channelName
    }

    private var isLocked: Bool {
        guard entry.channel != nil else { return false }
        guard !hasProAccess else { return false }
        guard !isPreview else { return false }
        return true
    }

    private var deepLink: URL? {
        if !hasProAccess {
            return LatestUploadDeepLink.paywall
        }

        guard let baseUrl = entry.latestUpload?.deeplinkUrl else { return nil }
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "widgetType", value: "latest_upload_medium")]
        return components?.url
    }

    var body: some View {
        Group {
            if isLocked {
                LockedWidgetContainer {
                    LatestUploadMediumWidget(entry: entry)
                }
            } else {
                LatestUploadMediumWidget(entry: entry)
            }
        }
        .widgetURL(isPreview ? nil : deepLink)
    }
}
