//
//  SubscriptionServiceProtocol.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2026-02-01.
//  Copyright © 2026 Arjun Dureja. All rights reserved.
//

protocol SubscriptionServiceProtocol {
    var hasProAccess: Bool { get set }

    func checkAccess() async
}
