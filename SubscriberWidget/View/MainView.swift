//
//  MainView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WishKit

struct MainView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    init() {
        WishKit.configure(with: Constants.wishKitApiKey)
        WishKit.config.statusBadge = .hide
        WishKit.config.commentSection = .hide
        WishKit.config.buttons.addButton.bottomPadding = .large
        WishKit.config.buttons.segmentedControl.display = .hide

        WishKit.theme.primaryColor = .youtubeRed
        WishKit.theme.secondaryColor = .set(light: .white, dark: Color(UIColor.systemGray6))
        WishKit.theme.tertiaryColor = .set(light: Color(UIColor.systemGray6), dark: .black)
    }

    var body: some View {
        TabView {
            WidgetListView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            WishKit.view.withNavigation()
                .tabItem {
                    Label("Wishlist", systemImage: "lightbulb.fill")
                }
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.youtubeRed)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
