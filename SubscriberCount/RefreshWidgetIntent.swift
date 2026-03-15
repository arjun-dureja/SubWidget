//
//  RefreshWidgetIntent.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import AppIntents
import WidgetKit

extension WidgetType {
    var widgetKind: String {
        switch self {
        case .subscribers:
            return "SubscriberCount"
        case .views:
            return "ViewCount"
        case .combined:
            return "CombinedCount"
        }
    }
}

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"
    static var description = IntentDescription("Refreshes the widget timeline.")
    static var openAppWhenRun = false
    static var isDiscoverable = false

    @Parameter(title: "Widget Kind")
    var widgetKind: String

    init() {
        self.widgetKind = WidgetType.subscribers.widgetKind
    }

    init(widgetKind: String) {
        self.widgetKind = widgetKind
    }

    func perform() async throws -> some IntentResult {
        AnalyticsService.shared.logWidgetManualRefreshTapped(widgetKind: widgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        return .result()
    }
}
