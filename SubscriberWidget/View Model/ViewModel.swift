//
//  APIManager.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

class ViewModel: ObservableObject {
    @Published var channels: [YouTubeChannel] = []
    @Published var isLoading = false
    
    @AppStorage("channels", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var singleChannelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
    
    var color: UIColor? {
        var color: UIColor?
        
        do {
            color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backgroundColor)
        } catch let error {
            print("\(error.localizedDescription)")
        }
        return color ?? nil
    }
    
    init() {
        isLoading = true
        guard let decodedChannels = try? JSONDecoder().decode([YouTubeChannel].self, from: channelData) else {
            print("Channel list is empty")
            guard let channelId = try? JSONDecoder().decode(String.self, from: singleChannelData) else {
                print("First time user")
                self.getChannelDetailsFromId(for: "UC-lHJZR3Gqxm24_Vd_AJ5Yw") { (channel) in
                    if let channel = channel {
                        withAnimation {
                            self.channels.append(channel)
                        }
                        guard let encodedChannels = try? JSONEncoder().encode([channel]) else { return }
                        self.channelData = encodedChannels
                    }
                }
                isLoading = false
                return
            }
            self.getChannelDetailsFromId(for: channelId) { (channel) in
                if let channel = channel {
                    var channel = channel
                    if let color = self.color {
                        print("Updating old color")
                        channel.bgColor = color
                    }
                    withAnimation {
                        self.channels.append(channel)
                    }
                    guard let encodedChannels = try? JSONEncoder().encode([channel]) else { return }
                    self.channelData = encodedChannels
                }
            }
            isLoading = false
            return
        }
        print("Channel list has values")
        withAnimation {
            self.channels = decodedChannels
        }
        for i in 0..<channels.count {
            print(channels[i])
            self.getChannelDetailsFromId(for: channels[i].channelId) { [weak self] (channel) in
                if let channel = channel {
                    print(channel)
                    self?.channels[i].subCount = channel.subCount
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    /// Get youtube channel details by channel username
    /// - Parameters:
    ///   - channelName: YouTube channel username
    ///   - completion: Sends a bool to determine if the API call was successful and an optional YouTubeChannel
    func getChannelDetails(for channelName: String, completion: @escaping (YouTubeChannel?) -> ()) {
        print("Performing network call")
        // YouTube data API URL
        let channelNameWithoutSpaces = channelName.replacingOccurrences(of: " ", with: "")
        guard let snippetURL = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(channelNameWithoutSpaces)&key=\(Constants.apiKey)&type=channel") else {
            return
        }
        
        URLSession.shared.dataTask(with: snippetURL) { (data, response, error) in
            do {
                let response = try JSONDecoder().decode(ChannelResponse.self, from: data!)

                // Check if any channels were returned
                if response.items!.count == 0 {
                    completion(nil)
                    return
                }
                self.getSubCount(channel: response.items![0]) { (channel) in
                    completion(channel)
                }
            }
            catch {
                completion(nil)
            }
        }.resume()
    }
    
    /// Get youtube channel details by channel ID
    /// - Parameters:
    ///   - id: YouTube channel ID
    ///   - completion: Sends a bool to determine if the API call was successful and an optional YouTubeChannel
    func getChannelDetailsFromId(for id: String, completion: @escaping (YouTubeChannel?) -> ()) {
        print("Performing network call")
        // YouTube data API URL
        let idWithoutSpaces = id.replacingOccurrences(of: " ", with: "")
        guard let snippetURL = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(idWithoutSpaces)&key=\(Constants.apiKey)") else {
            return
        }
        
        URLSession.shared.dataTask(with: snippetURL) { (data, response, error) in
            do {
                let response = try JSONDecoder().decode(ChannelIDResponse.self, from: data!)
                self.getSubCount(for: response.items![0]) { (channel) in
                    completion(channel)
                }
            }
            catch {
                print("json error: \(error)")
                completion(nil)
            }

        }.resume()
        
    }
    
    /// Get Youtube channel subscriber count by channel ID - only called from getChannelDetailsFromId, thus private
    /// - Parameters:
    ///   - channelID: YouTube channel ID
    ///   - completion: Sends an optional YouTubeChannel. Only called if getChannelDetailsFromId is successful so no need to send a bool
    private func getSubCount(for channelID: ChannelID? = nil, channel: Channel? = nil, completion: @escaping (YouTubeChannel?) -> ()) {
        // YouTube data API URL
        var id = ""
        if let channelID = channelID {
            id = channelID.channelId
        }
        if let channel = channel {
            id = channel.channelId
        }
        guard let statisticsURL = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=\(id)&key=\(Constants.apiKey)") else {
            return
        }
        
        URLSession.shared.dataTask(with: statisticsURL) { (data, response, error) in
            do {
                let response = try JSONDecoder().decode(SubscriberResponse.self, from: data!)
                DispatchQueue.main.async {
                    if let channelID = channelID {
                        completion(YouTubeChannel(channelName: channelID.channelName,
                                                  profileImage: channelID.profileImage,
                                                  subCount: response.items![0].subscriberCount,
                                                  channelId: channelID.channelId))
                    }
                    if let channelID = channel {
                        completion(YouTubeChannel(channelName: channelID.channelName,
                                                  profileImage: channelID.profileImage,
                                                  subCount: response.items![0].subscriberCount,
                                                  channelId: channelID.channelId))
                    }
                }
            }
            catch {
                print("json error: \(error)")
            }

        }.resume()
    }
    
    func addNewChannel(completion: @escaping (Bool) -> ()) {
        self.getChannelDetailsFromId(for: "UC-lHJZR3Gqxm24_Vd_AJ5Yw") { [weak self] (channel) in
            if let channel = channel {
                withAnimation {
                    self?.channels.append(channel)
                }
                guard let encodedChannels = try? JSONEncoder().encode(self?.channels) else { return }
                self?.channelData = encodedChannels
                completion(true)
            }
            completion(false)
        }
    }
    
    func updateColorForChannel(id: String, color: UIColor?) {
        for i in 0..<self.channels.count {
            if id == channels[i].id.uuidString {
                channels[i].bgColor = color
                break
            }
        }
        guard let encodedChannels = try? JSONEncoder().encode(self.channels) else { return }
        self.channelData = encodedChannels
    }
    
    func updateChannel(id: String, name: String, completion: @escaping (YouTubeChannel?) -> ()) {
        for i in 0..<self.channels.count {
            if id == channels[i].id.uuidString {
                self.getChannelDetails(for: name) { [weak self] (channel) in
                    if let channel = channel {
                        let color = self?.channels[i].bgColor
                        self?.channels[i] = channel
                        self?.channels[i].bgColor = color
                        guard let encodedChannels = try? JSONEncoder().encode(self?.channels) else { return }
                        self?.channelData = encodedChannels
                        WidgetCenter.shared.reloadAllTimelines()
                        completion(self?.channels[i])
                    } else {
                        completion(nil)
                    }
                }
                break
            }
        }
    }
    
    func delete(at index: Int) {
        self.channels.remove(at: index)
        guard let encodedChannels = try? JSONEncoder().encode(self.channels) else { return }
        self.channelData = encodedChannels
    }
}
