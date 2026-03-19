//
//  ReviewPromptService.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import SwiftUI
import Foundation

@MainActor
final class ReviewPromptService {
    static let shared = ReviewPromptService()

    @AppStorage("reviewPromptRequestCount", store: .shared) private var requestCount: Int = 0
    @AppStorage("reviewPromptLastRequestedTimestamp", store: .shared) private var lastRequestedTimestamp: Double = 0
    @AppStorage("reviewPromptHasTappedRateButton", store: .shared) private var hasTappedRateButton: Bool = false

    private var didShowPaywallThisSession = false
    private var didRequestReviewThisSession = false

    private let maxRequestCount = 3
    private let cooldown: TimeInterval = 30 * 24 * 60 * 60

    private init() {}

    func registerAppOpen() {
        didShowPaywallThisSession = false
        didRequestReviewThisSession = false
    }

    func markPaywallShown() {
        didShowPaywallThisSession = true
    }

    func markRateButtonTapped() {
        hasTappedRateButton = true
    }

    func requestReviewIfAppropriate(channelCount: Int, requestReview: () -> Void) {
        guard shouldRequestReview(channelCount: channelCount) else { return }

        didRequestReviewThisSession = true
        requestCount += 1
        lastRequestedTimestamp = Date().timeIntervalSince1970

        AnalyticsService.shared.logReviewRequested()
        requestReview()
    }

    private func shouldRequestReview(channelCount: Int) -> Bool {
        guard channelCount >= 1 else { return false }
        guard !hasTappedRateButton else { return false }
        guard !didShowPaywallThisSession else { return false }
        guard !didRequestReviewThisSession else { return false }
        guard requestCount < maxRequestCount else { return false }

        guard lastRequestedTimestamp > 0 else { return true }
        return Date().timeIntervalSince1970 - lastRequestedTimestamp >= cooldown
    }
}
