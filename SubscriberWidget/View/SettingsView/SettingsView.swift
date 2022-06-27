//
//  SettingsView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Choose how often the subscriber count should update")) {
                    RefreshFrequency()
                }

                Section {
                    NavigationLink {
                        FAQ()
                    } label: {
                        Label("FAQ", systemImage: "questionmark.circle.fill")
                    }
                    SafariSheet(
                        text: "Contact",
                        icon: "envelope.circle.fill",
                        url: URL(string: "https://www.emailmeform.com/builder/form/Sg3ejer1CD0ehy")!
                    )
                    Button {
                        SKStoreReviewController.requestReview()
                    } label: {
                        FormLabel(text: "Rate", icon: "star.circle.fill")
                    }
                    SafariSheet(
                        text: "Privacy Policy",
                        icon: "lock.circle.fill",
                        url: URL(string: "https://pages.flycricket.io/subwidget/privacy.html")!
                    )
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
