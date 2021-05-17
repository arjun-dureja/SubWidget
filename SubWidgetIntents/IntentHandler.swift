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
    
    var viewModel = ViewModel()

    func provideChannelOptionsCollection(for intent: SelectChannelIntent, with completion: @escaping (INObjectCollection<YouTubeChannelParam>?, Error?) -> Void) {
        viewModel.fetchChannelNames { (channels) in
            print(channels)
            let channelParams = channels.map { YouTubeChannelParam(channel: $0) }
            completion(INObjectCollection(items: channelParams), nil)
        }
    }
    
    func defaultChannel(for intent: SelectChannelIntent) -> YouTubeChannelParam? {
        var channelParams = [YouTubeChannelParam]()
        let group = DispatchGroup()
        group.enter()
        viewModel.fetchChannelNames { (channels) in
            channelParams = channels.map { YouTubeChannelParam(channel: $0) }
            group.leave()
        }
        group.wait()
        return channelParams[0]
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
