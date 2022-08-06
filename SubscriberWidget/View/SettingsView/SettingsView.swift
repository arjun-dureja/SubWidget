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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Form {
                Section(footer: EmptyView()) {
                    HStack(spacing: 16) {
                        Spacer()

                        AppIcon()
                            .cornerRadius(16)
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SubWidget \(Bundle.main.appVersion)")
                                .font(.system(size: 16, weight: .medium))
                            Text("by Arjun Dureja")
                                .font(.system(size: 14))
                                .foregroundColor(colorScheme == .dark ? .darkModeTitleGray2 : .titleGray)
                        }


                        Spacer()
                    }
                }
                .padding(.top, 24)
                .listRowBackground(Color.clear)

                Section(footer: Text("Choose how often the subscriber count should update")) {
                    RefreshFrequency()
                }

                Section {
                    NavigationLink {
                        FAQ()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.white, Color.youtubeRed)
                            Text("FAQ")
                        }
                        .padding(.leading, 4)
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}

struct AppIcon: View {
    var body: some View {
        Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map {
                Image(uiImage: $0)
                    .resizable()
            }
    }
}

extension Bundle {
    public var appVersion: String { getInfo("CFBundleShortVersionString") }
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}
