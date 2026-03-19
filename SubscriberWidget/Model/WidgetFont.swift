//
//  WidgetFont.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import SwiftUI

enum WidgetFont: String, CaseIterable, Codable {
    case `default`
    case rounded
    case serif
    case monospaced

    static let storageKey = "widgetFont"

    init(storageValue: String) {
        self = WidgetFont(rawValue: storageValue) ?? .default
    }

    var displayName: LocalizedStringResource {
        switch self {
        case .default:
            "Default"
        case .rounded:
            "Rounded"
        case .serif:
            "Serif"
        case .monospaced:
            "Monospaced"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .default:
            return .system(size: size, weight: weight, design: .default)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        }
    }
}
