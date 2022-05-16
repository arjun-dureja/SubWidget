//
//  Response.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    var items: [T]?

    enum CodingKeys: String, CodingKey {
        case items
    }

    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.items = try container.decode([T].self, forKey: .items)
    }
}
