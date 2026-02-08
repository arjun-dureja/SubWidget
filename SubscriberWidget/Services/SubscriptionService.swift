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
import RevenueCat

class SubscriptionService: SubscriptionServiceProtocol {
    private let freemiumCutoffDate = DateComponents(
        calendar: Calendar(identifier: .gregorian),
        timeZone: TimeZone(secondsFromGMT: 0),
        year: 2026,
        month: 2,
        day: 10,
        hour: 0,
        minute: 0,
        second: 0
    ).date

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

        let isProActive = await checkRevenueCatEntitlement()
        hasProAccess = isProActive
        if isProActive {
            AnalyticsService.shared.logActiveSubscriberDetected()
        }
        AnalyticsService.shared.logSubscriptionAccessEvaluated(
            stage: "revenuecat_entitlement",
            hasProAccess: isProActive,
            isLegacyUser: false
        )
    }

    /// Checks if user purchased the app before it went freemium
    private func detectLegacyUser() async -> Bool {
        do {
            let appTransaction = try await AppTransaction.shared

            guard case .verified(let transaction) = appTransaction else {
                AnalyticsService.shared.logLegacyUserCheck(
                    isLegacyUser: false,
                    originalPurchaseDate: nil,
                    freemiumCutoffDate: freemiumCutoffDate
                )
                return false
            }

            let originalPurchaseDate = transaction.originalPurchaseDate

            guard let freemiumCutoffDate else {
                AnalyticsService.shared.logLegacyUserCheck(
                    isLegacyUser: false,
                    originalPurchaseDate: originalPurchaseDate,
                    freemiumCutoffDate: nil
                )
                return false
            }

            if originalPurchaseDate < freemiumCutoffDate {
                AnalyticsService.shared.logLegacyUserCheck(
                    isLegacyUser: true,
                    originalPurchaseDate: originalPurchaseDate,
                    freemiumCutoffDate: freemiumCutoffDate
                )
                return true
            }

            AnalyticsService.shared.logLegacyUserCheck(
                isLegacyUser: false,
                originalPurchaseDate: originalPurchaseDate,
                freemiumCutoffDate: freemiumCutoffDate
            )
            return false
        } catch {
            AnalyticsService.shared.logLegacyUserCheck(
                isLegacyUser: false,
                originalPurchaseDate: nil,
                freemiumCutoffDate: freemiumCutoffDate
            )
            return false
        }
    }

    /// Checks revenue cat for pro access
    private func checkRevenueCatEntitlement() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[Constants.revenueCatEntitlementId]?.isActive == true
        } catch {
            AnalyticsService.shared.logRevenueCatError(error.localizedDescription)
            AnalyticsService.shared.logSubscriptionAccessEvaluated(
                stage: "revenuecat_error",
                hasProAccess: hasProAccess,
                isLegacyUser: false
            )
            return hasProAccess
        }
    }
}
