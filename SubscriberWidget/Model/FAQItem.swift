//
//  FAQItem.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-19.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import Foundation

struct FAQItem: Identifiable, Equatable {
    let question: LocalizedStringResource
    let answer: LocalizedStringResource
    var id: String { question.key }

    static var presets: [FAQItem] = [
        .init(
            question: "How do I add the widget to my homescreen?",
            answer: """
            Tap and hold anywhere on your homescreen and tap the plus button in the top left. \
            Look for SubWidget and add it to your homescreen. Finally, tap and hold on the widget and select your channel.
            """
        ),
        .init(
            question: "How do I add widget to my Lock Screen?",
            answer: "First, tap and hold on your Lock Screen and tap 'Customize'. Then you can add the widget and tap it to select the channel."
        ),
        .init(
            question: "I can't find my channel.",
            answer: "Try entering your channel ID instead of your channel name. If that still doesn't work, please contact me and I will help you."
        ),
        .init(
            question: "The channels aren't loading.",
            answer: "This indicates a server issue. Please try again later."
        ),
        .init(
            question: "How often does the subscriber count update?",
            answer: "You can select how often you want the widget to update in the app settings. The minimum is every 30 minutes."
        ),
        .init(
            question: "The widget is blank.",
            answer: "Please remove the widget from your homescreen and add it back."
        ),
        .init(
            question: "How many channels can I add?",
            answer: """
            Currently, you can add up to 10 channels. If you would like to add more, \
            please contact me using the link in Settings and I will increase the limit.
            """
        ),
        .init(
            question: "Why doesn't it show the exact subscriber count?",
            answer: "Unfortunately, YouTube does not provide exact subscriber counts, they provide a rounded number."
        ),
        .init(
            question: "What does the reset button do?",
            answer: "Restores the widget's colors to the defaults."
        ),
        .init(
            question: "I have a feature idea I want to request.",
            answer: "You can request a feature using the Wishlist tab below."
        )
    ]

}
