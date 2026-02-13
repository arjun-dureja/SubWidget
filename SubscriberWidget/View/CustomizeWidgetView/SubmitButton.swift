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
    @Environment(\.openURL) var openURL

    @Binding var showingAlert: Bool
    @Binding var loading: Bool

    @State private var showSafari = false
    @State private var pendingContactHelp = false

    var submitButtonTapped: () -> Void
    private let channelIdHelpURL = URL(string: "https://commentpicker.com/youtube-channel-id.php")!

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
        .confirmationDialog(
            "Channel not found",
            isPresented: $showingAlert,
            titleVisibility: .visible
        ) {
            Button("Find My ID") { self.showSafari = true }
            Button("Contact") { pendingContactHelp = true }
        } message: {
            Text("Try entering your channel ID instead. If that doesn't work, please contact me with your channel URL and I will help you find it")
        }
        .onChange(of: showingAlert) { newValue in
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
