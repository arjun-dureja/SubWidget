//
//  ViewModel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit
import Cache

@MainActor
class ViewModel: ObservableObject {
    @AppStorage("channels", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("refreshFrequency", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var refreshFrequencyData: Data = Data()
    @AppStorage("storedVersion", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var storedVersion = ""

    @Published var channels: [YouTubeChannel] = [] {
        didSet {
            guard let encodedChannels = try? JSONEncoder().encode(channels) else { return }
            channelData = encodedChannels
        }
    }

    @Published var refreshFrequency: RefreshFrequencies = .ONE_HR {
        didSet {
            guard let encodedFrequency = try? JSONEncoder().encode(refreshFrequency) else { return }
            refreshFrequencyData = encodedFrequency
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var isLoading = true
    @Published var networkError = false
    
    init() {
        Task { await self.fetchAndUpdateChannelData() }
    }
    
    func tryInitAgain() {
        if isLoading {
            return
        }
        
        networkError = false
        isLoading = true
        // Wait one second to avoid spamming retries
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task { await self.fetchAndUpdateChannelData() }
        }
    }
    
    private func fetchAndUpdateChannelData() async {
        // Only fetch all channels when inside the app
        guard Utils.isInApp() else { return }
        
        
        do {
            refreshFrequency = (try? JSONDecoder().decode(RefreshFrequencies.self, from: refreshFrequencyData)) ?? .ONE_HR

            var decodedChannels = try JSONDecoder().decode([YouTubeChannel].self, from: channelData)
            guard !decodedChannels.isEmpty else {
                isLoading = false
                return
            }
            
            for i in 0..<decodedChannels.count {
                let channel = try await YouTubeService.shared.getChannelDetailsFromId(for: decodedChannels[i].channelId)
                decodedChannels[i].subCount = channel.subCount
            }
            
            withAnimation { self.channels = decodedChannels }
        } catch {
            networkError = true
        }
        
        isLoading = false
    }
    
    func getChannels() async throws -> [YouTubeChannel] {
        return (try? JSONDecoder().decode([YouTubeChannel].self, from: channelData)) ?? []
    }

    func addNewChannel() async throws {
        let channel = try await YouTubeService.shared.getChannelDetailsFromId(for: "UC-lHJZR3Gqxm24_Vd_AJ5Yw")
        withAnimation { channels.append(channel) }
    }
    
    func updateColorForChannel(id: String, color: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].bgColor = color
        }
    }
    
    func updateChannel(id: String, name: String) async throws -> YouTubeChannel {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            let channel = try await YouTubeService.shared.getChannelDetailsFromChannelName(for: name)
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
}
