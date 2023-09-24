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
    var entry: YouTubeChannel?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var isVibrant: Bool {
        return widgetRenderingMode == .vibrant
    }

    var body: some View {
        ZStack {
            if let entry = entry {
                if #unavailable(iOS 17), let bgColor = entry.bgColor {
                    Color(bgColor)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        if Utils.isInWidget() {
                            NetworkImage(url: URL(string: entry.profileImage))
                                .frame(width: showsWidgetContainerBackground ? 60 : 70, height: showsWidgetContainerBackground ? 60 : 70)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        } else {
                            AsyncImageView(url: URL(string: entry.profileImage))
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        
                        Spacer()
                        
                        YouTubeLogo()
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 45, trailing: 0))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("\(entry.channelName)")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                        Text("\(Int(entry.subCount) ?? 0)")
                            .fontWeight(.bold)
                            .font(.system(size: showsWidgetContainerBackground ? 20 : 40))
                            .foregroundColor(isVibrant ? .white : .youtubeRed)
                        Text("Total subscribers")
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .dark ? .darkModeTitleGray : .titleGray)
                    }
                    .minimumScaleFactor(0.3)
                }
                .padding(showsWidgetContainerBackground ? 0 : 4)
                .backport.containerBackground(entry.bgColor)
            } else {
                ConfigurationView(baselineOffset: 5.0)
                    .backport.containerBackground(entry?.bgColor)
            }
        }
    }
}

struct SmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidget(entry: YouTubeChannel(channelName: "Test Channel", profileImage: "https://yt3.ggpht.com/ytc/AAUvwnga3eXKkQgGU-3j1_jccZ0K9m6MbjepV0ksd7eBEw=s800-c-k-c0x00ffffff-no-rj", subCount: "111000000", channelId: ""))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct Backport<Content> {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }
}

extension View {
    var backport: Backport<Self> { Backport(self) }
}

extension Backport where Content: View {
    @ViewBuilder func containerBackground(_ bgColor: UIColor?) -> some View {
        if #available(iOS 17, *) {
            content.containerBackground(for: .widget) {
                if let bgColor {
                    Color(bgColor)
                }
            }
        } else {
            content
        }
    }
}
