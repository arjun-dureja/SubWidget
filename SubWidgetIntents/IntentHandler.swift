//
//  IntentHandler.swift
//  SubWidgetIntents
//
//  Created by Arjun Dureja on 2021-02-15.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import Intents
import Foundation

class IntentHandler: INExtension, SelectChannelIntentHandling {
    func provideChannelOptionsCollection(for intent: SelectChannelIntent, with completion: @escaping (INObjectCollection<YouTubeChannelParam>?, Error?) -> Void) {
        Task {
            let viewModel = await ViewModel()
            let channels = await viewModel.getChannels()
            let channelParams = channels.map { YouTubeChannelParam(channel: $0) }
            completion(INObjectCollection(items: channelParams), nil)
        }
    }
}
