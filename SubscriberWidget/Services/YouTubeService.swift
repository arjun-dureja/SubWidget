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

    func getChannelDetailsFromChannelName(for name: String) async throws -> YouTubeChannel {
        let channelNameWithoutSpaces = name.replacingOccurrences(of: " ", with: "%20")
        let query = "search?part=snippet&q=\(channelNameWithoutSpaces)&type=channel"
        let channel: Channel = try await makeRequest(with: query)
        return try await getChannelDetailsFromId(for: channel.channelId)
    }

    func getChannelDetailsFromId(for id: String) async throws -> YouTubeChannel {
        try? storage?.removeExpiredObjects()

        let idWithoutSpaces = id.replacingOccurrences(of: " ", with: "")

        if let cachedChannel = try? storage?.object(forKey: idWithoutSpaces) {
            return cachedChannel
        }

        let query = "channels?part=snippet&id=\(idWithoutSpaces)"
        let channelData: ChannelID = try await makeRequest(with: query)
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

    private func getStatistics(channelId: String) async throws -> (String, String) {
        let query = "channels?part=statistics&id=\(channelId)"
        let channelStatistics: Statistics = try await makeRequest(with: query)
        return (channelStatistics.subscriberCount, channelStatistics.viewCount)
    }

    private func makeUrl(query: String) throws -> URL {
        guard let url = URL(string: "\(baseUrl)\(query)&key=\(Constants.apiKey)") else {
            throw SubWidgetError.invalidURL
        }

        return url
    }

    private func makeRequest<T: Decodable>(with query: String) async throws -> T {
        let url = try makeUrl(query: query)

        var request = URLRequest(url: url)
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
            throw SubWidgetError.serverError
        }

        let jsonData = try JSONDecoder().decode(Response<T>.self, from: data)
        guard let items = jsonData.items, !items.isEmpty else {
            throw SubWidgetError.channelNotfound
        }

        return items[0]
    }

}
