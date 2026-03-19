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
    @AppStorage("widgetFont", store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue
    @ViewBuilder var content: Content

    private var widgetFont: WidgetFont {
        WidgetFont(storageValue: widgetFontRawValue)
    }

    var body: some View {
        ZStack {
            content
                .redacted(reason: .placeholder)
                .blur(radius: 3)

            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Unlock")
                    .font(widgetFont.font(size: 16, weight: .semibold))
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
    @AppStorage("widgetFont", store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue

    private var widgetFont: WidgetFont {
        WidgetFont(storageValue: widgetFontRawValue)
    }

    var body: some View {
        Text("Get SubWidget Pro to use this widget")
            .font(widgetFont.font(size: 12, weight: .semibold))
            .minimumScaleFactor(0.1)
            .lineLimit(2)
            .containerBackground(.clear, for: .widget)
    }
}
