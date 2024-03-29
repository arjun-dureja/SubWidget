//
//  YouTubeChannel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation
import UIKit

struct YouTubeChannel: Identifiable, Codable, Hashable {

    private enum CodingKeys: String, CodingKey {
        case channelName, profileImage, subCount, viewCount, channelId, bgColor, accentColor, numberColor, id
    }

    var channelName: String
    var profileImage: String
    var subCount: String
    var viewCount: String?
    var channelId: String
    var bgColor: UIColor?
    var accentColor: UIColor?
    var numberColor: UIColor?
    var id = UUID().uuidString

    var deeplinkUrl: URL? {
        return URL(string: "subwidget://\(channelId)")
    }

    init(
        channelName: String,
        profileImage: String,
        subCount: String,
        viewCount: String? = "0",
        channelId: String,
        bgColor: UIColor? = nil,
        accentColor: UIColor? = nil,
        numberColor: UIColor? = nil
    ) {
        self.channelName = channelName
        self.profileImage = profileImage
        self.subCount = subCount
        self.viewCount = viewCount
        self.channelId = channelId
        self.bgColor = bgColor
        self.accentColor = accentColor
        self.numberColor = numberColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        channelName = try container.decode(String.self, forKey: .channelName)
        profileImage = try container.decode(String.self, forKey: .profileImage)
        subCount = try container.decode(String.self, forKey: .subCount)
        viewCount = try? container.decode(String.self, forKey: .viewCount)
        channelId = try container.decode(String.self, forKey: .channelId)
        bgColor = try? container.decode(CustomColor.self, forKey: .bgColor).uiColor
        accentColor = try? container.decode(CustomColor.self, forKey: .accentColor).uiColor
        numberColor = try? container.decode(CustomColor.self, forKey: .numberColor).uiColor
        id = try container.decode(String.self, forKey: .id)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channelName, forKey: .channelName)
        try container.encode(profileImage, forKey: .profileImage)
        try container.encode(subCount, forKey: .subCount)
        try container.encode(viewCount, forKey: .viewCount)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(bgColor != nil ? CustomColor(uiColor: bgColor) : nil, forKey: .bgColor)
        try container.encode(accentColor != nil ? CustomColor(uiColor: accentColor) : nil, forKey: .accentColor)
        try container.encode(numberColor != nil ? CustomColor(uiColor: numberColor) : nil, forKey: .numberColor)
        try container.encode(id, forKey: .id)
    }

    static var preview: YouTubeChannel {
        YouTubeChannel(
            channelName: "PewDiePie",
            profileImage: "https://yt3.ggpht.com/ytc/AAUvwnga3eXKkQgGU-3j1_jccZ0K9m6MbjepV0ksd7eBEw=s800-c-k-c0x00ffffff-no-rj",
            subCount: "1000000",
            viewCount: "100000000000",
            channelId: "UC-lHJZR3Gqxm24_Vd_AJ5Yw"
        )
    }
}

struct CustomColor: Codable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor: UIColor?) {
        uiColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
