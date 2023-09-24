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
    
    @State private var rotateIn3D = false
    
    @Binding var animate: Bool
    @Binding var bgColor: CGColor?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: self.animate ? 329 : 155, height: 155, alignment: .leading)
                .foregroundColor(Color((channel.bgColor ?? (colorScheme == .dark ? UIColor.black : UIColor.white))))
                .shadow(radius: 16)
            
            SmallWidget(entry: channel)
                .padding()
                .frame(width: 160, height: 160, alignment: .leading)
                .cornerRadius(25)
                .opacity(self.animate ? 0 : 1)
            
            MediumWidget(entry: channel)
                .padding()
                .frame(width: 329, height: 155, alignment: .leading)
                .cornerRadius(25)
                .opacity(self.animate ? 1 : 0)
        }
        #if !targetEnvironment(macCatalyst)
        .rotation3DEffect(
            .degrees(rotateIn3D ? 12 : -12),
            axis: (x: rotateIn3D ? 90 : -45, y: rotateIn3D ? -45 : -90, z: 0))
        .onAppear() {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                rotateIn3D = true
            }
        }
        #endif
    }
}
