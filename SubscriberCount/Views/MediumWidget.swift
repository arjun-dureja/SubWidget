//
//  MediumWidget.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-10-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

private enum CountMode {
    case single(count: String, type: WidgetType)
    case combined(subscribers: String, views: String)
}

struct MediumWidget: View {
    var entry: SimpleEntry?
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("showUpdateTime", store: .shared) var showUpdateTime: Bool = true
    let lastUpdatedTime: String = .currentTime

    var channel: YouTubeChannel? {
        entry?.channel
    }

    private var subCount: String {
        channel?.subCount ?? "0"
    }

    private var viewCount: String {
        channel?.viewCount ?? "0"
    }

    private var countMode: CountMode {
        switch entry?.widgetType {
        case .subscribers:
            return .single(count: subCount, type: .subscribers)
        case .views:
            return .single(count: viewCount, type: .views)
        case .combined:
            return .combined(subscribers: subCount, views: viewCount)
        case nil:
            return .single(count: "0", type: .subscribers)
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

    var body: some View {
        ZStack {
            if let entry = entry,
               let channel = channel {
                HStack {
                    if Utils.isInWidget() || usesLocalPreviewImage {
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

                        switch countMode {
                        case let .single(count, type):
                            FormattedCount(count: count)
                                .font(.system(size: 32))
                                .lineLimit(1)
                                .foregroundColor(numberColor)
                            FormattedCaption(widgetType: type)
                                .font(.system(size: 15))
                                .lineLimit(1)
                                .foregroundColor(accentColor)
                        case let .combined(subscribers, views):
                            VStack(alignment: .leading, spacing: 2) {
                                FormattedCount(count: subscribers)
                                    .font(.system(size: 24))
                                    .foregroundColor(numberColor)
                                FormattedCaption(widgetType: .subscribers)
                                    .font(.system(size: 12))
                                    .foregroundColor(accentColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                FormattedCount(count: views)
                                    .font(.system(size: 24))
                                    .foregroundColor(numberColor)
                                FormattedCaption(widgetType: .views)
                                    .font(.system(size: 12))
                                    .foregroundColor(accentColor)
                            }
                        }
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
    }
}

struct MediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: SimpleEntry(channel: .preview, widgetType: .subscribers))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
