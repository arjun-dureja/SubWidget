//
//  SubscriptionService.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2026-02-01.
//  Copyright © 2026 Arjun Dureja. All rights reserved.
//

import StoreKit
import Foundation
import SwiftUI

class SubscriptionService: SubscriptionServiceProtocol {
    private let freemiumBuildNumber = 31
    private let subscriptionProductID = "com.arjundureja.SubscriberWidget.premium.yearly"

    @AppStorage("hasProAccess", store: .shared) var hasProAccess: Bool = false
    @AppStorage("isLegacyUser", store: .shared) var isLegacyUser: Bool = false

    func checkAccess() async {
        if isLegacyUser {
            hasProAccess = true
            AnalyticsService.shared.logSubscriptionAccessEvaluated(
                stage: "legacy_flag",
                hasProAccess: true,
                isLegacyUser: true
            )
            return
        }

        if await detectLegacyUser() {
            isLegacyUser = true
            hasProAccess = true
            AnalyticsService.shared.logLegacyUserDetected()
            AnalyticsService.shared.logSubscriptionAccessEvaluated(
                stage: "legacy_check",
                hasProAccess: true,
                isLegacyUser: true
            )
            return
        }

        if await checkActiveSubscriptionStatus() {
            hasProAccess = true
            AnalyticsService.shared.logActiveSubscriberDetected()
            AnalyticsService.shared.logSubscriptionAccessEvaluated(
                stage: "subscription_check",
                hasProAccess: true,
                isLegacyUser: false
            )
            return
        } else {
            hasProAccess = false
            AnalyticsService.shared.logSubscriptionAccessEvaluated(
                stage: "subscription_check",
                hasProAccess: false,
                isLegacyUser: false
            )
        }
    }

    /// Checks if user purchased the app before it went freemium
    private func detectLegacyUser() async -> Bool {
        do {
            let appTransaction = try await AppTransaction.shared

            guard case .verified(let transaction) = appTransaction else {
                AnalyticsService.shared.logLegacyUserCheck(
                    isLegacyUser: false,
                    originalBuild: nil,
                    freemiumBuildNumber: freemiumBuildNumber
                )
                return false
            }

            // originalAppVersion is the CFBundleVersion (Build number) for iOS apps
            let originalBuildString = transaction.originalAppVersion

            let originalBuild: Int?
            if let intBuild = Int(originalBuildString) {
                originalBuild = intBuild
            } else if let doubleBuild = Double(originalBuildString) {
                originalBuild = Int(doubleBuild)
            } else {
                originalBuild = nil
            }

            guard let originalBuild else {
                AnalyticsService.shared.logLegacyUserCheck(
                    isLegacyUser: false,
                    originalBuild: nil,
                    freemiumBuildNumber: freemiumBuildNumber
                )
                return false
            }

            // If they installed a build BEFORE the freemium build = legacy user
            if originalBuild < freemiumBuildNumber {
                AnalyticsService.shared.logLegacyUserCheck(
                    isLegacyUser: true,
                    originalBuild: originalBuild,
                    freemiumBuildNumber: freemiumBuildNumber
                )
                return true
            }

            // New user who downloaded the free version
            AnalyticsService.shared.logLegacyUserCheck(
                isLegacyUser: false,
                originalBuild: originalBuild,
                freemiumBuildNumber: freemiumBuildNumber
            )
            return false
        } catch {
            AnalyticsService.shared.logLegacyUserCheck(
                isLegacyUser: false,
                originalBuild: nil,
                freemiumBuildNumber: freemiumBuildNumber
            )
            return false
        }
    }

    /// Checks for active subscription entitlements
    private func checkActiveSubscriptionStatus() async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            // Only consider our subscription product
            guard transaction.productID == subscriptionProductID else { continue }

            // Check if subscription is active
            if let expirationDate = transaction.expirationDate {
                if expirationDate > Date() {
                    AnalyticsService.shared.logSubscriptionEntitlementEvaluated(
                        status: "active",
                        productId: transaction.productID,
                        expirationDate: expirationDate
                    )
                    return true
                } else {
                    AnalyticsService.shared.logSubscriptionEntitlementEvaluated(
                        status: "expired",
                        productId: transaction.productID,
                        expirationDate: expirationDate
                    )
                    return false
                }
            } else {
                // Non-expiring purchase (shouldn't happen for subscriptions, but handle it)
                AnalyticsService.shared.logSubscriptionEntitlementEvaluated(
                    status: "non_expiring",
                    productId: transaction.productID,
                    expirationDate: nil
                )
                return true
            }
        }

        AnalyticsService.shared.logSubscriptionEntitlementEvaluated(
            status: "no_entitlement",
            productId: subscriptionProductID,
            expirationDate: nil
        )
        return false
    }
}
