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
    @Binding var currentPage: WidgetPreviewPage
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
                ShareableWidgetPreview(
                    channel: channel,
                    page: .subscribersSmall,
                    channelImage: nil,
                    hasProAccess: hasProAccess,
                    onUpgrade: handleUpgradeTapped
                )
                .tag(WidgetPreviewPage.subscribersSmall)

                ShareableWidgetPreview(
                    channel: channel,
                    page: .subscribersMedium,
                    channelImage: nil,
                    hasProAccess: hasProAccess,
                    onUpgrade: handleUpgradeTapped
                )
                .tag(WidgetPreviewPage.subscribersMedium)

                ShareableWidgetPreview(
                    channel: channel,
                    page: .viewsSmall,
                    channelImage: nil,
                    hasProAccess: hasProAccess,
                    onUpgrade: handleUpgradeTapped
                )
                .tag(WidgetPreviewPage.viewsSmall)

                ShareableWidgetPreview(
                    channel: channel,
                    page: .viewsMedium,
                    channelImage: nil,
                    hasProAccess: hasProAccess,
                    onUpgrade: handleUpgradeTapped
                )
                .tag(WidgetPreviewPage.viewsMedium)

                ShareableWidgetPreview(
                    channel: channel,
                    page: .combinedMedium,
                    channelImage: nil,
                    hasProAccess: hasProAccess,
                    onUpgrade: handleUpgradeTapped
                )
                .tag(WidgetPreviewPage.combinedMedium)
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
    @State var currentPage: WidgetPreviewPage = .subscribersSmall
    return WidgetPreview(channel: $channel, currentPage: $currentPage)
}

struct LockedPreview<Content: View>: View {
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
