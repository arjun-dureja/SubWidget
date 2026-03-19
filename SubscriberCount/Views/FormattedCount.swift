//
//  FormattedSubCount.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-27.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FormattedCount: View {
    @AppStorage("simplifyNumbers", store: .shared) var simplifyNumbers: Bool = false
    @AppStorage("widgetFont", store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue

    var count: String
    var fontSize: CGFloat? = nil
    var fontWeight: Font.Weight = .bold

    private var widgetFont: WidgetFont {
        WidgetFont(storageValue: widgetFontRawValue)
    }

    var formatted: String {
        if simplifyNumbers {
            return count.simplified()
        }

        return count.formattedWithSeparator()
    }

    var body: some View {
        Text(formatted)
            // Widget call sites pass an explicit size so the global widget font applies only there.
            // Non-widget app views continue to provide their own `.font(...)` externally.
            .if(fontSize != nil) { view in
                view.font(widgetFont.font(size: fontSize ?? 17, weight: fontWeight))
            }
            .if(fontSize == nil) { view in
                view.fontWeight(fontWeight)
            }
    }
}
