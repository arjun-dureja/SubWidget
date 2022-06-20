//
//  FAQItem.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-19.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import Foundation

struct FAQItem: Identifiable, Decodable {
    let question: String
    let answer: String
    var id: String { question }
}
