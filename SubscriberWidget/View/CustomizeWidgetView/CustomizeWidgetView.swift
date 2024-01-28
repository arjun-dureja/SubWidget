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
    @State private var colorChanged = false
    @State private var showNetworkError = false
    @State private var loadingChannel = false
    
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
                            viewModel: viewModel,
                            name: $name,
                            showingAlert: $showingAlert,
                            channel: $channel,
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
                
                VStack {
                    WidgetColorPicker(
                        viewModel: viewModel,
                        channel: $channel,
                        colorChanged: $colorChanged
                    )

                    ResetButton(
                        viewModel: viewModel,
                        channel: $channel,
                        colorChanged: $colorChanged
                    )
                }
                
                Spacer()
            }
            .navigationBarTitle(self.channel.channelName, displayMode: .inline)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                updateColorIfNeeded()
            }
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
    }
    
    func updateColorIfNeeded() {
        // Only reload timelines if the color was changed
        if colorChanged {
            print("Color changed, reloading timelines")
            WidgetCenter.shared.reloadAllTimelines()
            colorChanged = false
        }
    }

    func submitButtonTapped() {
        guard name.count > 0 else { return }

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
