//
//  WhatsNewView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-07-07.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("What's New in SubWidget")
                .font(.system(size: 26, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 32)

            WhatsNewListItem(
                iconName: "plus.circle.fill",
                heading: "Add More Channels",
                description: "You can now add multiple channels. View the subscriber counts of several different channels from your homescreen."
            )

            WhatsNewListItem(
                iconName: "arrow.clockwise.circle.fill",
                heading: "Customize Update Frequency",
                description: "Choose how often the subscriber count should update. From every 30 minutes to every 12 hours."
            )

            WhatsNewListItem(
                iconName: "magnifyingglass.circle.fill",
                heading: "Improved Search Functionality",
                description: "SubWidget will now do a better job at finding your YouTube channel."
            )

            Spacer()

            Button {
                isPresented = false
            } label: {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.youtubeRed)
                    .cornerRadius(12)
            }

        }
        .padding(32)
        .padding(.vertical, 32)
        .background(colorScheme == .dark ? .black : Color(UIColor.systemGray6))
    }
}
