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
    @AppStorage(WidgetFont.storageKey, store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue

    var channel: YouTubeChannel? {
        entry?.channel
    }

    private var widgetFont: WidgetFont {
        WidgetFont(rawValue: widgetFontRawValue) ?? .default
    }

    private var usesLocalPreviewImage: Bool {
        channel?.profileImage.hasPrefix("OnboardingAvatar-") == true
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

    var body: some View {
        if let entry = entry,
           let channel = channel {
            HStack {
                if Utils.isInWidget() || usesLocalPreviewImage {
                    Image(uiImage: entry.channelImage)
                        .resizable()
                        .widgetAccentedRenderingMode(.desaturated)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                } else {
                    AsyncImageView(url: URL(string: channel.profileImage))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }

                VStack(alignment: .leading) {
                    Text(channel.channelName)
                        .font(widgetFont.font(size: 14, weight: .bold))
                        .minimumScaleFactor(0.01)
                        .lineLimit(2)
                    FormattedCount(count: count, fontSize: 16)
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    FormattedCaption(widgetType: entry.widgetType)
                        .font(widgetFont.font(size: 11, weight: .medium))
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                }
            }
            .containerBackground(.clear, for: .widget)
        } else {
            // Configuration View
            VStack(alignment: .leading) {
                Text("Select Your Channel")
                    .font(widgetFont.font(size: 13, weight: .bold))
                Text("- Add a channel in the app, then tap this widget while editing")
                    .font(widgetFont.font(size: 11, weight: .medium))
            }
            .containerBackground(.clear, for: .widget)
        }
    }
}

struct LockscreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockscreenWidget(entry: SimpleEntry(channel: .preview, widgetType: .subscribers))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
