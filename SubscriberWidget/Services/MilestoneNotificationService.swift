//
//  MilestoneNotificationService.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-28.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftUI

class MilestoneNotificationService {
    static let shared = MilestoneNotificationService()

    private let lastKnownSubCountsKey = "lastKnownSubCounts"
    private let notificationIdentifierPrefix = "milestone_"

    @AppStorage("lastKnownSubCounts", store: .shared) private var lastKnownSubCountsData: Data = Data()

    private var lastKnownSubCounts: [String: Int] {
        get {
            (try? JSONDecoder().decode([String: Int].self, from: lastKnownSubCountsData)) ?? [:]
        }
        set {
            lastKnownSubCountsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    func checkAndNotifyMilestone(
        channel: YouTubeChannel,
        hasProAccess: Bool
    ) async {
        guard hasProAccess else { return }
        guard let newSubCount = Int(channel.subCount) else { return }

        let channelId = channel.id
        let oldSubCount = lastKnownSubCounts[channelId] ?? newSubCount

        lastKnownSubCounts[channelId] = newSubCount

        if let crossedMilestone = detectMilestoneCrossing(oldCount: oldSubCount, newCount: newSubCount) {
            await scheduleMilestoneNotification(
                channel: channel,
                milestone: crossedMilestone
            )
        }
    }

    func nextMilestone(for subscriberCount: Int) -> Int {
        let normalizedCount = max(subscriberCount, 0)
        let interval = milestoneStep(for: normalizedCount)
        return ((normalizedCount / interval) + 1) * interval
    }

    private func detectMilestoneCrossing(oldCount: Int, newCount: Int) -> Int? {
        guard newCount > oldCount else { return nil }

        let nextMilestone = nextMilestone(for: oldCount)
        return newCount >= nextMilestone ? nextMilestone : nil
    }

    private func milestoneStep(for subscriberCount: Int) -> Int {
        switch subscriberCount {
        case ..<100:
            return 10
        case ..<10_000:
            return 100
        case ..<1_000_000:
            return 10_000
        case ..<100_000_000:
            return 1_000_000
        case ..<1_000_000_000:
            return 10_000_000
        default:
            let digits = String(subscriberCount).count
            return Int(pow(10.0, Double(max(digits - 2, 0))))
        }
    }

    private func scheduleMilestoneNotification(channel: YouTubeChannel, milestone: Int) async {
        let center = UNUserNotificationCenter.current()

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "🎉 Milestone Reached!"
        content.body = "\(channel.channelName) reached \(formatMilestone(milestone)) subscribers!"
        content.sound = .default
        content.userInfo = [
            "channelId": channel.id,
            "channelName": channel.channelName,
            "milestone": milestone,
            "type": "milestone_notification"
        ]

        let identifier = "\(notificationIdentifierPrefix)\(channel.id)_\(milestone)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        do {
            try await center.add(request)
            AnalyticsService.shared.logMilestoneNotificationScheduled(
                channelName: channel.channelName,
                milestone: milestone
            )
        } catch {
            AnalyticsService.shared.logMilestoneNotificationFailed(error.localizedDescription)
        }
    }

    private func formatMilestone(_ milestone: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: milestone)) ?? "\(milestone)"
    }

    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                AnalyticsService.shared.logNotificationPermissionGranted()
            } else {
                AnalyticsService.shared.logNotificationPermissionDenied()
            }
            return granted
        } catch {
            AnalyticsService.shared.logNotificationPermissionError(error.localizedDescription)
            return false
        }
    }

    func getNotificationPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    func clearLastKnownSubCount(for channelId: String) {
        var counts = lastKnownSubCounts
        counts.removeValue(forKey: channelId)
        lastKnownSubCounts = counts
    }
}
