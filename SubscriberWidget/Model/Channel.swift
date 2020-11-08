//
//  Channel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

struct Channel: Decodable, Identifiable {
    var id = UUID()
    var channelId = ""
    var channelName = ""
    var profileImage = ""
    
    enum CodingKeys: String, CodingKey {
        case snippet
        case thumbnails
        case high
        case channelId
        
        case channelName = "title"
        case profileImage = "url"
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        
        self.channelId = try snippetContainer.decode(String.self, forKey: .channelId)
        
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

