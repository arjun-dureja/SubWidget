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
    @Binding var channel: YouTubeChannel
    @Binding var loading: Bool
    
    @State private var showSafari = false

    var submitButtonTapped: () -> Void
    
    var body: some View {
        Button(action: submitButtonTapped, label: {
            ZStack {
                if loading {
                    ProgressView()
                }
                
                Text("Submit")
                    .foregroundColor(.white)
                    .bold()
                    .opacity(loading ? 0 : 1)
            }
            
        })
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .foregroundColor(.white)
        .font(.subheadline)
        .background(Color.youtubeRed)
        .cornerRadius(8)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Can't find your channel?"),
                  message: Text("Try entering your YouTube channel ID instead"),
                  primaryButton: .default(Text("Find My ID")) {
                self.showSafari = true
            }, secondaryButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: "https://commentpicker.com/youtube-channel-id.php")!)
        }
    }
}
