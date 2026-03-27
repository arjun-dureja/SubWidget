//
//  WidgetTapDestination.swift
//  SubscriberWidget
//
//  Created by Codex on 2026-03-26.
//

import Foundation

enum WidgetTapDestination: String, CaseIterable, Codable {
    case youtube
    case studio

    init(storageValue: String) {
        self = WidgetTapDestination(rawValue: storageValue) ?? .youtube
    }

    var title: String {
        switch self {
        case .youtube:
            return "YouTube"
        case .studio:
            return "Studio"
        }
    }
}
