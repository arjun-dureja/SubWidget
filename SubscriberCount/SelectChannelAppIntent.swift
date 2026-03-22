//
//  SelectChannelAppIntent.swift
//  SubscriberWidget
//
//  Created by Codex on 2025-02-14.
//

import AppIntents

struct YouTubeChannelParam: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Channel"
    static var defaultQuery = YouTubeChannelParamQuery()

    let identifier: String
    let displayString: String

    var id: String {
        identifier
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: displayString)
    }
}

struct YouTubeChannelParamQuery: EntityQuery {
    func entities(for identifiers: [YouTubeChannelParam.ID]) async throws -> [YouTubeChannelParam] {
        let channels = ChannelStorageService().getChannels()

        return identifiers.map { identifier in
            channels
                .first(where: { $0.id == identifier })
                .map(YouTubeChannelParam.init(channel:))
                ?? YouTubeChannelParam(identifier: identifier, displayString: identifier)
        }
    }

    func suggestedEntities() async throws -> [YouTubeChannelParam] {
        ChannelStorageService().getChannels().map(YouTubeChannelParam.init(channel:))
    }
}

struct SelectChannelAppIntent: WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SelectChannelIntent"
    static let title: LocalizedStringResource = "Select Channel"
    static let description = IntentDescription("Select a YouTube channel for this widget.")

    @Parameter(title: "Channel")
    var channel: YouTubeChannelParam?

    static var parameterSummary: some ParameterSummary {
        Summary("View \(\.$channel)")
    }
}

private extension YouTubeChannelParam {
    init(channel: YouTubeChannel) {
        self.init(identifier: channel.id, displayString: channel.channelName)
    }
}
