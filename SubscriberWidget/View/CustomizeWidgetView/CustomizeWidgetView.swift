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
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
    
    @StateObject var viewModel: ViewModel
    @State var channel: YouTubeChannel
    @State var isNewWidget: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @State private var name: String = ""
    @State private var showingAlert = false
    @State private var animate = false
    @State private var helpAlert = false
    @State private var bgColor: CGColor?
    @State private var colorChanged = false
    
    var body: some View {
        GeometryReader { _ in // Use geometry reader to prevent keyboard avoidance
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
                            channelData: $channelData,
                            channel: $channel,
                            submitButtonTapped: submitButtonTapped
                        )

                        HelpButton(helpAlert: $helpAlert)
                    }
                } else {
                    Spacer()
                }
                VStack {
                    WidgetColorPicker(
                        viewModel: viewModel,
                        channel: $channel,
                        colorChanged: $colorChanged,
                        backgroundColor: $backgroundColor
                    )

                    ResetButton(
                        viewModel: viewModel,
                        channel: $channel,
                        colorChanged: $colorChanged
                    )
                }
                Spacer()
                WidgetPreview(
                    channel: $channel,
                    animate: $animate,
                    bgColor: $bgColor
                )

                Spacer()
                WidgetSizePicker(animate: $animate)
                Spacer()
            }
            .background(Color(UIColor.systemGray6)).edgesIgnoringSafeArea(.all)
            .navigationBarTitle(self.channel.channelName, displayMode: .inline)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                updateColorIfNeeded()
            }
            .ignoresSafeArea(.keyboard, edges: .all)
        }
    }
    
    func updateColorIfNeeded() {
        // Only reload timelines if the color was changed
        if self.colorChanged {
            print("Color changed, reloading timelines")
            WidgetCenter.shared.reloadAllTimelines()
            self.colorChanged = false
        }
    }

    func submitButtonTapped() {
        guard name.count > 0 else { return }

        Task {
            do {
                let channel = try await viewModel.updateChannel(id: channel.id, name: name)
                UIApplication.shared.endEditing()
                name.removeAll()
                self.channel = channel
            } catch {
                showingAlert = true
            }
        }
    }
}

struct CustomizeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeWidgetView(
            viewModel: ViewModel(),
            channel: YouTubeChannel(
                channelName: "PreviewChannel",
                profileImage: "",
                subCount: "0",
                channelId: ""
            ),
            isNewWidget: false
        )
    }
}
