//
//  Utils.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2026-02-16.
//  Copyright © 2026 Arjun Dureja. All rights reserved.
//

class StringUtils {
    static func getChannelUrlFromId(_ channelId: String) -> String {
        return "https://youtube.com/channel/\(channelId)"
    }

    static func getVideoUrlFromId(_ videoId: String) -> String {
        return "https://youtube.com/watch?v=\(videoId)"
    }
}
