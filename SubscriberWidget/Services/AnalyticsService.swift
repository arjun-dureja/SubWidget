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

    func logChannelDeepLinkOpened(_ channelId: String) {
        logEvent("channel_deeplink.opened", properties: [
            "channelId": channelId
        ])
    }

    func logCustomizeWidgetScreenOpened(_ channelName: String, subCount: String) {
        logEvent("customize_widget_screen.opened", properties: [
            "channelName": channelName,
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
}
