//
//  MainView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WishKit
import WidgetKit
import ConfettiSwiftUI

struct MainView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var currentTab = 0
    @State private var confettiTrigger = 0

    init() {
        WishKit.configure(with: Constants.wishKitApiKey)
        WishKit.config.statusBadge = .hide
        WishKit.config.commentSection = .hide
        WishKit.config.emailField = .none
        WishKit.config.buttons.addButton.bottomPadding = .large
        WishKit.config.buttons.segmentedControl.display = .hide
        WishKit.config.allowUndoVote = true

        WishKit.theme.primaryColor = .youtubeRed
        WishKit.theme.secondaryColor = .set(light: .white, dark: Color(UIColor.systemGray6))
        WishKit.theme.tertiaryColor = .set(light: Color(UIColor.systemGray6), dark: .black)
    }

    var body: some View {
        TabView(selection: $currentTab) {
            WidgetListView(viewModel: viewModel)
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .onAppear {
                    currentTab = 0
                }

            WishKit.FeedbackListView().withNavigation()
                .tag(1)
                .tabItem {
                    Label("Wishlist", systemImage: "lightbulb.fill")
                }
                .onAppear {
                    currentTab = 1
                }

            SettingsView(viewModel: viewModel)
                .tag(2)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .onAppear {
                    currentTab = 2
                }
        }
        .accentColor(.youtubeRed)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onReceive(NotificationCenter.default.publisher(for: .revenueCatPurchaseCompleted)) { _ in
            confettiTrigger += 1
        }
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 40,
            rainHeight: 750,
            radius: 500,
            repetitions: 1,
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
