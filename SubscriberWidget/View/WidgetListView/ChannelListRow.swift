//
//  ChannelListRow.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ChannelListRow: View {
    @Environment(\.colorScheme) var colorScheme
    @State var channel: YouTubeChannel

    var body: some View {
        HStack(spacing: 15) {
            AsyncImageView(url: URL(string: channel.profileImage))
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(channel.channelName)
                    .fontWeight(.bold)
                    .font(.system(size: 18))
                    .foregroundColor(Color("AccentColor"))
                FormattedCount(count: channel.subCount)
                    .font(.system(size: 23))
                    .foregroundColor(.youtubeRed)
                Text("Total subscribers")
                    .font(.system(size: 13))
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .padding(.vertical, 8)
    }
}
