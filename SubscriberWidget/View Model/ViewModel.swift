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
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var singleChannelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
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
    @Published var isMigratedUser = false
    @Published var networkError = false

    var appVersion: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    var color: UIColor? {
        try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backgroundColor)
    }
    
    let storage: Storage<String, YouTubeChannel>?

    init() {
        let diskConfig = DiskConfig(name: "SubWidget", expiry: .seconds(1200))
        let memoryConfig = MemoryConfig(expiry: .seconds(1200))
        
        self.storage = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: YouTubeChannel.self)
        )
        
        Task { try? await self.fetchAndUpdateChannelData() }
    }
    
    func tryInitAgain() {
        if isLoading {
            return
        }
        
        networkError = false
        isLoading = true
        // Wait one second to avoid spamming retries
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                try await self.fetchAndUpdateChannelData()
            }
        }
    }
    
    private func fetchAndUpdateChannelData() async throws {
        do {
            // Only fetch all channels when inside the app
            guard Utils.isInApp() else {
                return
            }
            
            guard
                var decodedChannels = try? JSONDecoder().decode([YouTubeChannel].self, from: channelData),
                !decodedChannels.isEmpty
            else {
                    guard let channelId = try? JSONDecoder().decode(String.self, from: singleChannelData) else {
                    isLoading = false
                    return
                }
                
                var channel = try await getChannelDetailsFromId(for: channelId)
                if let color = color {
                    channel.bgColor = color
                }
                
                withAnimation { self.channels.append(channel) }
                isLoading = false
                isMigratedUser = true
                return
            }
            
            if let frequency = try? JSONDecoder().decode(RefreshFrequencies.self, from: refreshFrequencyData) {
                refreshFrequency = frequency
            }
            
            for i in 0..<decodedChannels.count {
                let channel = try await getChannelDetailsFromId(for: decodedChannels[i].channelId)
                decodedChannels[i].subCount = channel.subCount
            }
            
            withAnimation { self.channels = decodedChannels }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.isLoading = false
            }
        } catch {
            isLoading = false
            networkError = true
        }
    }
    
    func fetchChannels() async throws -> [YouTubeChannel] {
        guard let decodedChannels = try? JSONDecoder().decode([YouTubeChannel].self, from: channelData) else {
            guard let channelId = try? JSONDecoder().decode(String.self, from: singleChannelData) else {
                return []
            }

            var channel = try await getChannelDetailsFromId(for: channelId)
            if let color = color { channel.bgColor = color }
            return [channel]
        }

        return decodedChannels
    }

    func makeRequest<T: Decodable>(with query: String) async throws -> T {
        guard let url = URL(string: "https://www.googleapis.com/youtube/v3/\(query)&key=\(Constants.apiKey)") else {
            throw SubWidgetError.invalidURL
        }
  
        var request = URLRequest(url: url)
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
            throw SubWidgetError.serverError
        }
        
        let jsonData = try JSONDecoder().decode(Response<T>.self, from: data)
        guard let items = jsonData.items, items.count > 0 else {
            throw SubWidgetError.channelNotfound
        }

        return items[0]
    }

    func searchForChannelFromMixerno(for name: String) async throws -> YouTubeChannel {
        guard let url = URL(string: "https://mixerno.space/api/youtube-channel-counter/search/\(name)") else {
            throw SubWidgetError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
            throw SubWidgetError.serverError
        }
        
        let jsonData = try JSONDecoder().decode(MixernoSearch.self, from: data)
        guard let id = jsonData.list.first?.last else {
            throw SubWidgetError.channelNotfound
        }
        
        return try await getChannelDetailsFromId(for: id)
    }
    
    func getChannelDetailsFromChannelName(for name: String) async throws -> YouTubeChannel {
        let channelNameWithoutSpaces = name.replacingOccurrences(of: " ", with: "%20")
        do {
            return try await searchForChannelFromMixerno(for: channelNameWithoutSpaces)
        } catch let error {
            print(error)
            let query = "search?part=snippet&q=\(channelNameWithoutSpaces)&type=channel"
            let channel: Channel = try await makeRequest(with: query)
            let subCount = try await getSubCount(channelId: channel.channelId)
            return YouTubeChannel(
                channelName: channel.channelName,
                profileImage: channel.profileImage,
                subCount: subCount,
                channelId: channel.channelId
            )
        }
    }
    
    func getChannelDetailsFromMixerno(for id: String) async throws -> YouTubeChannel {
        guard let url = URL(string: "https://mixerno.space/api/youtube-channel-counter/user/\(id)") else {
            throw SubWidgetError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
            throw SubWidgetError.serverError
        }
        
        let jsonData = try JSONDecoder().decode(Mixerno.self, from: data)
        guard let name = jsonData.user.first(where: { $0.value == "name" })?.count,
              let image = jsonData.user.first(where: { $0.value == "pfp" })?.count,
              let count = jsonData.counts.first(where: { $0.value == "apisubscribers" })?.count else {
            throw SubWidgetError.channelNotfound
        }
        
        return YouTubeChannel(
            channelName: name,
            profileImage: image,
            subCount: String(count),
            channelId: id
        )
    }

    func getChannelDetailsFromId(for id: String) async throws -> YouTubeChannel {
        try? storage?.removeExpiredObjects()
        
        let idWithoutSpaces = id.replacingOccurrences(of: " ", with: "")
        
        if let cachedChannel = try? storage?.object(forKey: idWithoutSpaces) {
            return cachedChannel
        }
        
        do {
            let channelFromMixerno = try await getChannelDetailsFromMixerno(for: idWithoutSpaces)
            try storage?.setObject(channelFromMixerno, forKey: idWithoutSpaces)
            return channelFromMixerno
        } catch {
            let query = "channels?part=snippet&id=\(idWithoutSpaces)"
            let channelData: ChannelID = try await makeRequest(with: query)
            let subCount = try await getSubCount(channelId: channelData.channelId)
            let channelFromGoogle = YouTubeChannel(
                channelName: channelData.channelName,
                profileImage: channelData.profileImage,
                subCount: subCount,
                channelId: channelData.channelId
            )
            
            try storage?.setObject(channelFromGoogle, forKey: idWithoutSpaces)
            return channelFromGoogle
        }
    }

    private func getSubCount(channelId: String) async throws -> String {
        let query = "channels?part=statistics&id=\(channelId)"
        let subData: Subscribers = try await makeRequest(with: query)
        return subData.subscriberCount
    }
    
    func addNewChannel() async throws {
        let channel = try await getChannelDetailsFromId(for: "UC-lHJZR3Gqxm24_Vd_AJ5Yw")
        withAnimation { channels.append(channel) }
    }
    
    func updateColorForChannel(id: String, color: UIColor?) {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            channels[index].bgColor = color
        }
    }
    
    func updateChannel(id: String, name: String) async throws -> YouTubeChannel {
        if let index = channels.firstIndex(where: { $0.id == id }) {
            let channel = try await getChannelDetailsFromChannelName(for: name)
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

struct Mixerno: Codable {
    let counts: [Count]
    let user: [User]
}

struct Count: Codable {
    let value: String
    let count: Int
}

struct User: Codable {
    let value: String
    let count: String
}

struct MixernoSearch: Codable {
    let list: [[String]]
}
