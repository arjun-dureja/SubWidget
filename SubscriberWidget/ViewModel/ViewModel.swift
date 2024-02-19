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

@MainActor
class ViewModel: ObservableObject {
    let youtubeService: YouTubeServiceProtocol
    let channelStorageService: ChannelStorageServiceProtocol

    @Published var channels: [YouTubeChannel] = [] {
        didSet {
            channelStorageService.saveChannels(channels)
        }
    }

    @Published var refreshFrequency: RefreshFrequencies = .ONE_HR {
        didSet {
            channelStorageService.saveRefreshFrequency(refreshFrequency)
        }
    }

    @Published private(set) var state: LoadingState = .loading

    init(
        youtubeService: YouTubeServiceProtocol = YouTubeService(),
        channelStorageService: ChannelStorageServiceProtocol = ChannelStorageService()
    ) {
        self.youtubeService = youtubeService
        self.channelStorageService = channelStorageService
    }

    func loadChannels() async {
        guard state != .loaded else { return }

        do {
            state = .loading
            channels = try await getChannelsWithUpdatedStatistics()
            AnalyticsService.shared.logChannelsLoaded(channels.count)
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

    func addNewChannel() async throws {
        AnalyticsService.shared.logAddNewChannelTapped()
        var channel = try await youtubeService.getChannelDetailsFromId(
            for: YouTubeChannel.preview.channelId
        )

        // Generate a new ID in case an existing channel was returned
        channel.id = UUID().uuidString
        channels.append(channel)
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

    func updateChannel(id: String, name: String) async throws -> YouTubeChannel {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            var channel = try await youtubeService.getChannelDetailsFromChannelName(for: name)
            // Generate a new ID in case an existing channel was returned
            channel.id = UUID().uuidString
            channels[index] = channel
            AnalyticsService.shared.logChannelSearched(name)
            return channels[index]
        }

        throw SubWidgetError.channelNotfound
    }

    func deleteChannel(at index: Int) {
        let deletedChannel = channels.remove(at: index)
        AnalyticsService.shared.logChannelDeleted(deletedChannel.channelName)
    }

    func getFaq() async throws -> [FAQItem] {
        guard let faqUrl = URL(string: "https://arjundureja.com/subwidget/faq.json") else { throw SubWidgetError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: faqUrl)
        let jsonData = try JSONDecoder().decode([FAQItem].self, from: data)
        return jsonData
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
        try await withThrowingTaskGroup(of: (Int, YouTubeChannel).self) { group in
            var decodedChannels = channelStorageService.getChannels()
            for (index, channel) in decodedChannels.enumerated() {
                group.addTask {
                    let updatedChannel = try await self.youtubeService.getChannelDetailsFromId(for: channel.channelId)
                    return (index, updatedChannel)
                }
            }

            for try await (index, updatedChannel) in group {
                decodedChannels[index].subCount = updatedChannel.subCount
                decodedChannels[index].viewCount = updatedChannel.viewCount
            }

            return decodedChannels
        }
    }
}
