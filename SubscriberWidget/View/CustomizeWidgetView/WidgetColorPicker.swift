//
//  WidgetColorPicker.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetColorPicker: View {
    let title: LocalizedStringResource
    let colorType: ColorType
    let onSelectColor: (_ color: CGColor, _ type: ColorType) -> Void

    @Environment(\.colorScheme) var colorScheme
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
        ColorPicker(String(localized: title), selection: Binding(
            get: {
                currentColor.cgColor
            },
            set: { newValue in
                onSelectColor(newValue, colorType)
            }), supportsOpacity: false)
    }
}
