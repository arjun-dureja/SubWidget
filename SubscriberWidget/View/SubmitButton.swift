//
//  SubmitButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SubmitButton: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.openURL) var openURL
    
    @Binding var name: String
    @Binding var showingAlert: Bool
    @Binding var channelData: Data
    
    var body: some View {
        Button(action: {
            if name.count > 0 {
                self.viewModel.getChannelDetails(for: name) { (success, channel) in
                    if success {
                        UIApplication.shared.endEditing()
                        guard let channelData = try? JSONEncoder().encode(channel!.channelId) else { return }
                        self.channelData = channelData
                        WidgetCenter.shared.reloadAllTimelines()
                    } else {
                        self.showingAlert = true
                    }
                    name.removeAll()
                }
            }
        }, label: {
            Text("Submit")
                .foregroundColor(Color(UIColor.systemBackground))
                .bold()
        })
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .foregroundColor(.white)
        .font(.subheadline)
        .background(Color.youtubeRed)
        .cornerRadius(8)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Unable to find channel"), message: Text("Please enter the correct channel username or ID"), primaryButton: .default(Text("Find my ID")) {
                openURL(URL(string: "https://commentpicker.com/youtube-channel-id.php")!)
            }, secondaryButton: .default(Text("OK")) {

            })
        }
    }
}
