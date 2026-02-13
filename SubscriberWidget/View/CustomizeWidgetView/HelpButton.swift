//
//  HelpButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct HelpButton: View {
    @State private var helpAlert = false
    @State private var showSafari = false
    @State private var pendingContactHelp = false

    private let channelIdHelpURL = URL(string: "https://commentpicker.com/youtube-channel-id.php")!

    var body: some View {
        Button(action: {
            self.helpAlert = true
        }, label: {
            Image(systemName: "info.circle")
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
        .confirmationDialog(
            "Can't find your channel?",
            isPresented: $helpAlert,
            titleVisibility: .visible
        ) {
            Button("Find My ID") { self.showSafari = true }
            Button("Contact") { pendingContactHelp = true }
        } message: {
            Text("Try entering your channel ID instead. If that doesn't work, please contact me with your channel URL and I will help you find it")
        }
        .onChange(of: helpAlert) { newValue in
            if !newValue && pendingContactHelp {
                pendingContactHelp = false
                AnalyticsService.shared.logContactButtonTapped()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    EmailHelper.shared.send(
                        subject: "SubWidget Channel Help",
                        to: "arjun.dureja1000@gmail.com"
                    )
                }
            }
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: channelIdHelpURL)
        }
    }
}
