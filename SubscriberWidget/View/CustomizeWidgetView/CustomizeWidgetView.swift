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
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @State private var name: String = ""
    @State private var showingAlert = false
    @State private var animate = false
    @State private var helpAlert = false
    @State private var bgColor: CGColor?
    @State private var colorChanged = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            HStack {
                ChannelTextField(name: $name)
                
                SubmitButton(viewModel: viewModel,
                             name: $name,
                             showingAlert: $showingAlert,
                             channelData: $channelData,
                             channel: $channel)
            
                HelpButton(helpAlert: $helpAlert)
            }
            
            VStack {
                WidgetColorPicker(viewModel: viewModel,
                                  channel: $channel,
                                  colorChanged: $colorChanged,
                                  backgroundColor: $backgroundColor)
                
                ResetButton(viewModel: viewModel,
                            channel: $channel,
                            colorChanged: $colorChanged)
            }
            
            Spacer()
    
            WidgetPreview(channel: $channel,
                          animate: $animate,
                          bgColor: $bgColor)
            
            Spacer()
            
            WidgetSizePicker(animate: $animate)
            
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(UIColor.systemGray6)).edgesIgnoringSafeArea(.all)
        .navigationBarTitle("", displayMode: .inline)
        .onAppear() {
            //self.updateDataOnAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            //self.updateColorIfNeeded()
        }
    }
    
    func updateDataOnAppear() {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else {
            self.viewModel.getChannelDetails(for: "pewdiepie") { (channel)   in
                if let channel = channel {
                    guard let channelData = try? JSONEncoder().encode(channel.channelId) else { return }
                    self.channelData = channelData
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            return
        }
        self.viewModel.getChannelDetailsFromId(for: channelId) { (channel) in
            guard let _ = channel else {
                self.showingAlert = true
                return
            }
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
}

struct CustomizeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeWidgetView(viewModel: ViewModel(), channel: YouTubeChannel(channelName: "PreviewChannel", profileImage: "", subCount: "0", channelId: ""))
    }
}
