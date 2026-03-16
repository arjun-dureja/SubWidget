//
//  LatestUploadVideo.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import Foundation

struct LatestUploadVideo: Codable, Hashable {
    var videoId = ""
    var title = ""
    var thumbnailUrl = ""
    var viewCount = "0"
    var likeCount: String?
    var commentCount: String?
    var publishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case snippet
        case statistics
        case title
        case thumbnails
        case maxres
        case standard
        case high
        case medium
        case `default`
        case url
        case publishedAt
        case viewCount
        case likeCount
        case commentCount
    }

    init(
        videoId: String,
        title: String,
        thumbnailUrl: String,
        viewCount: String,
        likeCount: String?,
        commentCount: String?,
        publishedAt: Date?
    ) {
        self.videoId = videoId
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.publishedAt = publishedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videoId = try container.decode(String.self, forKey: .id)

        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        title = try snippetContainer.decode(String.self, forKey: .title)

        let publishedAtString = try? snippetContainer.decode(String.self, forKey: .publishedAt)
        if let publishedAtString {
            publishedAt = ISO8601DateFormatter().date(from: publishedAtString)
        } else {
            publishedAt = nil
        }

        let thumbnailsContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        thumbnailUrl =
            (try? thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .maxres).decode(String.self, forKey: .url))
            ?? (try? thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .standard).decode(String.self, forKey: .url))
            ?? (try? thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high).decode(String.self, forKey: .url))
            ?? (try? thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .medium).decode(String.self, forKey: .url))
            ?? (try? thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .default).decode(String.self, forKey: .url))
            ?? ""

        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        viewCount = try statisticsContainer.decode(String.self, forKey: .viewCount)
        likeCount = try? statisticsContainer.decode(String.self, forKey: .likeCount)
        commentCount = try? statisticsContainer.decode(String.self, forKey: .commentCount)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoId, forKey: .id)

        var snippetContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        try snippetContainer.encode(title, forKey: .title)
        try snippetContainer.encodeIfPresent(
            publishedAt.map { ISO8601DateFormatter().string(from: $0) },
            forKey: .publishedAt
        )

        var thumbnailsContainer = snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        var highContainer = thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        try highContainer.encode(thumbnailUrl, forKey: .url)

        var statisticsContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        try statisticsContainer.encode(viewCount, forKey: .viewCount)
        try statisticsContainer.encodeIfPresent(likeCount, forKey: .likeCount)
        try statisticsContainer.encodeIfPresent(commentCount, forKey: .commentCount)
    }

    var deeplinkUrl: URL? {
        URL(string: "subwidget://video/\(videoId)")
    }

    static var preview: LatestUploadVideo {
        LatestUploadVideo(
            videoId: "dQw4w9WgXcQ",
            title: "How I Built SubWidget in a Weekend",
            thumbnailUrl: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
            viewCount: "124800",
            likeCount: "8300",
            commentCount: "540",
            publishedAt: .now.addingTimeInterval(-(60 * 60 * 26))
        )
    }

    static var placeholder: LatestUploadVideo {
        LatestUploadVideo(
            videoId: "",
            title: "Latest Upload",
            thumbnailUrl: "",
            viewCount: "0",
            likeCount: "0",
            commentCount: "0",
            publishedAt: nil
        )
    }
}
