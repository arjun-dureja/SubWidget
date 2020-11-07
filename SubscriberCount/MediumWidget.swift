//
//  MediumWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-10-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct MediumWidget: View {
    var entry: YouTubeChannel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: -5) {
            NetworkImage(url: URL(string: entry.profileImage))
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 3)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("\(entry.channelName)")
                    .fontWeight(.bold)
                    .font(.system(size: 26))
                    .lineLimit(entry.channelName.firstIndex(of: " ") != nil && entry.channelName.count > 15 ? .max : 1)
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                Text("\(Int(entry.subCount)!)")
                    .fontWeight(.bold)
                    .font(.system(size: 36))
                    .lineLimit(1)
                    .foregroundColor(.youtubeRed)
                Text("Total subscribers")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
            }
            .minimumScaleFactor(0.3)
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            
            Spacer()
            
            Image("youtube-logo")
                .resizable()
                .frame(width: 20.5, height: 14.6)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 90, trailing: 0))
        }
        .minimumScaleFactor(0.3)
        .padding()
    }
}
