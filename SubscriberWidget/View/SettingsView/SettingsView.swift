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
                    RefreshFrequency(viewModel: viewModel)
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
                    .onChange(of: simplifyNumbers) { _ in
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                
                Section {
                    NavigationLink {
                        FAQ(viewModel: viewModel)
                    } label: {
                        Label {
                            Text("FAQ")
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.white, Color.youtubeRed)
                        }
                    }
                    
                    Button {
                        EmailHelper.shared.send(
                            subject: "SubWidget Feedback",
                            to: "arjun.dureja1000@gmail.com"
                        )
                    } label: {
                        FormLabel(text: "Contact", icon: "envelope.circle.fill")
                    }
                    
                    Button {
                        SKStoreReviewController.requestReviewInCurrentScene()
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

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
}
