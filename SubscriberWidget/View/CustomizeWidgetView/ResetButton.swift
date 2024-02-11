//
//  ResetButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ResetButton: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var channel: YouTubeChannel

    var body: some View {
        Button(action: resetTapped, label: {
            Text("Reset")
                .bold()
                .font(.footnote)
        })
    }

    func resetTapped() {
        AnalyticsService.shared.logResetColorTapped()
        viewModel.resetAllColors(id: channel.id)
        channel.bgColor = nil
        channel.accentColor = nil
        channel.numberColor = nil
    }
}
