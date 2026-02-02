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
    private let freemiumBuildNumber = 31
    private let revenueCatEntitlementId = Constants.revenueCatEntitlementId

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

    /// Checks revenue cat for pro access
    private func checkRevenueCatEntitlement() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[revenueCatEntitlementId]?.isActive == true
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
