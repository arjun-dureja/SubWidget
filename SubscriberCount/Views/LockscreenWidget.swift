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
    var entry: SimpleEntry?

    var channel: YouTubeChannel? {
        entry?.channel
    }

    var count: String {
        switch entry?.widgetType {
        case .subscribers:
            channel?.subCount ?? "0"
        case .views:
            channel?.viewCount ?? "0"
        case nil:
            "0"
        }
    }

    var body: some View {
        if let entry = entry,
           let channel = channel {
            HStack {
                NetworkImage(url: URL(string: channel.profileImage))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(radius: 2)

                VStack(alignment: .leading) {
                    Text(channel.channelName)
                        .fontWeight(.bold)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.01)
                        .lineLimit(2)
                    FormattedCount(count: count)
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    FormattedCaption(widgetType: entry.widgetType)
                        .fontWeight(.medium)
                        .font(.system(size: 11))
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                }
            }
            .backport.containerBackground(UIColor.clear)
            .widgetURL(channel.deeplinkUrl)
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
        LockscreenWidget(entry: SimpleEntry(channel: .preview, widgetType: .subscribers))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
