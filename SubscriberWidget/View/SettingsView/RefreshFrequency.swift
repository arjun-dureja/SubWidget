//
//  RefreshFrequency.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-26.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct RefreshFrequency: View {
    @StateObject var viewModel: ViewModel

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
    }
}
