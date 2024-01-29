//
//  YouTubeServiceProtocol.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-21.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import Foundation

protocol YouTubeServiceProtocol {
    func getChannelDetailsFromChannelName(for name: String) async throws -> YouTubeChannel

    func getChannelDetailsFromId(for id: String) async throws -> YouTubeChannel
}
