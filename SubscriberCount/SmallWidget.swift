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
                
                VStack(alignment: .leading) {
                    HStack {
                        if Utils.isInWidget() {
                            NetworkImage(url: URL(string: entry.profileImage))
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        } else {
                            AsyncImageView(url: URL(string: entry.profileImage))
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        
                        Spacer()
                        
                        YouTubeLogo()
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 45, trailing: 0))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("\(entry.channelName)")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                        Text("\(Int(entry.subCount) ?? 0)")
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .foregroundColor(.youtubeRed)
                        Text("Total subscribers")
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                    }
                    .minimumScaleFactor(0.3)
                }
                .padding()
            } else {
                ConfigurationView(baselineOffset: 5.0)
            }
        }
    }
}
