//
//  AnalyticsService.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-27.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import Mixpanel

class AnalyticsService {
    static let shared = AnalyticsService()

    private func logEvent(
        _ eventName: String,
        properties: [String: any MixpanelType]? = [:]
    ) {
        Mixpanel.mainInstance().track(event: eventName, properties: properties)
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

    func logChannelsLoaded(_ numChannels: Int) {
        logEvent("channels.loaded", properties: [
            "numChannels": numChannels
        ])
    }

    func logLoadChannelsFailed(_ errorMessage: String) {
        logEvent("load_channels.failed", properties: [
            "errorMessage": errorMessage
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

    func logChannelDeepLinkOpened() {
        logEvent("channel_deeplink.opened")
    }

    func logCustomizeWidgetScreenOpened(_ channelName: String) {
        logEvent("customize_widget_screen.opened", properties: [
            "channelName": channelName
        ])
    }

    func logResetColorTapped() {
        logEvent("reset_color.tapped")
    }
}
