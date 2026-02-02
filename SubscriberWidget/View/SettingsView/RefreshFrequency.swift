//
//  RefreshFrequency.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-26.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct RefreshFrequency: View {
    @ObservedObject var viewModel: ViewModel
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false
    @Binding var showPaywall: Bool

    var body: some View {
        Picker(
            selection: $viewModel.refreshFrequency,
            label: Label(
                title: {
                    Text("Update Frequency")
                },
                icon: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundStyle(.white, Color.youtubeRed)
                }
            )
        ) {
            ForEach(RefreshFrequencies.allCases, id: \.self) { freq in
                Text(freq.toString()).tag(freq)
            }
        }
        .onChange(of: viewModel.refreshFrequency) { newValue in
            guard hasProAccess else {
                if newValue != .SIX_HR {
                    viewModel.refreshFrequency = .SIX_HR
                    AnalyticsService.shared.logPaywallShown(source: "refresh_frequency")
                    showPaywall = true
                }
                return
            }
        }
        .onAppear {
            viewModel.loadRefreshFrequency()
        }
    }
}
