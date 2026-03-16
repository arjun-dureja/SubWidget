//
//  ChannelUploads.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import Foundation

struct ChannelUploads: Decodable {
    var uploadsPlaylistId = ""

    enum CodingKeys: String, CodingKey {
        case contentDetails
        case relatedPlaylists
        case uploads
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contentDetailsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .contentDetails)
        let relatedPlaylistsContainer = try contentDetailsContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .relatedPlaylists
        )

        uploadsPlaylistId = try relatedPlaylistsContainer.decode(String.self, forKey: .uploads)
    }
}
