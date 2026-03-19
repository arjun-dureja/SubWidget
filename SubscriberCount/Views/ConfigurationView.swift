//
//  ConfigurationView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-05-28.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

struct ConfigurationView: View {
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    @AppStorage("widgetFont", store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue

    var baselineOffset: CGFloat

    private var widgetFont: WidgetFont {
        WidgetFont(storageValue: widgetFontRawValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Your Channel")
                    .font(widgetFont.font(size: 14, weight: .bold))
                    .foregroundColor(Color("AccentColor"))

                Spacer()

                YouTubeLogo()
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 16, trailing: 0))
            }

            HStack {
                Text(Image(systemName: "1.circle.fill"))
                    .foregroundColor(.youtubeRed)
                    .baselineOffset(baselineOffset)
                Text("Add a channel in the app")
                    .font(widgetFont.font(size: 13, weight: .medium))
                    .foregroundColor(Color("AccentColor"))
            }

            HStack {
                Text(Image(systemName: "2.circle.fill"))
                    .foregroundColor(.youtubeRed)
                    .baselineOffset(baselineOffset)
                Text("Hold and tap 'Edit Widget'")
                    .font(widgetFont.font(size: 13, weight: .medium))
                    .foregroundColor(Color("AccentColor"))
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(showsWidgetContainerBackground ? 0 : 6)
        .minimumScaleFactor(0.25)
        .containerBackground(.clear, for: .widget)
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(baselineOffset: 5.0)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
