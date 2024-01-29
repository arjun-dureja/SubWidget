//
//  LockscreenWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-09-03.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

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
                    Text("\(Int(entry.subCount) ?? 0)")
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
            .backport.containerBackground(UIColor.clear)
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
            .backport.containerBackground(UIColor.clear)
        }
    }
}

struct LockscreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockscreenWidget(entry: .preview)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
