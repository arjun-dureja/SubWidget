//
//  MediumWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-10-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

struct MediumWidget: View {
    var entry: SimpleEntry?
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("showUpdateTime", store: .shared) var showUpdateTime: Bool = true
    let lastUpdatedTime: String = .currentTime

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

    var accentColor: Color {
        if let color = channel?.accentColor {
            return Color(color)
        }
        return Color("AccentColor")
    }

    var numberColor: Color {
        if let color = channel?.numberColor {
            return Color(color)
        }
        return .youtubeRed
    }

    var body: some View {
        ZStack {
            if let entry = entry,
               let channel = channel {
                HStack {
                    if Utils.isInWidget() {
                        Image(uiImage: entry.channelImage)
                            .resizable()
                            .widgetAccentedRenderingMode(.desaturated)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(.horizontal, 8)
                    } else {
                        AsyncImageView(url: URL(string: channel.profileImage))
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(.horizontal, 8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(channel.channelName)
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .lineLimit(channel.channelName.firstIndex(of: " ") != nil && channel.channelName.count > 15 ? .max : 1)
                            .foregroundColor(accentColor)
                        FormattedCount(count: count)
                            .font(.system(size: 32))
                            .lineLimit(1)
                            .foregroundColor(numberColor)
                        FormattedCaption(widgetType: entry.widgetType)
                            .font(.system(size: 15))
                            .lineLimit(1)
                            .foregroundColor(accentColor)
                    }
                    .minimumScaleFactor(0.3)

                    Spacer()

                    VStack(alignment: .trailing) {
                        YouTubeLogo()
                            .frame(maxHeight: .infinity, alignment: .top)

                        Text(lastUpdatedTime)
                            .font(.system(size: 11))
                            .foregroundColor(accentColor)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .opacity(showUpdateTime ? 1 : 0)
                    }
                }
                .minimumScaleFactor(0.3)
                .containerBackground(for: .widget) {
                    if let bgColor = channel.bgColor {
                        Color(bgColor)
                    }
                }
            } else {
                ConfigurationView(baselineOffset: 0.0)
                    .containerBackground(for: .widget) {
                        if let bgColor = channel?.bgColor {
                            Color(bgColor)
                        }
                    }
            }
        }
        .widgetURL(channel?.deeplinkUrl)
    }
}

struct MediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: SimpleEntry(channel: .preview, widgetType: .subscribers))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
