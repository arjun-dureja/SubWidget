//
//  WidgetColorPicker.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

enum ColorType: String {
    case background, accent, number

    var title: String {
        return self.rawValue.capitalized
    }
}

struct WidgetColorPicker: View {
    let colorType: ColorType

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ViewModel
    @Binding var channel: YouTubeChannel

    var currentColor: UIColor {
        switch colorType {
        case .background:
            channel.bgColor ?? UIColor(named: "Default")!
        case .accent:
            channel.accentColor ?? UIColor(named: "AccentColor")!
        case .number:
            channel.numberColor ?? UIColor(Color.youtubeRed)
        }
    }

    var body: some View {
        ColorPicker(colorType.title, selection: Binding(
            get: {
                currentColor.cgColor
            },
            set: { newValue in
                updateColor(with: newValue)
            }), supportsOpacity: false)
    }

    func updateColor(with color: CGColor) {
        let updatedColor = UIColor(cgColor: color)
        switch colorType {
        case .background:
            viewModel.updateBgColorForChannel(id: channel.id, color: updatedColor)
            channel.bgColor = updatedColor
        case .accent:
            viewModel.updateAccentColorForChannel(id: channel.id, color: updatedColor)
            channel.accentColor = updatedColor
        case .number:
            viewModel.updateNumberColorForChannel(id: channel.id, color: updatedColor)
            channel.numberColor = updatedColor
        }
    }
}
