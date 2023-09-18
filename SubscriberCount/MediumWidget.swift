//
//  MediumWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-10-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct MediumWidget: View {
    var entry: YouTubeChannel?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if let entry = entry {
                if let bgColor = entry.bgColor {
                    Color(bgColor)
                }
                HStack {
                    if Utils.isInWidget() {
                        NetworkImage(url: URL(string: entry.profileImage))
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(.leading, 8)
                            .padding(.trailing)
                    } else {
                        AsyncImageView(url: URL(string: entry.profileImage))
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(.horizontal, 8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(entry.channelName)")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .lineLimit(entry.channelName.firstIndex(of: " ") != nil && entry.channelName.count > 15 ? .max : 1)
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                        Text("\(Int(entry.subCount) ?? 0)")
                            .fontWeight(.bold)
                            .font(.system(size: 32))
                            .lineLimit(1)
                            .foregroundColor(.youtubeRed)
                        Text("Total subscribers")
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                    }
                    .minimumScaleFactor(0.3)
                    
                    Spacer()
                    
                    YouTubeLogo()
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                .minimumScaleFactor(0.3)
                .padding()
            } else {
                ConfigurationView(baselineOffset: 0.0)
            }
        }
    }
}
