//
//  WhatsNewListItem.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-07-07.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WhatsNewListItem: View {
    @Environment(\.colorScheme) var colorScheme

    var iconName: String
    var heading: String
    var description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 32))
                .foregroundStyle(.white, Color.youtubeRed)
            VStack(alignment: .leading, spacing: 2) {
                Text(heading)
                    .font(.system(size: 15, weight: .bold, design: .default))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray2 : .titleGray)
            }
        }
    }
}
