//
//  WidgetWithBackground.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-13.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

enum WidgetSize {
    case small
    case medium

    var width: CGFloat {
        switch self {
        case .small: return 155
        case .medium: return 328
        }
    }
}

struct WidgetBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var bgColor: UIColor?
    var size: WidgetSize
    var showsShadow: Bool

    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: size.width, height: 155)
                .foregroundColor(Color((bgColor ?? (colorScheme == .dark ? UIColor.black : UIColor.white))))
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.33),
                    radius: showsShadow ? 8 : 0
                )

            content
                .padding()
                .frame(width: size.width, height: 155)
                .cornerRadius(25)
        }
    }
}

extension View {
    func widgetBackground(bgColor: UIColor?, size: WidgetSize, showsShadow: Bool = true) -> some View {
        self.modifier(WidgetBackgroundModifier(bgColor: bgColor, size: size, showsShadow: showsShadow))
    }
}
