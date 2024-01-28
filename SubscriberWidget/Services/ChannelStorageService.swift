//
//  ChannelStorageService.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-21.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WidgetKit

class ChannelStorageService: ChannelStorageServiceProtocol {
    @AppStorage("channels", store: .shared) var channelData: Data = Data()
    @AppStorage("refreshFrequency", store: .shared) var refreshFrequencyData: Data = Data()
    
    func getChannels() -> [YouTubeChannel] {
        guard let channels = try? JSONDecoder().decode([YouTubeChannel].self, from: channelData) else {
            return []
        }
        
        return channels
    }
    
    func saveChannels(_ channels: [YouTubeChannel]) {
        guard let encodedChannels = try? JSONEncoder().encode(channels) else { return }
        channelData = encodedChannels
    }
    
    func getRefreshFrequency() -> RefreshFrequencies {
        guard let refreshFrequency = try? JSONDecoder().decode(RefreshFrequencies.self, from: refreshFrequencyData) else {
            return .ONE_HR
        }
        
        return refreshFrequency
    }
    
    func saveRefreshFrequency(_ frequency: RefreshFrequencies) {
        guard frequency != getRefreshFrequency() else {
            return
        }
        
        AnalyticsService.shared.logRefreshFrequencyUpdated(frequency.toString())
        guard let encodedFrequency = try? JSONEncoder().encode(frequency) else { return }
        refreshFrequencyData = encodedFrequency
        WidgetCenter.shared.reloadAllTimelines()
    }
}
