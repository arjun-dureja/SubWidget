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
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 155, height: 155, alignment: .leading)
                        .foregroundColor(Color((channel.bgColor ?? (colorScheme == .dark ? UIColor.black : UIColor.white))))
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.33), radius: 8)
                    
                    SmallWidget(entry: channel)
                        .backport.padding()
                        .frame(width: 160, height: 160, alignment: .leading)
                        .cornerRadius(25)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 329, height: 155, alignment: .leading)
                        .foregroundColor(Color((channel.bgColor ?? (colorScheme == .dark ? UIColor.black : UIColor.white))))
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), radius: 8)
                    
                    MediumWidget(entry: channel)
                        .backport.padding()
                        .frame(width: 329, height: 155, alignment: .leading)
                        .cornerRadius(25)
                }
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
