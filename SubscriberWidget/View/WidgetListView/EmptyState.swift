//
//  EmptyState.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-07-31.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct EmptyState: View {
    var addWidgetTapped: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            MediumWidget(entry: SimpleEntry(channel: .preview, widgetType: .subscribers))
                .redacted(reason: .placeholder)
                .frame(width: 329, height: 155, alignment: .leading)

            Text("No channels added yet")
                .font(.system(size: 16, weight: .bold, design: .default))
            Text("Add a channel to get started.")
                .font(.system(size: 14))
                .foregroundColor(colorScheme == .dark ? .darkModeTitleGray2 : .titleGray)

            Button(
                action: addWidgetTapped,
                label: {
                    Text("Add a Channel")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 250, height: 15)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.youtubeRed)
                        .cornerRadius(16)
                }
            )
            .padding(.top, 16)
        }
        .padding(.horizontal)
        .padding(.bottom, 64)
    }
}
