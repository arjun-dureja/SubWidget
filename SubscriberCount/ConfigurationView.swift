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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    
    var baselineOffset: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Your Channel")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)

                Spacer()

                YouTubeLogo()
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 16, trailing: 0))
            }
            
            HStack {
                Text(Image(systemName: "1.circle.fill"))
                    .foregroundColor(.youtubeRed)
                    .baselineOffset(baselineOffset)
                Text("Add a channel in the app")
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
            }

            HStack {
                Text(Image(systemName: "2.circle.fill"))
                    .foregroundColor(.youtubeRed)
                    .baselineOffset(baselineOffset)
                Text("Hold and tap 'Edit Widget'")
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(showsWidgetContainerBackground ? 0 : 6)
        .backport.containerBackground(.clear)
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(baselineOffset: 5.0)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
