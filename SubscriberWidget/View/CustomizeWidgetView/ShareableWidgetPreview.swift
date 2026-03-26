//
//  ShareableWidgetPreview.swift
//  SubscriberWidget
//
//  Created by Codex on 2025-02-14.
//

import SwiftUI
import UIKit

enum WidgetPreviewPage: Int, CaseIterable, Identifiable {
    case subscribersSmall
    case subscribersMedium
    case viewsSmall
    case viewsMedium
    case combinedMedium

    var id: Int { rawValue }

    var widgetType: WidgetType {
        switch self {
        case .subscribersSmall, .subscribersMedium:
            return .subscribers
        case .viewsSmall, .viewsMedium:
            return .views
        case .combinedMedium:
            return .combined
        }
    }

    var size: WidgetSize {
        switch self {
        case .subscribersSmall, .viewsSmall:
            return .small
        case .subscribersMedium, .viewsMedium, .combinedMedium:
            return .medium
        }
    }

    var analyticsName: String {
        switch self {
        case .subscribersSmall:
            return "subscribers_small"
        case .subscribersMedium:
            return "subscribers_medium"
        case .viewsSmall:
            return "views_small"
        case .viewsMedium:
            return "views_medium"
        case .combinedMedium:
            return "combined_medium"
        }
    }

    var isProOnly: Bool {
        self != .subscribersSmall
    }
}

struct ShareableWidgetPreview: View {
    let channel: YouTubeChannel
    let page: WidgetPreviewPage
    let channelImage: UIImage?
    let hasProAccess: Bool
    var exportMode: Bool = false
    let onUpgrade: (() -> Void)?

    private var entry: SimpleEntry {
        SimpleEntry(
            channel: channel,
            channelImage: channelImage ?? UIImage(systemName: "person.circle")!,
            widgetType: page.widgetType
        )
    }

    private var isLocked: Bool {
        page.isProOnly && !hasProAccess
    }

    var body: some View {
        LockedPreview(size: page.size, isLocked: isLocked, onUpgrade: onUpgrade ?? {}) {
            widgetView
                .widgetBackground(bgColor: channel.bgColor, size: page.size)
        }
    }

    @ViewBuilder
    private var widgetView: some View {
        switch page.size {
        case .small:
            SmallWidget(entry: entry, forceEntryImage: channelImage != nil, exportMode: exportMode)
        case .medium:
            MediumWidget(entry: entry, forceEntryImage: channelImage != nil, exportMode: exportMode)
        }
    }
}
