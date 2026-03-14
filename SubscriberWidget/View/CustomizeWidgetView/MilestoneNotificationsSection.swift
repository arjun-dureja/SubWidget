//
//  MilestoneNotificationsSection.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-28.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI
import UIKit

struct MilestoneNotificationsSection: View {
    @Binding var channel: YouTubeChannel
    let hasProAccess: Bool
    @Binding var showPaywall: Bool
    let onUpdateChannel: () -> Void

    @State private var notificationDenied = false

    var body: some View {
        Section {
            Toggle(isOn: Binding(
                get: { channel.milestoneEnabled },
                set: { newValue in handleToggle(newValue) }
            )) {
                Label {
                    Text("Milestone Notifications")
                } icon: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(.white, Color.youtubeRed)
                }
            }
            .tint(.youtubeRed)
        } footer: {
            if channel.milestoneEnabled {
                Text("You'll be notified when this channel reaches \(nextMilestoneText) subscribers!")
            }
        }
        .alert("Notifications Disabled", isPresented: $notificationDenied) {
            Button("Cancel", role: .cancel) {
                channel.milestoneEnabled = false
            }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                channel.milestoneEnabled = false
            }
        } message: {
            Text("Enable notifications in Settings to receive milestone alerts")
        }
    }

    private var nextMilestoneText: String {
        guard let subCount = Int(channel.subCount) else {
            return "0"
        }

        let milestone = MilestoneNotificationService.shared.nextMilestone(for: subCount)
        return "\(milestone)".formattedWithSeparator()
    }

    private func handleToggle(_ newValue: Bool) {
        if !newValue {
            channel.milestoneEnabled = false
            onUpdateChannel()
            AnalyticsService.shared.logMilestoneNotificationsDisabled(channelName: channel.channelName)
            MilestoneNotificationService.shared.clearLastKnownSubCount(for: channel.channelId)
            return
        }

        guard hasProAccess else {
            AnalyticsService.shared.logPaywallShown(source: "milestone_notifications")
            showPaywall = true
            return
        }

        Task {
            let status = await MilestoneNotificationService.shared.getNotificationPermissionStatus()

            switch status {
            case .notDetermined:
                let granted = await MilestoneNotificationService.shared.requestNotificationPermission()
                if granted {
                    channel.milestoneEnabled = true
                    onUpdateChannel()
                    AnalyticsService.shared.logMilestoneNotificationsEnabled(channelName: channel.channelName)
                } else {
                    channel.milestoneEnabled = false
                }
            case .authorized, .provisional, .ephemeral:
                channel.milestoneEnabled = true
                onUpdateChannel()
                AnalyticsService.shared.logMilestoneNotificationsEnabled(channelName: channel.channelName)
            case .denied:
                notificationDenied = true
            @unknown default:
                channel.milestoneEnabled = false
            }
        }
    }
}
