//
//  View+Extensions.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2026-02-02.
//  Copyright © 2026 Arjun Dureja. All rights reserved.
//

import SwiftUI
import RevenueCatUI
import Foundation

extension Notification.Name {
    static let revenueCatPurchaseCompleted = Notification.Name("revenueCatPurchaseCompleted")
    static let paywallRequested = Notification.Name("paywallRequested")
}

extension View {
    func paywallSheet(isPresented: Binding<Bool>) -> some View {
        self.sheet(isPresented: isPresented) {
            NavigationView {
                PaywallView()
                    .onPurchaseCompleted { _, _ in
                        AnalyticsService.shared.logSubscriptionPurchaseCompleted()
                        Task { await SubscriptionService().checkAccess() }
                        NotificationCenter.default.post(name: .revenueCatPurchaseCompleted, object: nil)
                    }
                    .onRestoreCompleted { customerInfo in
                        Task { await SubscriptionService().checkAccess() }
                        if customerInfo.entitlements[Constants.revenueCatEntitlementId]?.isActive ?? false {
                            AnalyticsService.shared.logSubscriptionRestoreSucceeded()
                            NotificationCenter.default.post(name: .revenueCatPurchaseCompleted, object: nil)
                        }
                    }
            }
        }
    }
}
