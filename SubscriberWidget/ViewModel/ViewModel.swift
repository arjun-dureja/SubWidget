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
            channels = try await getChannelsWithUpdatedSubCounts()
            state = .loaded
        } catch {
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
        let channel = try await youtubeService.getChannelDetailsFromId(
            for: YouTubeChannel.preview.channelId
        )
        
        channels.append(channel)
    }
    
    func updateColorForChannel(id: String, color: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].bgColor = color
        }
    }
    
    func updateChannel(id: String, name: String) async throws -> YouTubeChannel {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            let channel = try await youtubeService.getChannelDetailsFromChannelName(for: name)
            channels[index] = channel
            return channels[index]
        }
        
        throw SubWidgetError.channelNotfound
    }
    
    func deleteChannel(at index: Int) {
        channels.remove(at: index)
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
    
    private func getChannelsWithUpdatedSubCounts() async throws -> [YouTubeChannel] {
        var decodedChannels = channelStorageService.getChannels()
        for i in 0..<decodedChannels.count {
            let channel = try await youtubeService.getChannelDetailsFromId(for: decodedChannels[i].channelId)
            decodedChannels[i].subCount = channel.subCount
        }
        return decodedChannels
    }
}
