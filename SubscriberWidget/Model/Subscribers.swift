//
//  Subscribers.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

struct Statistics: Decodable, Identifiable {
    let id = UUID()
    var subscriberCount = ""
    var viewCount = ""

    enum CodingKeys: String, CodingKey {
        case statistics
        case subscriberCount
        case viewCount
    }

    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        self.subscriberCount = try statisticsContainer.decode(String.self, forKey: .subscriberCount)
        self.viewCount = try statisticsContainer.decode(String.self, forKey: .viewCount)
    }

    init (subCount: String, viewCount: String) {
        self.subscriberCount = subCount
        self.viewCount = viewCount
    }
}
