//
//  LockscreenWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-09-03.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct LockscreenWidget: View {
    var entry: YouTubeChannel?
    
    var body: some View {
        if let entry = entry {
            HStack {
                NetworkImage(url: URL(string: entry.profileImage))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 2)

                VStack(alignment: .leading) {
                    Text(entry.channelName)
                        .fontWeight(.bold)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.01)
                        .lineLimit(2)
                    Text("\(Int(entry.subCount)!)")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    Text("Total subscribers")
                        .fontWeight(.medium)
                        .font(.system(size: 11))
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                }
            }
        } else {
            // Configuration View
            VStack(alignment: .leading) {
                Text("Select Your Channel")
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                Text("- Add a channel in the app, then tap this widget while editing")
                    .font(.system(size: 11))
                    .fontWeight(.medium)
            }
        }
    }
}

