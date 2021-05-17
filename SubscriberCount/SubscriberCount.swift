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
}

struct Provider: IntentTimelineProvider {
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "PewDiePie", profileImage: "https://yt3.ggpht.com/ytc/AAUvwnga3eXKkQgGU-3j1_jccZ0K9m6MbjepV0ksd7eBEw=s800-c-k-c0x00ffffff-no-rj", subCount: "1111111110", channelId: "UC-lHJZR3Gqxm24_Vd_AJ5Yw"))
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else { return }
        let viewModel = ViewModel()
        viewModel.getChannelDetailsFromId(for: channelId) { (channel) in
            if let channel = channel {
                let entry = SimpleEntry(date: Date(), configuration: configuration, channel: channel)
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
                let entry = SimpleEntry(date: Date(), configuration: configuration, channel: channel)
                let timeline = Timeline(entries: [entry], policy: .after(refresh))
                completion(timeline)
            }
        }
    }
}

struct SubscriberCountEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidget(entry: entry.channel)
        default:
            MediumWidget(entry: entry.channel)
        }
    }
}

@main
struct SubscriberCount: Widget {
    let kind: String = "SubscriberCount"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectChannelIntent.self, provider: SubWidgetIntentTimelineProvider(), content: { (entry) in
            SubscriberCountEntryView(entry: entry)
        })
        .configurationDisplayName("Subscriber Count")
        .description("View your YouTube subscriber count in realtime")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


struct SubscriberCount_Previews: PreviewProvider {
    static var previews: some View {
        SubscriberCountEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "Google", profileImage: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Google_Chrome_icon_%28September_2014%29.svg/1200px-Google_Chrome_icon_%28September_2014%29.svg.png", subCount: "123,501", channelId: "test")))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small widget")
                .environment(\.colorScheme, .dark)
    }
}
