//
//  RefreshFrequency.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-26.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct RefreshFrequency: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        Picker(
            selection: $viewModel.refreshFrequency,
            label: Label("Update Frequency", systemImage: "arrow.clockwise.circle.fill")
        ) {
            ForEach(RefreshFrequencies.allCases, id: \.self) { freq in
                Text(freq.rawValue).tag(freq)
            }
        }
    }
}

struct RefreshFrequency_Previews: PreviewProvider {
    static var previews: some View {
        RefreshFrequency()
    }
}
