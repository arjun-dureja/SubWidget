//
//  WidgetPreview.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetPreview: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false

    @Binding var channel: YouTubeChannel
    @State private var currentPage = 0
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 35, alignment: .center)
                    .foregroundColor(colorScheme == .light ? Color(UIColor.systemGray6) : .black)
                    .cornerRadius(14, corners: [.topLeft, .topRight])

                Text("Preview")
                    .foregroundColor(Color(UIColor.label))
                    .font(.subheadline)
                    .bold()
            }
            .padding(.horizontal, 7)
            .padding(.top, 7)

            TabView(selection: $currentPage) {
                let subCountEntry = SimpleEntry(channel: channel, widgetType: .subscribers)
                SmallWidget(entry: subCountEntry)
                    .widgetBackground(bgColor: channel.bgColor, size: .small)
                    .tag(0)

                LockedPreview(size: .medium, isLocked: !hasProAccess, onUpgrade: handleUpgradeTapped) {
                    MediumWidget(entry: subCountEntry)
                        .widgetBackground(bgColor: channel.bgColor, size: .medium)
                }
                .tag(1)

                let viewCountEntry = SimpleEntry(channel: channel, widgetType: .views)
                LockedPreview(size: .small, isLocked: !hasProAccess, onUpgrade: handleUpgradeTapped) {
                    SmallWidget(entry: viewCountEntry)
                        .widgetBackground(bgColor: channel.bgColor, size: .small)
                }
                .tag(2)

                LockedPreview(size: .medium, isLocked: !hasProAccess, onUpgrade: handleUpgradeTapped) {
                    MediumWidget(entry: viewCountEntry)
                        .widgetBackground(bgColor: channel.bgColor, size: .medium)
                }
                .tag(3)
            }
            .padding(.top, -40)
            .padding(.bottom, -8)
            .tabViewStyle(.page)
        }
        .frame(height: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(colorScheme == .light ? .white : Color(UIColor.systemGray6))
        )
        .padding(.horizontal, 16)
        .paywallSheet(isPresented: $showPaywall)
    }

    private func handleUpgradeTapped() {
        AnalyticsService.shared.logPaywallShown(source: "preview_page")
        showPaywall = true
    }
}

#Preview {
    @State var channel: YouTubeChannel = .preview
    return WidgetPreview(channel: $channel)
}

private struct LockedPreview<Content: View>: View {
    let size: WidgetSize
    let isLocked: Bool
    let onUpgrade: () -> Void
    let content: Content
    init(size: WidgetSize, isLocked: Bool, onUpgrade: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.size = size
        self.isLocked = isLocked
        self.onUpgrade = onUpgrade
        self.content = content()
    }

    var body: some View {
        ZStack {
            content

            if isLocked {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(UIColor.systemBackground).opacity(0.5))
                    .frame(width: size.width, height: 155)
                    .overlay(
                        Button(action: onUpgrade) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                Text("Unlock")
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .background(Color.youtubeRed)
                            .cornerRadius(16)
                        }
                    )
            }
        }
        .frame(width: size.width, height: 155)
    }
}
