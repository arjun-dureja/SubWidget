//
//  ViewModel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI

enum LoadingState {
    case loading
    case loaded
    case error
}

private enum ChannelRefreshOutcome {
    case updated(YouTubeChannel)
    case unavailable
    case unchanged
}

@MainActor
class ViewModel: ObservableObject {
    let youtubeService: YouTubeServiceProtocol
    let channelStorageService: ChannelStorageServiceProtocol
    let subscriptionService: SubscriptionServiceProtocol

    @Published var channels: [YouTubeChannel] = [] {
        didSet {
            channelStorageService.saveChannels(channels)
        }
    }

    @Published var refreshFrequency: RefreshFrequencies = .SIX_HR {
        didSet {
            channelStorageService.saveRefreshFrequency(refreshFrequency)
        }
    }

    @Published private(set) var state: LoadingState = .loading

    init(
        youtubeService: YouTubeServiceProtocol = YouTubeService(),
        channelStorageService: ChannelStorageServiceProtocol = ChannelStorageService(),
        subscriptionService: SubscriptionServiceProtocol = SubscriptionService()
    ) {
        self.youtubeService = youtubeService
        self.channelStorageService = channelStorageService
        self.subscriptionService = subscriptionService
    }

    func loadChannels() async {
        guard state != .loaded else { return }

        do {
            state = .loading

            // Check subscription/legacy access first
            _ = await subscriptionService.checkAccess()

            channels = try await getChannelsWithUpdatedStatistics()
            AnalyticsService.shared.logChannelsLoaded(channels.count, channels.map({ $0.channelName }))
            state = .loaded
        } catch {
            AnalyticsService.shared.logLoadChannelsFailed("\(error)")
            state = .error
        }
    }

    func retryLoadChannels() {
        state = .loading

        // Wait one second to avoid spamming retries
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                await self.loadChannels()
            }
        }
    }

    func loadRefreshFrequency() {
        refreshFrequency = channelStorageService.getRefreshFrequency()
    }

    func searchChannels(for name: String) async throws -> [Channel] {
        AnalyticsService.shared.logChannelSearched(name)
        return try await youtubeService.searchChannels(for: name)
    }

    func addChannel(_ channel: YouTubeChannel) -> YouTubeChannel {
        var newChannel = channel
        newChannel.id = UUID().uuidString
        channels.append(newChannel)
        return newChannel
    }

    func updateBgColorForChannel(id: String, color: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].bgColor = color
        }
    }

    func updateAccentColorForChannel(id: String, color: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].accentColor = color
        }
    }

    func updateNumberColorForChannel(id: String, color: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].numberColor = color
        }
    }

    func updateColorsForChannel(id: String, bgColor: UIColor?, accentColor: UIColor?, numberColor: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].bgColor = bgColor
            channels[index].accentColor = accentColor
            channels[index].numberColor = numberColor
        }
    }

    func resetAllColors(id: String) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].bgColor = nil
            channels[index].accentColor = nil
            channels[index].numberColor = nil
        }
    }

    func updateMilestoneSettings(id: String, enabled: Bool) {
        guard let channelId = channels.first(where: { $0.id == id })?.channelId else {
            return
        }

        for index in channels.indices where channels[index].channelId == channelId {
            channels[index].milestoneEnabled = enabled
        }
    }

    func deleteChannel(at index: Int) {
        let deletedChannel = channels.remove(at: index)

        let hasRemainingCopies = channels.contains { $0.channelId == deletedChannel.channelId }
        if !hasRemainingCopies {
            MilestoneNotificationService.shared.clearLastKnownSubCount(for: deletedChannel.channelId)
        }

        AnalyticsService.shared.logChannelDeleted(deletedChannel.channelName)
    }

    func deleteChannel(_ channel: YouTubeChannel) {
        if let index = channels.firstIndex(where: { $0.id == channel.id }) {
            deleteChannel(at: index)
        }
    }

    func shouldShowWhatsNew() -> Bool {
        // Version 2.1.1 - No whats new view
        return false

        // Lockscreen widgets are only available on iPhone
        //        if UIDevice.current.userInterfaceIdiom == .phone {
        //            if storedVersion != appVersion {
        //                storedVersion = appVersion
        //                return true
        //            }
        //        }
        //        return false
    }

    private func getChannelsWithUpdatedStatistics() async throws -> [YouTubeChannel] {
        try await withThrowingTaskGroup(of: (Int, ChannelRefreshOutcome).self) { group in
            var decodedChannels = channelStorageService.getChannels()
            for (index, channel) in decodedChannels.enumerated() {
                group.addTask {
                    do {
                        let updatedChannel = try await self.youtubeService.getChannelDetailsFromId(for: channel.channelId)
                        return (index, .updated(updatedChannel))
                    } catch SubWidgetError.channelNotfound {
                        return (index, .unavailable)
                    } catch let DecodingError.keyNotFound(key, context) {
                        // Skip any channels that failed to decode instead of showing an error message
                        AnalyticsService.shared.logChannelDetailsKeyNotFound(
                            "\(key)",
                            context.debugDescription,
                            channel.channelName,
                            channel.channelId
                        )
                        return (index, .unchanged)
                    } catch {
                        throw error
                    }
                }
            }

            var unavailableIndexes = Set<Int>()

            for try await (index, outcome) in group {
                switch outcome {
                case .updated(let updatedChannel):
                    decodedChannels[index].subCount = updatedChannel.subCount
                    decodedChannels[index].viewCount = updatedChannel.viewCount
                    decodedChannels[index].profileImage = updatedChannel.profileImage
                case .unavailable:
                    unavailableIndexes.insert(index)
                case .unchanged:
                    break
                }
            }

            return decodedChannels.enumerated().compactMap { index, channel in
                unavailableIndexes.contains(index) ? nil : channel
            }
        }
    }
}
