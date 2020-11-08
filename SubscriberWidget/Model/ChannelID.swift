//
//  Channel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-11-06.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

struct ChannelID: Decodable, Identifiable {
    var id = UUID()
    var channelId = ""
    var channelName = ""
    var profileImage = ""
    
    enum CodingKeys: String, CodingKey {
        case channelId = "id"
        case snippet
        case thumbnails
        case high
        
        case channelName = "title"
        case profileImage = "url"
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.channelId = try container.decode(String.self, forKey: .channelId)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        
        self.channelName = try snippetContainer.decode(String.self, forKey: .channelName)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        
        self.profileImage = try highContainer.decode(String.self, forKey: .profileImage)
        
    }
    
    init (channelName: String, profileImage: String) {
        self.channelName = channelName
        self.profileImage = profileImage
    }
}

