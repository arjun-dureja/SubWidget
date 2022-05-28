//
//  ConfigurationView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-05-28.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ConfigurationView: View {
    @Environment(\.colorScheme) var colorScheme
    var baselineOffset: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Your Channel")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .foregroundColor(.youtubeRed)
                Spacer()
                Image("youtube-logo")
                    .resizable()
                    .frame(width: 20.5, height: 14.6)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 16, trailing: 0))
            }

            HStack {
                Text(Image(systemName: "1.circle.fill"))
                    .foregroundColor(.youtubeRed)
                    .baselineOffset(baselineOffset)
                Text("Add a channel in the app")
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
            }
            HStack {
                Text(Image(systemName: "2.circle.fill"))
                    .foregroundColor(.youtubeRed)
                    .baselineOffset(baselineOffset)
                Text("Hold and tap 'Edit Widget'")
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
            }

            Spacer()
        }
        .padding(EdgeInsets(top: 16 , leading: 16, bottom: 0, trailing: 16))
    }
}
