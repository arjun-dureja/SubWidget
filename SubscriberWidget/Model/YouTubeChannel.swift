//
//  YouTubeChannel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

struct YouTubeChannel: Identifiable, Codable {
    let channelName: String
    let profileImage: String
    let subCount: String
    let channelId: String
    var id = UUID()
}
