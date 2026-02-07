//
//  LockedWidgetViews.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2026-02-07.
//

import SwiftUI
import WidgetKit

struct LockedWidgetContainer<Content: View>: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            content
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Unlock")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.youtubeRed)
            .cornerRadius(16)
            .opacity(0.9)
        }
    }
}

struct LockedLockscreenWidget: View {
    var body: some View {
        Text("Get SubWidget Pro to use this widget")
            .font(.system(size: 12, weight: .semibold))
            .minimumScaleFactor(0.1)
            .lineLimit(2)
            .containerBackground(.clear, for: .widget)
    }
}
