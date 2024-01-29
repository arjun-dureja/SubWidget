//
//  ChannelStorageServiceProtocol.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-21.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

protocol ChannelStorageServiceProtocol {
    func getChannels() -> [YouTubeChannel]

    func saveChannels(_ channels: [YouTubeChannel])

    func getRefreshFrequency() -> RefreshFrequencies

    func saveRefreshFrequency(_ frequency: RefreshFrequencies)
}
