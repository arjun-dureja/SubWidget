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
    @AppStorage("showWidgetRefreshButton", store: .shared) var showWidgetRefreshButton: Bool = false
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false
    @AppStorage("widgetFont", store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue

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

    private var widgetFont: WidgetFont {
        WidgetFont(storageValue: widgetFontRawValue)
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
                            .font(widgetFont.font(size: 24, weight: .bold))
                            .lineLimit(channel.channelName.firstIndex(of: " ") != nil && channel.channelName.count > 15 ? .max : 1)
                            .foregroundColor(accentColor)

                        switch countMode {
                        case let .single(count, type):
                            FormattedCount(count: count, fontSize: 32)
                                .lineLimit(1)
                                .foregroundColor(numberColor)
                            FormattedCaption(widgetType: type)
                                .font(widgetFont.font(size: 15))
                                .lineLimit(1)
                                .foregroundColor(accentColor)
                        case let .combined(subscribers, views):
                            VStack(alignment: .leading, spacing: 2) {
                                FormattedCount(count: subscribers, fontSize: 24)
                                    .foregroundColor(numberColor)
                                FormattedCaption(widgetType: .subscribers)
                                    .font(widgetFont.font(size: 12))
                                    .foregroundColor(accentColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                FormattedCount(count: views, fontSize: 24)
                                    .foregroundColor(numberColor)
                                FormattedCaption(widgetType: .views)
                                    .font(widgetFont.font(size: 12))
                                    .foregroundColor(accentColor)
                            }
                        }
                    }
                    .minimumScaleFactor(0.3)

                    Spacer()

                    VStack(alignment: .trailing) {
                        Group {
                            if shouldShowRefreshButton {
                                WidgetRefreshButton(
                                    widgetType: entry.widgetType
                                )
                            } else {
                                YouTubeLogo()
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)

                        Text(lastUpdatedTime)
                            .font(widgetFont.font(size: 11))
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
