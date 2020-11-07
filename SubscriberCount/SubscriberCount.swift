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
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "", profileImage: "", subCount: "0", channelId: ""))
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else { return }
        let viewModel = ViewModel()
        viewModel.getChannelDetailsFromId(for: channelId) { (success, channel) in
            let entry = SimpleEntry(date: Date(), configuration: configuration, channel: channel!)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else { return }
        
        // Update widget every hour
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        
        ViewModel().getChannelDetailsFromId(for: channelId) { (success, channel) in
            if success {
                let entry = SimpleEntry(date: Date(), configuration: configuration, channel: channel!)
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
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor = ""
    @State private var bgColor = Color(UIColor.systemBackground)
    let kind: String = "SubscriberCount"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SubscriberCountEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgColor)
                .onAppear {
                    if (backgroundColor != "") {
                        let rgbArray = backgroundColor.components(separatedBy: ",")
                        if let red = Double(rgbArray[0]), let green = Double(rgbArray[1]), let blue = Double(rgbArray[2]), let alpha = Double(rgbArray[3]) {
                            bgColor = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
                        }
                    }
                }
        }
        .configurationDisplayName("Subscriber Count")
        .description("View your YouTube subscriber count in realtime")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


struct SubscriberCount_Previews: PreviewProvider {
    static var previews: some View {
            SubscriberCountEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), channel: YouTubeChannel(channelName: "Google", profileImage: "https://yt3.ggpht.com/a/AATXAJy1Y4nZmI7R2mSni2KzVUHhlrvlbb58Ydp7qWO4=s800-c-k-c0xffffffff-no-rj-mo", subCount: "123,501", channelId: "test")))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small widget")
                .environment(\.colorScheme, .dark)
    }
}
