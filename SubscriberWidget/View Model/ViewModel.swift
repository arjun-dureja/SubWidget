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
    @Published var channelDetails: [Channel] = [.init(channelName: "", profileImage: "0")]
    @Published var subCount: [Subscribers] = [.init(subCount: "0")]
    
    /// Get youtube channel details by channel username
    /// - Parameters:
    ///   - channelName: YouTube channel username
    ///   - completion: Sends a bool to determine if the API call was successful and an optional YouTubeChannel
    func getChannelDetails(for channelName: String, completion: @escaping (Bool, YouTubeChannel?) -> ()) {
        // YouTube data API URL
        guard let snippetURL = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(channelName.replacingOccurrences(of: " ", with: ""))&key=\(Constants.apiKey)&type=channel") else { return }
        
        URLSession.shared.dataTask(with: snippetURL) { (data, response, error) in
            do {
                let response = try JSONDecoder().decode(ChannelResponse.self, from: data!)

                // Check if any channels were returned
                if response.items!.count == 0 {
                    completion(false, nil)
                    return
                }
                
                DispatchQueue.main.async {
                    self.channelDetails = response.items!
                }
                self.getSubCount(for: response.items![0].channelId) { (channel) in
                    completion(true, channel)
                }
            }
            catch {
                completion(false, nil)
            }
        }.resume()
    }
    
    /// Get youtube channel details by channel ID
    /// - Parameters:
    ///   - id: YouTube channel ID
    ///   - completion: Sends a bool to determine if the API call was successful and an optional YouTubeChannel
    func getChannelDetailsFromId(for id: String, completion: @escaping (Bool, YouTubeChannel?) -> ()) {
        // YouTube data API URL
        guard let snippetURL = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(id.replacingOccurrences(of: " ", with: ""))&key=\(Constants.apiKey)") else { return }
        
        URLSession.shared.dataTask(with: snippetURL) { (data, response, error) in
            do {
                let response = try JSONDecoder().decode(ChannelIDResponse.self, from: data!)
                DispatchQueue.main.async {
                    self.channelDetails = [Channel(channelName: response.items![0].channelName, profileImage: response.items![0].profileImage)]
                }
                self.getSubCount(for: response.items![0].channelId) { (channel) in
                    completion(true, channel)
                }
            }
            catch {
                print("json error: \(error)")
                completion(false, nil)
            }

        }.resume()
        
    }
    
    /// Get Youtube channel subscriber count by channel ID - only called from getChannelDetailsFromId, thus private
    /// - Parameters:
    ///   - channelID: YouTube channel ID
    ///   - completion: Sends an optional YouTubeChannel. Only called if getChannelDetailsFromId is successful so no need to send a bool
    private func getSubCount(for channelID: String, completion: @escaping (YouTubeChannel?) -> ()) {
        // YouTube data API URL
        guard let statisticsURL = URL(string: "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=\(channelID)&key=\(Constants.apiKey)") else { return }
        
        URLSession.shared.dataTask(with: statisticsURL) { (data, response, error) in
            do {
                let response = try JSONDecoder().decode(SubscriberResponse.self, from: data!)
                DispatchQueue.main.async {
                    self.subCount = response.items!
                    completion(YouTubeChannel(channelName: self.channelDetails[0].channelName, profileImage: self.channelDetails[0].profileImage, subCount: response.items![0].subscriberCount, channelId: channelID))
                }
            }
            catch {
                print("json error: \(error)")
            }

        }.resume()
    }
}
