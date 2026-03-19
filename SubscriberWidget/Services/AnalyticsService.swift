//
//  AnalyticsService.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-27.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import Mixpanel
import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()

    private func logEvent(
        _ eventName: String,
        properties: [String: any MixpanelType]? = [:]
    ) {
        #if DEBUG
        if let properties = properties, !properties.isEmpty {
            print("📊 Analytics: \(eventName) | Properties: \(properties)")
        } else {
            print("📊 Analytics: \(eventName)")
        }
        #else
        Mixpanel.mainInstance().track(event: eventName, properties: properties)
        #endif
    }

    func logAppOpened() {
        logEvent("app.opened")
    }

    func logAddNewChannelTapped() {
        logEvent("add_new_channel.tapped")
    }

    func logChannelDeleted(_ channelName: String) {
        logEvent("channel.deleted", properties: [
            "channelName": channelName
        ])
    }

    func logChannelsLoaded(_ numChannels: Int, _ channelNames: [String]) {
        logEvent("channels.loaded", properties: [
            "numChannels": numChannels,
            "channelNames": channelNames
        ])
    }

    func logLoadChannelsFailed(_ errorMessage: String) {
        logEvent("load_channels.failed", properties: [
            "errorMessage": errorMessage
        ])
    }

    func logChannelDetailsKeyNotFound(
        _ key: String,
        _ debugDescription: String,
        _ channelName: String,
        _ channelId: String
    ) {
        logEvent("channel_details.key_not_found", properties: [
            "key": key,
            "debugDescription": debugDescription,
            "channelName": channelName,
            "channelId": channelId
        ])
    }

    func logChannelSearched(_ channelName: String) {
        logEvent("youtube_channel.searched", properties: [
            "channelName": channelName
        ])
    }

    func logChannelSearchFailed(_ channelName: String) {
        logEvent("youtube_channel_search.failed", properties: [
            "channelName": channelName
        ])
    }

    func logNetworkError(_ errorMessage: String) {
        logEvent("network.error", properties: [
            "errorMessage": errorMessage
        ])
    }

    func logRefreshFrequencyUpdated(_ refreshFrequency: String) {
        logEvent("refresh_frequency.updated", properties: [
            "refreshFrequency": refreshFrequency
        ])
    }

    func logSimplifyNumbersToggled(_ isToggled: Bool) {
        logEvent("simplify_numbers.toggled", properties: [
            "isToggled": isToggled
        ])
    }

    func logShowUpdateTimeToggled(_ isToggled: Bool) {
        logEvent("show_update_time.toggled", properties: [
            "isToggled": isToggled
        ])
    }

    func logWidgetRefreshButtonToggled(_ isToggled: Bool) {
        logEvent("widget_refresh_button.toggled", properties: [
            "isToggled": isToggled
        ])
    }

    func logWidgetFontChanged(_ font: String) {
        logEvent("widget_font.changed", properties: [
            "font": font
        ])
    }

    func logWidgetManualRefreshTapped(widgetKind: String) {
        logEvent("widget_manual_refresh.tapped", properties: [
            "widgetKind": widgetKind
        ])
    }

    func logFaqScreenViewed() {
        logEvent("faq_screen.viewed")
    }

    func logFaqCellTapped(_ question: String) {
        logEvent("faq_cell.tapped", properties: [
            "question": question
        ])
    }

    func logRateButtontapped() {
        logEvent("rate_button.tapped")
    }

    func logReviewRequested() {
        logEvent("review.requested")
    }

    func logChannelDeepLinkOpened(_ channelUrl: String, widgetType: String) {
        logEvent("channel_deeplink.opened", properties: [
            "channelUrl": channelUrl,
            "widgetType": widgetType
        ])
    }

    func logCustomizeWidgetScreenOpened(_ channelName: String, _ channelUrl: String, _ subCount: String) {
        logEvent("customize_widget_screen.opened", properties: [
            "channelName": channelName,
            "channelUrl": channelUrl,
            "subCount": subCount
        ])
    }

    func logResetColorTapped() {
        logEvent("reset_color.tapped")
    }

    func logContactButtonTapped() {
        logEvent("contact_button.tapped")
    }

    func logSendEmailFailure() {
        logEvent("send_email.failure")
    }

    func logColorPaletteTapped(_ paletteName: String) {
        logEvent("color_palette.tapped", properties: [
            "paletteName": paletteName
        ])
    }

    func logWidgetChannelFetchFailed(_ message: String) {
        logEvent("widget.channel_fetch_failed", properties: [
            "message": message
        ])
    }

    func logWidgetImageFetchFailed(url: String, error: String) {
        logEvent("widget.image_fetch_failed", properties: [
            "url": url,
            "error": error
        ])
    }

    // Subscription & Access Events
    func logLegacyUserDetected() {
        logEvent("subscription.legacy_user_detected")
    }

    func logLegacyUserCheck(
        isLegacyUser: Bool,
        originalPurchaseDate: Date?,
        freemiumCutoffDate: Date?
    ) {
        var properties: [String: any MixpanelType] = [
            "isLegacyUser": isLegacyUser
        ]
        if let originalPurchaseDate = originalPurchaseDate {
            properties["originalPurchaseTimestamp"] = originalPurchaseDate.timeIntervalSince1970
        }
        if let freemiumCutoffDate = freemiumCutoffDate {
            properties["freemiumCutoffTimestamp"] = freemiumCutoffDate.timeIntervalSince1970
        }
        logEvent("subscription.legacy_check", properties: properties)
    }

    func logAppTransactionDetails(
        originalApplicationVersion: String,
        originalPurchaseDate: Date?
    ) {
        var properties: [String: any MixpanelType] = [
            "originalApplicationVersion": originalApplicationVersion
        ]

        if let originalPurchaseDate = originalPurchaseDate {
            properties["originalPurchaseTimestamp"] = originalPurchaseDate.timeIntervalSince1970
        }

        logEvent("subscription.app_transaction_details", properties: properties)
    }

    func logActiveSubscriberDetected() {
        logEvent("subscription.active_subscriber_detected")
    }

    func logSubscriptionEntitlementEvaluated(
        status: String,
        productId: String,
        expirationDate: Date?
    ) {
        var properties: [String: any MixpanelType] = [
            "status": status,
            "productId": productId
        ]
        if let expirationDate = expirationDate {
            properties["expirationTimestamp"] = expirationDate.timeIntervalSince1970
        }
        logEvent("subscription.entitlement_evaluated", properties: properties)
    }

    func logSubscriptionAccessEvaluated(
        stage: String,
        hasProAccess: Bool,
        isLegacyUser: Bool
    ) {
        logEvent("subscription.access_evaluated", properties: [
            "stage": stage,
            "hasProAccess": hasProAccess,
            "isLegacyUser": isLegacyUser
        ])
    }

    func logRevenueCatError(_ message: String) {
        logEvent("subscription.revenuecat_error", properties: [
            "message": message
        ])
    }

    func logPaywallShown(source: String) {
        logEvent("paywall.shown", properties: [
            "source": source
        ])
    }

    func logWidgetUpgradeAlertShown(source: String) {
        logEvent("widget_upgrade_alert.shown", properties: [
            "source": source
        ])
    }

    func logOnboardingShown() {
        logEvent("onboarding.shown")
    }

    func logOnboardingStepViewed() {
        logEvent("onboarding.step_viewed")
    }

    func logOnboardingAdvanced() {
        logEvent("onboarding.advanced")
    }

    func logOnboardingCompleted() {
        logEvent("onboarding.completed")
    }

    func logSubscriptionPurchaseCompleted() {
        logEvent("subscription.purchase_completed")
    }

    func logSubscriptionRestoreSucceeded() {
        logEvent("subscription.restore_succeeded")
    }

    func logLegacyAccessManuallyGranted() {
        logEvent("subscription.legacy_access_manually_granted")
    }

    func logRestorePurchasesTapped() {
        logEvent("subscription.restore_purchases_tapped")
    }

    // Milestone Notifications
    func logMilestoneNotificationsEnabled(channelName: String) {
        logEvent("milestone_notifications.enabled", properties: [
            "channelName": channelName
        ])
    }

    func logMilestoneNotificationsDisabled(channelName: String) {
        logEvent("milestone_notifications.disabled", properties: [
            "channelName": channelName
        ])
    }

    func logMilestoneNotificationScheduled(channelName: String, milestone: Int) {
        logEvent("milestone_notification.scheduled", properties: [
            "channelName": channelName,
            "milestone": milestone
        ])
    }

    func logMilestoneNotificationFailed(_ errorMessage: String) {
        logEvent("milestone_notification.failed", properties: [
            "errorMessage": errorMessage
        ])
    }

    func logNotificationPermissionGranted() {
        logEvent("notification_permission.granted")
    }

    func logNotificationPermissionDenied() {
        logEvent("notification_permission.denied")
    }

    func logNotificationPermissionError(_ errorMessage: String) {
        logEvent("notification_permission.error", properties: [
            "errorMessage": errorMessage
        ])
    }

    func logMilestoneNotificationTapped(channelId: String) {
        logEvent("milestone_notification.tapped", properties: [
            "channelId": channelId
        ])
    }
}
