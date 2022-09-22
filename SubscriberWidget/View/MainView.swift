//
//  MainView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: ViewModel = ViewModel()

    var body: some View {
        TabView {
            WidgetListView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
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
