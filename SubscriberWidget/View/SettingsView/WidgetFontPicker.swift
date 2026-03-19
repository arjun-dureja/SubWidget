//
//  WidgetFontPicker.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import SwiftUI
import WidgetKit

struct WidgetFontPicker: View {
    @AppStorage(WidgetFont.storageKey, store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false
    @Binding var showPaywall: Bool

    @State private var isRevertingSelection = false

    var body: some View {
        Picker(
            selection: $widgetFontRawValue,
            label: Label(
                title: {
                    Text("Widget Font")
                },
                icon: {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(Color.youtubeRed)
                        Image(systemName: "textformat")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            )
        ) {
            ForEach(WidgetFont.allCases, id: \.self) { font in
                Text(font.displayName).tag(font.rawValue)
            }
        }
        .onAppear {
            if WidgetFont(rawValue: widgetFontRawValue) == nil {
                widgetFontRawValue = WidgetFont.default.rawValue
            }
        }
        .onChange(of: widgetFontRawValue) { newValue in
            if isRevertingSelection {
                isRevertingSelection = false
                return
            }

            guard let widgetFont = WidgetFont(rawValue: newValue) else {
                widgetFontRawValue = WidgetFont.default.rawValue
                return
            }

            guard hasProAccess || widgetFont == .default else {
                isRevertingSelection = true
                widgetFontRawValue = WidgetFont.default.rawValue
                AnalyticsService.shared.logPaywallShown(source: "widget_font")
                showPaywall = true
                return
            }

            AnalyticsService.shared.logWidgetFontChanged(widgetFont.rawValue)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
