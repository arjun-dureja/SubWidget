//
//  Subscribers.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

struct Subscribers: Decodable, Identifiable {
    let id = UUID()
    var subscriberCount = ""
    
    enum CodingKeys: String, CodingKey {
        case statistics
        case subscriberCount
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        
        self.subscriberCount = try statisticsContainer.decode(String.self, forKey: .subscriberCount)
    }
    
    init (subCount: String) {
        self.subscriberCount = subCount
    }
}
