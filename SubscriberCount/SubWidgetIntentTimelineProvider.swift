//
//  SubWidgetIntentTimelineProvider.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-15.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import Foundation
import WidgetKit

struct SubWidgetIntentTimelineProvider: IntentTimelineProvider {
    
    typealias Entry = SimpleEntry
    typealias Intent = SelectChannelIntent
    
    var viewModel = ViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "", profileImage: "", subCount: "", channelId: ""))
    }
    
    func getSnapshot(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        fetchChannel(for: configuration.channel ?? YouTubeChannelParam.global) { (result) in
            completion(result)
        }
    }
    
    func getTimeline(for configuration: SelectChannelIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        fetchChannel(for: configuration.channel ?? YouTubeChannelParam.global) { (result) in
            let timeline = Timeline(entries: [result], policy: .after(Date().addingTimeInterval(60 * 30)))
            completion(timeline)
        }
    }
    
    private func fetchChannel(for param: YouTubeChannelParam, completion: @escaping (SimpleEntry) -> ()) {
        guard let id = param.identifier else { return }
        
        viewModel.fetchChannelNames(completion: { (channels) in
            for channel in channels {
                if channel.id == id {
                    viewModel.getChannelDetailsFromId(for: channel.channelId) { (resultChannel) in
                        if let resultChannel = resultChannel {
                            var finalChannel = resultChannel
                            finalChannel.bgColor = channel.bgColor
                            completion(SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: finalChannel))
                        }
                    }
                    break
                }
            }
        })
    }
}


