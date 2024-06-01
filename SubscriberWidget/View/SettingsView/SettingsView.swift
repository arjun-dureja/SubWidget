//
//  SettingsView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import StoreKit
import WidgetKit

struct SettingsView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("simplifyNumbers", store: .shared) var simplifyNumbers: Bool = false
    @AppStorage("showUpdateTime", store: .shared) var showUpdateTime: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                if colorScheme == .light {
                    Color(UIColor.systemGray6)
                        .ignoresSafeArea(.all)
                }

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
                        RefreshFrequency(viewModel: viewModel)
                    }

                    Section(footer: Text("Display the time the subscriber count was last updated")) {
                        Toggle(isOn: $showUpdateTime) {
                            Label {
                                Text("Show Update Time")
                            } icon: {
                                // Workaround with overlay to get the clock background to be red and hands to be white
                                Image(systemName: "clock")
                                    .foregroundStyle(Color.white)
                                    .overlay {
                                        Image(systemName: "clock.fill")
                                            .foregroundStyle(Color.youtubeRed)
                                    }
                            }
                        }
                        .tint(.youtubeRed)
                        .onChange(of: showUpdateTime) { newValue in
                            AnalyticsService.shared.logShowUpdateTimeToggled(newValue)
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }

                    Section(footer: Text("Display large numbers in a compact, simplified format")) {
                        Toggle(isOn: $simplifyNumbers) {
                            Label {
                                Text("Simplify Numbers")
                            } icon: {
                                Image(systemName: "number.circle.fill")
                                    .foregroundStyle(.white, Color.youtubeRed)
                            }
                        }
                        .tint(.youtubeRed)
                        .onChange(of: simplifyNumbers) { newValue in
                            AnalyticsService.shared.logSimplifyNumbersToggled(newValue)
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }

                    Section {
                        NavigationLink {
                            FAQ()
                        } label: {
                            Label {
                                Text("FAQ")
                            } icon: {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundStyle(.white, Color.youtubeRed)
                            }
                        }

                        Button {
                            AnalyticsService.shared.logContactButtonTapped()
                            EmailHelper.shared.send(
                                subject: "SubWidget Feedback",
                                to: "arjun.dureja1000@gmail.com"
                            )
                        } label: {
                            FormLabel(text: "Contact", icon: "envelope.circle.fill")
                        }

                        Button {
                            AnalyticsService.shared.logRateButtontapped()
                            UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id1534958933?action=write-review")!)
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
                .frame(maxWidth: 850)
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: ViewModel())
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
