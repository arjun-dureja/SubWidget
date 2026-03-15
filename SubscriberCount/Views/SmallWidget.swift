//
//  SmallWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-10-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SmallWidget: View {
    var entry: SimpleEntry?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    @AppStorage("showUpdateTime", store: .shared) var showUpdateTime: Bool = true
    @AppStorage("showWidgetRefreshButton", store: .shared) var showWidgetRefreshButton: Bool = false
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false
    let lastUpdatedTime: String = .currentTime

    var channel: YouTubeChannel? {
        entry?.channel
    }

    var isVibrant: Bool {
        return widgetRenderingMode == .vibrant
    }

    var count: String {
        switch entry?.widgetType {
        case .subscribers:
            channel?.subCount ?? "0"
        case .views:
            channel?.viewCount ?? "0"
        case .combined:
            channel?.subCount ?? "0"
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

    private var usesLocalPreviewImage: Bool {
        channel?.profileImage.hasPrefix("OnboardingAvatar-") == true
    }

    private var shouldShowRefreshButton: Bool {
        guard hasProAccess else { return false }
        guard showWidgetRefreshButton else { return false }
        guard channel?.channelName != YouTubeChannel.preview.channelName else { return false }
        return entry != nil
    }

    var body: some View {
        ZStack {
            if let entry = entry,
               let channel = channel {
                if #unavailable(iOS 17), let bgColor = channel.bgColor {
                    Color(bgColor)
                }

                VStack(alignment: .leading) {
                    HStack {
                        if Utils.isInWidget() || usesLocalPreviewImage {
                            Image(uiImage: entry.channelImage)
                                .resizable()
                                .widgetAccentedRenderingMode(.desaturated)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: showsWidgetContainerBackground ? 60 : 70, height: showsWidgetContainerBackground ? 60 : 70)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        } else {
                            AsyncImageView(url: URL(string: channel.profileImage))
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            if shouldShowRefreshButton {
                                WidgetRefreshButton(
                                    widgetType: entry.widgetType
                                )
                            } else {
                                YouTubeLogo()
                            }
                            Text(lastUpdatedTime)
                                .font(.system(size: 10))
                                .foregroundColor(accentColor)
                                .opacity(showUpdateTime ? 1 : 0)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }

                    Spacer()

                    VStack(alignment: .leading) {
                        Text(channel.channelName)
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .foregroundColor(accentColor)
                        FormattedCount(count: count)
                            .font(.system(size: showsWidgetContainerBackground ? 20 : 40))
                            .foregroundColor(isVibrant ? .white : numberColor)
                        FormattedCaption(widgetType: entry.widgetType)
                            .font(.system(size: 12))
                            .foregroundColor(accentColor)
                    }
                    .minimumScaleFactor(0.3)
                }
                .padding(showsWidgetContainerBackground ? 0 : 4)
                .containerBackground(for: .widget) {
                    if let bgColor = channel.bgColor {
                        Color(bgColor)
                    }
                }
            } else {
                ConfigurationView(baselineOffset: 5.0)
                    .containerBackground(for: .widget) {
                        if let bgColor = channel?.bgColor {
                            Color(bgColor)
                        }
                    }
            }
        }
    }
}

struct SmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidget(entry: SimpleEntry(channel: .preview, widgetType: .subscribers))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
