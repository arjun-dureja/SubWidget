//
//  SelectChannelAppIntent.swift
//  SubscriberWidget
//
//  Created by Codex on 2025-02-14.
//

import AppIntents

struct YouTubeChannelEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Channel"
    static var defaultQuery = YouTubeChannelEntityQuery()

    let id: String
    let channelName: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: channelName)
    }
}

struct YouTubeChannelEntityQuery: EntityQuery {
    func entities(for identifiers: [YouTubeChannelEntity.ID]) async throws -> [YouTubeChannelEntity] {
        let channels = ChannelStorageService().getChannels()

        return identifiers.map { identifier in
            channels
                .first(where: { $0.id == identifier })
                .map(YouTubeChannelEntity.init(channel:))
                ?? YouTubeChannelEntity(id: identifier, channelName: identifier)
        }
    }

    func suggestedEntities() async throws -> [YouTubeChannelEntity] {
        ChannelStorageService().getChannels().map(YouTubeChannelEntity.init(channel:))
    }
}

struct SelectChannelAppIntent: WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SelectChannelIntent"
    static let title: LocalizedStringResource = "Select Channel"
    static let description = IntentDescription("Select a YouTube channel for this widget.")

    @Parameter(title: "Channel")
    var channel: YouTubeChannelEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("View \(\.$channel)")
    }
}

private extension YouTubeChannelEntity {
    init(channel: YouTubeChannel) {
        self.init(id: channel.id, channelName: channel.channelName)
    }
}
