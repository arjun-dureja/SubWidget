//
//  HelpButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct HelpButton: View {
    @Binding var helpAlert: Bool
    @Environment(\.openURL) var openURL

    @State private var showSafari = false

    var body: some View {
        Button(action: {
            self.helpAlert = true
        }, label: {
            Image(systemName: "info.circle")
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
        .alert(isPresented: $helpAlert) {
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
