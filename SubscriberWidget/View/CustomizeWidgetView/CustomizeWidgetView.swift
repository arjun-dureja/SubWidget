//
//  ContentView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI
import UIKit
import WidgetKit

struct CustomizeWidgetView: View {
    @ObservedObject var viewModel: ViewModel
    @State var channel: YouTubeChannel

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false

    @State private var bgColor: CGColor?
    @State private var showPaywall = false

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 8)

                WidgetPreview(channel: $channel)
                    .frame(maxWidth: 650)

                Form {
                    Section {
                        WidgetColorPicker(
                            title: "Background",
                            colorType: .background,
                            onSelectColor: handleColorSelected,
                            channel: $channel
                        )
                        WidgetColorPicker(
                            title: "Accent",
                            colorType: .accent,
                            onSelectColor: handleColorSelected,
                            channel: $channel
                        )
                        WidgetColorPicker(
                            title: "Number",
                            colorType: .number,
                            onSelectColor: handleColorSelected,
                            channel: $channel
                        )
                    } header: {
                        HStack {
                            Text("Colors")
                            Spacer()
                            ResetButton(
                                onReset: handleResetColors,
                                channel: $channel
                            )
                        }
                    }

                    Section("Palettes") {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Palette.presets, id: \.name.key) { palette in
                                ColorPalette(palette: palette, onPress: handlePressPalette)
                            }
                        }
                    }

                    MilestoneNotificationsSection(
                        channel: $channel,
                        hasProAccess: hasProAccess,
                        showPaywall: $showPaywall,
                        onUpdateChannel: updateChannel
                    )
                }
                .scrollContentBackground(.hidden)
                .frame(maxWidth: 650)

                Spacer()
            }
            .navigationBarTitle(self.channel.channelName, displayMode: .inline)
            .frame(
                width: geometry.frame(in: .global).width,
                height: geometry.frame(in: .global).height
            )
        }
        .background(colorScheme == .light ? Color(UIColor.systemGray6) : .black)
        .ignoresSafeArea(.keyboard, edges: .all)
        .paywallSheet(isPresented: $showPaywall)
        .onAppear {
            AnalyticsService.shared.logCustomizeWidgetScreenOpened(
                channel.channelName,
                StringUtils.getChannelUrlFromId(channel.channelId),
                channel.subCount
            )
        }
    }

    func handleColorSelected(_ color: CGColor, _ type: ColorType) {
        guard hasProAccess else {
            AnalyticsService.shared.logPaywallShown(source: "color_picker")
            // Show paywall after delay to avoid sheet collision
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showPaywall = true
            }
            return
        }
        let updatedColor = UIColor(cgColor: color)
        switch type {
        case .background:
            viewModel.updateBgColorForChannel(id: channel.id, color: updatedColor)
            channel.bgColor = updatedColor
        case .accent:
            viewModel.updateAccentColorForChannel(id: channel.id, color: updatedColor)
            channel.accentColor = updatedColor
        case .number:
            viewModel.updateNumberColorForChannel(id: channel.id, color: updatedColor)
            channel.numberColor = updatedColor
        }
    }

    func handleResetColors() {
        AnalyticsService.shared.logResetColorTapped()
        viewModel.resetAllColors(id: channel.id)
        channel.bgColor = nil
        channel.accentColor = nil
        channel.numberColor = nil
    }

    func handlePressPalette(_ palette: Palette) {
        guard hasProAccess else {
            AnalyticsService.shared.logPaywallShown(source: "color_palette")
            showPaywall = true
            return
        }
        AnalyticsService.shared.logColorPaletteTapped(String(localized: palette.name))
        let bgColor = UIColor(palette.background)
        let accentColor = UIColor(palette.accent)
        let numberColor = UIColor(palette.number)
        viewModel.updateColorsForChannel(
            id: channel.id,
            bgColor: bgColor,
            accentColor: accentColor,
            numberColor: numberColor
        )

        channel.bgColor = bgColor
        channel.accentColor = accentColor
        channel.numberColor = numberColor
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateChannel() {
        viewModel.updateMilestoneSettings(
            id: channel.id,
            enabled: channel.milestoneEnabled
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct CustomizeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeWidgetView(
            viewModel: ViewModel(),
            channel: .preview
        )
    }
}
