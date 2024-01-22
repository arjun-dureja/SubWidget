//
//  YouTubeServiceProtocol.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-21.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import Foundation

protocol YouTubeServiceProtocol {
    func makeUrl(query: String) throws -> URL
    
    func makeRequest<T: Decodable>(with query: String) async throws -> T
    
    func getChannelDetailsFromChannelName(for name: String) async throws -> YouTubeChannel
    
    func getChannelDetailsFromId(for id: String) async throws -> YouTubeChannel
    
    func getSubCount(channelId: String) async throws -> String
}
