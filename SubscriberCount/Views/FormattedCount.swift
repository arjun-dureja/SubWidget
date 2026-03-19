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
    @AppStorage(WidgetFont.storageKey, store: .shared) private var widgetFontRawValue: String = WidgetFont.default.rawValue

    var count: String
    var fontSize: CGFloat? = nil
    var fontWeight: Font.Weight = .bold

    private var widgetFont: WidgetFont {
        WidgetFont(rawValue: widgetFontRawValue) ?? .default
    }

    var formatted: String {
        if simplifyNumbers {
            return count.simplified()
        }

        return count.formattedWithSeparator()
    }

    var body: some View {
        Text(formatted)
            .if(fontSize != nil) { view in
                view.font(widgetFont.font(size: fontSize ?? 17, weight: fontWeight))
            }
            .if(fontSize == nil) { view in
                view.fontWeight(fontWeight)
            }
    }
}
