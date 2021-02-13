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
    
    @ObservedObject var viewModel: ViewModel
    
    @State private var rotateIn3D = false
    
    @Binding var animate: Bool
    @Binding var bgColor: CGColor?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                                .frame(width: self.animate ? 329 : 155, height: 155, alignment: .leading)
                .foregroundColor(Color(bgColor ?? (colorScheme == .dark ? UIColor.black.cgColor : UIColor.white.cgColor)))
                                .shadow(radius: 16)
                                .animation(.easeInOut(duration: 0.25))

            SmallWidget(entry: YouTubeChannel(channelName: "\(viewModel.channelDetails[0].channelName)", profileImage: "\(viewModel.channelDetails[0].profileImage)", subCount: "\(Int(viewModel.subCount[0].subscriberCount)!)", channelId: "\(viewModel.channelDetails[0].channelId)"), bgColor: UIColor.clear)
                .frame(width: 155, height: 155, alignment: .leading)
                .opacity(self.animate ? 0 : 1)
                .animation(.easeInOut(duration: 0.5))
            
            MediumWidget(entry: YouTubeChannel(channelName: "\(viewModel.channelDetails[0].channelName)", profileImage: "\(viewModel.channelDetails[0].profileImage)", subCount: "\(Int(viewModel.subCount[0].subscriberCount)!)", channelId: "\(viewModel.channelDetails[0].channelId)"), bgColor: UIColor.clear)
                .frame(width: 329, height: 155, alignment: .leading)
                .opacity(self.animate ? 1 : 0)
                .animation(.easeInOut(duration: 0.5))
        }
        .rotation3DEffect(
            .degrees(rotateIn3D ? 12 : -12),
            axis: (x: rotateIn3D ? 90 : -45, y: rotateIn3D ? -45 : -90, z: 0))
        .animation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true))
        .onAppear() {
            rotateIn3D.toggle()
        }
    }
}
