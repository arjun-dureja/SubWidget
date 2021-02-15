//
//  SubscriberCount.swift
//  SubscriberCount
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let channel: YouTubeChannel
    let bgColor: UIColor?
}

struct Provider: IntentTimelineProvider {
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "", profileImage: "", subCount: "0", channelId: ""), bgColor: UIColor.systemBackground)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else { return }
        let viewModel = ViewModel()
        viewModel.getChannelDetailsFromId(for: channelId) { (channel) in
            if let channel = channel {
                let entry = SimpleEntry(date: Date(), configuration: configuration, channel: channel, bgColor: color)
                completion(entry)
            }
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else { return }
        
        // Refresh widget every hour
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        
        ViewModel().getChannelDetailsFromId(for: channelId) { (channel) in
            if let channel = channel {
                let entry = SimpleEntry(date: Date(), configuration: configuration, channel: channel, bgColor: color)
                let timeline = Timeline(entries: [entry], policy: .after(refresh))
                completion(timeline)
            }
        }
    }
    
    var color: UIColor? {
        var color: UIColor?
        
        do {
            color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backgroundColor)
        } catch let error {
            print("\(error.localizedDescription)")
        }
        return color ?? nil
    }
}

struct SubscriberCountEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidget(entry: entry.channel, bgColor: entry.bgColor)
        default:
            MediumWidget(entry: entry.channel, bgColor: entry.bgColor)
        }
    }
}

@main
struct SubscriberCount: Widget {
    let kind: String = "SubscriberCount"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SubscriberCountEntryView(entry: entry)
        }
        .configurationDisplayName("Subscriber Count")
        .description("View your YouTube subscriber count in realtime")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


struct SubscriberCount_Previews: PreviewProvider {
    static var previews: some View {
        SubscriberCountEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "Google", profileImage: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Google_Chrome_icon_%28September_2014%29.svg/1200px-Google_Chrome_icon_%28September_2014%29.svg.png", subCount: "123,501", channelId: "test"), bgColor: .systemBackground))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small widget")
                .environment(\.colorScheme, .dark)
    }
}
