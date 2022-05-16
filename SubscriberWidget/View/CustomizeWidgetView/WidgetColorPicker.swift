//
//  WidgetColorPicker.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetColorPicker: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    @Binding var channel: YouTubeChannel
    @Binding var colorChanged: Bool
    @Binding var backgroundColor: Data
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 215, height: 50, alignment: .leading)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            ColorPicker("Background Color", selection: Binding(get: {
                channel.bgColor?.cgColor ?? (colorScheme == .dark ? UIColor.black.cgColor : UIColor.white.cgColor)
            }, set: { newValue in
                if UIColor(cgColor: newValue).hexStringFromColor() != channel.bgColor?.hexStringFromColor() {
                    updateBackgroundColor(with: newValue)
                }
            }), supportsOpacity: false)
            .frame(width: 190, height: 50)
            .font(.headline)
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
    
    func updateBackgroundColor(with color: CGColor) {
        viewModel.updateColorForChannel(id: channel.id, color: UIColor(cgColor: color))
        channel.bgColor = UIColor(cgColor: color)
        colorChanged = true
    }
}
