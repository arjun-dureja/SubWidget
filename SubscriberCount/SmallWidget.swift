//
//  SmallWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-10-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct SmallWidget: View {
    var entry: YouTubeChannel?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if let entry = entry {
                if let bgColor = entry.bgColor {
                    Color(bgColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if Utils.isInWidget() {
                            NetworkImage(url: URL(string: entry.profileImage))
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        } else {
                            AsyncImageView(url: URL(string: entry.profileImage))
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }

                        Spacer()

                        YouTubeLogo()
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 45, trailing: 0))
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

                    VStack(alignment: .leading) {
                        Text("\(entry.channelName)")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                        Text("\(Int(entry.subCount)!)")
                            .fontWeight(.bold)
                            .font(.system(size: 26))
                            .foregroundColor(.youtubeRed)
                        Text("Total subscribers")
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                    }
                    .minimumScaleFactor(0.3)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                }
            } else {
                ConfigurationView(baselineOffset: 5.0)
            }
        }
    }
}
