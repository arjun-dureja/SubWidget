//
//  WidgetPreview.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetPreview: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var channel: YouTubeChannel
    @Binding var animate: Bool
    @Binding var bgColor: CGColor?
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 35, alignment: .center)
                    .foregroundColor(colorScheme == .light ? Color(UIColor.systemGray6) : .black)
                    .cornerRadius(14, corners: [.topLeft, .topRight])
                
                Text("Preview")
                    .foregroundColor(Color(UIColor.label))
                    .font(.subheadline)
                    .bold()
            }
            .padding(.horizontal, 7)
            .padding(.top, 7)
            
            
            TabView {
                SmallWidget(entry: channel)
                    .widgetBackground(bgColor: channel.bgColor, size: .small)
                MediumWidget(entry: channel)
                    .widgetBackground(bgColor: channel.bgColor, size: .medium)
            }
            .padding(.top, -40)
            .padding(.bottom, -8)
            .tabViewStyle(.page)
        }
        .frame(height: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(colorScheme == .light ? .white : Color(UIColor.systemGray6))
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    @State var channel: YouTubeChannel = .preview
    return WidgetPreview(channel: $channel, animate: .constant(false), bgColor: .constant(nil))
}
