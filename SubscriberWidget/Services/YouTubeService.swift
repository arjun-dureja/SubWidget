//
//  YouTubeService.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-15.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import Foundation
import Cache

class YouTubeService: YouTubeServiceProtocol {
    let baseUrl = "https://www.googleapis.com/youtube/v3/"
    let storage: Storage<String, YouTubeChannel>?

    init() {
        let diskConfig = DiskConfig(name: "SubWidget", expiry: .seconds(600))
        let memoryConfig = MemoryConfig(expiry: .seconds(600))

        self.storage = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: YouTubeChannel.self)
        )
    }

    func searchChannels(for name: String) async throws -> [Channel] {
        let trimmedInput = name.trimmingCharacters(in: .whitespaces)

        // If input looks like a channel ID (starts with UC and is 24 chars), try direct lookup
        if trimmedInput.hasPrefix("UC") && trimmedInput.count == 24 {
            let channel = try await getChannelDetailsFromId(for: trimmedInput)
            var searchResult = Channel(
                channelName: channel.channelName,
                profileImage: channel.profileImage
            )
            searchResult.channelId = channel.channelId
            return [searchResult]
        }

        // If input starts with @, try handle lookup directly
        if trimmedInput.hasPrefix("@") {
            let channel = try await getChannelDetailsFromHandle(for: trimmedInput)
            var searchResult = Channel(
                channelName: channel.channelName,
                profileImage: channel.profileImage
            )
            searchResult.channelId = channel.channelId
            return [searchResult]
        }

        // Try search endpoint
        let channelNameWithoutSpaces = name.replacingOccurrences(of: " ", with: "%20")
        let query = "search?part=snippet&q=\(channelNameWithoutSpaces)&type=channel&maxResults=50"

        let items: [Channel] = try await makeRequest(with: query)

        if !items.isEmpty {
            return items
        }

        // If no results, try handle lookup as fallback
        if let channel = try? await getChannelDetailsFromHandle(for: trimmedInput) {
            var searchResult = Channel(
                channelName: channel.channelName,
                profileImage: channel.profileImage
            )
            searchResult.channelId = channel.channelId
            return [searchResult]
        }

        throw SubWidgetError.channelNotfound
    }

    func getChannelDetailsFromId(for id: String) async throws -> YouTubeChannel {
        try? storage?.removeExpiredObjects()

        let idWithoutSpaces = id.replacingOccurrences(of: " ", with: "")

        if let cachedChannel = try? storage?.object(forKey: idWithoutSpaces),
           cachedChannel.viewCount != nil {
            return cachedChannel
        }

        let query = "channels?part=snippet&id=\(idWithoutSpaces)"
        let items: [ChannelID] = try await makeRequest(with: query)
        guard let channelData = items.first else {
            throw SubWidgetError.channelNotfound
        }

        let (subCount, viewCount) = try await getStatistics(channelId: channelData.channelId)
        let channelFromGoogle = YouTubeChannel(
            channelName: channelData.channelName,
            profileImage: channelData.profileImage,
            subCount: subCount,
            viewCount: viewCount,
            channelId: channelData.channelId
        )

        try storage?.setObject(channelFromGoogle, forKey: idWithoutSpaces)
        return channelFromGoogle
    }

    private func getChannelDetailsFromHandle(for handle: String) async throws -> YouTubeChannel {
        let handleWithoutSpaces = handle.replacingOccurrences(of: " ", with: "")
        let query = "channels?part=snippet&forHandle=\(handleWithoutSpaces)"

        let items: [ChannelID] = try await makeRequest(with: query)
        guard let channelData = items.first else {
            throw SubWidgetError.channelNotfound
        }

        let (subCount, viewCount) = try await getStatistics(channelId: channelData.channelId)
        return YouTubeChannel(
            channelName: channelData.channelName,
            profileImage: channelData.profileImage,
            subCount: subCount,
            viewCount: viewCount,
            channelId: channelData.channelId
        )
    }

    private func getStatistics(channelId: String) async throws -> (String, String) {
        let query = "channels?part=statistics&id=\(channelId)"
        let items: [Statistics] = try await makeRequest(with: query)
        guard let channelStatistics = items.first else {
            throw SubWidgetError.channelNotfound
        }
        return (channelStatistics.subscriberCount, channelStatistics.viewCount)
    }

    private func makeUrl(query: String) throws -> URL {
        guard let url = URL(string: "\(baseUrl)\(query)&key=\(Constants.apiKey)") else {
            throw SubWidgetError.invalidURL
        }

        return url
    }

    private func makeRequest<T: Decodable>(with query: String) async throws -> [T] {
        let url = try makeUrl(query: query)

        var request = URLRequest(url: url)
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
            throw SubWidgetError.serverError
        }

        let jsonData = try JSONDecoder().decode(Response<T>.self, from: data)
        return jsonData.items ?? []
    }

}
