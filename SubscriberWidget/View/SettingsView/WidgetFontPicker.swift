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

    private var selectedWidgetFont: Binding<WidgetFont> {
        Binding(
            get: { WidgetFont(storageValue: widgetFontRawValue) },
            set: { widgetFontRawValue = $0.rawValue }
        )
    }

    var body: some View {
        Picker(
            selection: selectedWidgetFont,
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
                Text(font.displayName).tag(font)
            }
        }
        .onChange(of: widgetFontRawValue) { newValue in
            let widgetFont = WidgetFont(storageValue: newValue)

            guard hasProAccess || widgetFont == .default else {
                widgetFontRawValue = WidgetFont.default.rawValue
                AnalyticsService.shared.logPaywallShown(source: "widget_font")
                WidgetCenter.shared.reloadAllTimelines()
                showPaywall = true
                return
            }

            guard hasProAccess else { return }

            AnalyticsService.shared.logWidgetFontChanged(widgetFont.rawValue)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
