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

    var appVersion: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    var color: UIColor? {
        try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backgroundColor)
    }

    init() {
        Task { try? await self.fetchAndUpdateChannelData() }
    }
    
    private func fetchAndUpdateChannelData() async throws {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.isLoading = false
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

        let (data, _) = try await URLSession.shared.data(from: url)
        let jsonData = try JSONDecoder().decode(Response<T>.self, from: data)
        guard let items = jsonData.items, items.count > 0 else {
            throw SubWidgetError.channelNotfound
        }

        return items[0]
    }

    func getChannelDetailsFromChannelName(for name: String) async throws -> YouTubeChannel {
        let channelNameWithoutSpaces = name.replacingOccurrences(of: " ", with: "%20")
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

    func getChannelDetailsFromId(for id: String) async throws -> YouTubeChannel {
        let idWithoutSpaces = id.replacingOccurrences(of: " ", with: "")
        let query = "channels?part=snippet&id=\(idWithoutSpaces)"
        let channelData: ChannelID = try await makeRequest(with: query)
        let subCount = try await getSubCount(channelId: channelData.channelId)
        return YouTubeChannel(
            channelName: channelData.channelName,
            profileImage: channelData.profileImage,
            subCount: subCount,
            channelId: channelData.channelId
        )
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
        guard let faqUrl = URL(string: "https://api.npoint.io/705eb0378a484c18d135") else { throw SubWidgetError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: faqUrl)
        let jsonData = try JSONDecoder().decode([FAQItem].self, from: data)
        return jsonData
    }

    func shouldShowWhatsNew() -> Bool {
        if storedVersion != appVersion {
            storedVersion = appVersion
            return true
        }
        return false
    }
}
