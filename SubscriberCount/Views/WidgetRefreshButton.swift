//
//  WidgetRefreshButton.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import SwiftUI
import AppIntents

struct WidgetRefreshButton: View {
    let widgetType: WidgetType

    var body: some View {
        Button(intent: RefreshWidgetIntent(widgetKind: widgetType.widgetKind)) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, Color.youtubeRed)
        }
        .buttonStyle(.plain)
    }
}
