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
    @State var isNewWidget: Bool

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL

    @State private var name: String = ""
    @State private var showingAlert = false
    @State private var helpAlert = false
    @State private var bgColor: CGColor?
    @State private var showNetworkError = false
    @State private var loadingChannel = false

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        GeometryReader { geometry in // Use geometry reader to prevent keyboard avoidance
            VStack(spacing: 16) {
                if isNewWidget {
                    CustomizeWidgetHeader(viewModel: viewModel)

                    HStack {
                        ChannelTextField(
                            name: $name,
                            submitButtonTapped: submitButtonTapped
                        )

                        SubmitButton(
                            showingAlert: $showingAlert,
                            loading: $loadingChannel,
                            submitButtonTapped: submitButtonTapped
                        )

                        HelpButton(helpAlert: $helpAlert)
                    }
                } else {
                    Spacer()
                        .frame(height: 8)
                }

                WidgetPreview(
                    channel: $channel,
                    bgColor: $bgColor
                )
                .frame(maxWidth: 650)

                Form {
                    Section {
                        WidgetColorPicker(
                            colorType: .background,
                            viewModel: viewModel,
                            channel: $channel

                        )
                        WidgetColorPicker(
                            colorType: .accent,
                            viewModel: viewModel,
                            channel: $channel

                        )
                        WidgetColorPicker(
                            colorType: .number,
                            viewModel: viewModel,
                            channel: $channel
                        )
                    } header: {
                        HStack {
                            Text("Colors")
                            Spacer()
                            ResetButton(
                                viewModel: viewModel,
                                channel: $channel
                            )
                        }
                    }

                    Section("Palettes") {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Palette.presets, id: \.name) { palette in
                                ColorPalette(palette: palette, onPress: handlePressPalette)
                            }
                        }
                    }
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
        .alert("Network error. Please try again later.", isPresented: $showNetworkError) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            AnalyticsService.shared.logCustomizeWidgetScreenOpened(channel.channelName, subCount: channel.subCount)
        }
    }

    func submitButtonTapped() {
        guard !name.isEmpty else { return }

        Task {
            do {
                loadingChannel = true
                let channel = try await viewModel.updateChannel(id: channel.id, name: name)
                UIApplication.shared.endEditing()
                name.removeAll()
                self.channel = channel
            } catch SubWidgetError.serverError {
                showNetworkError = true
            } catch {
                AnalyticsService.shared.logChannelSearchFailed(name)
                showingAlert = true
            }

            loadingChannel = false
        }
    }

    func handlePressPalette(_ palette: Palette) {
        AnalyticsService.shared.logColorPaletteTapped(palette.name)
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
}

struct CustomizeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeWidgetView(
            viewModel: ViewModel(),
            channel: .preview,
            isNewWidget: false
        )
    }
}
