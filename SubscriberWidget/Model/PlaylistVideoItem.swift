//
//  PlaylistVideoItem.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import Foundation

struct PlaylistVideoItem: Decodable {
    var videoId = ""

    enum CodingKeys: String, CodingKey {
        case contentDetails
        case videoId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contentDetailsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .contentDetails)
        videoId = try contentDetailsContainer.decode(String.self, forKey: .videoId)
    }
}
