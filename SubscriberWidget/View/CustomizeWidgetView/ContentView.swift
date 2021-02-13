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

struct ContentView: View {
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
    
    @ObservedObject var viewModel = ViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @State private var name: String = ""
    @State private var showingAlert = false
    @State private var animate = false
    @State private var helpAlert = false
    @State private var bgColor: CGColor?
    @State private var colorChanged = false
    
    init() {
        // Segmented control colors
        UISegmentedControl.appearance().backgroundColor = .systemGray6
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.youtubeRed)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBackground], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            
            Text("SubWidget")
                .foregroundColor(Color(UIColor.label))
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            HStack {
                ChannelTextField(name: $name)
                
                SubmitButton(viewModel: self.viewModel,
                             name: $name,
                             showingAlert: $showingAlert,
                             channelData: $channelData)
            
                HelpButton(helpAlert: $helpAlert)
            }
            
            Spacer()
            
            VStack {
                WidgetColorPicker(pickerColor: $bgColor,
                                  colorChanged: $colorChanged,
                                  backgroundColor: $backgroundColor)
                
                ResetButton(backgroundColor: $backgroundColor,
                            bgColor: $bgColor,
                            colorChanged: $colorChanged)
            }
    
            WidgetPreview(viewModel: viewModel,
                          animate: $animate,
                          bgColor: $bgColor)
            
            Spacer()
            
            WidgetSizePicker(animate: $animate)
            
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(UIColor.systemGray6)).edgesIgnoringSafeArea(.all)
        .onAppear() {
            self.updateDataOnAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.updateColorIfNeeded()
        }
    }
    
    func updateDataOnAppear() {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else {
            self.viewModel.getChannelDetails(for: "pewdiepie") { (success, channel)   in
                if success {
                    guard let channelData = try? JSONEncoder().encode(channel!.channelId) else { return }
                    self.channelData = channelData
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            return
        }
        self.viewModel.getChannelDetailsFromId(for: channelId) { (success, _) in
            if !success {
                self.showingAlert = true
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
