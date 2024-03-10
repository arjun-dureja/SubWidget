//
//  FAQ.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-18.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FAQ: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(FAQItem.presets) { item in
                        FAQCell(question: item.question, answer: item.answer)
                    }
                }
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.bottom)
            }
        }
        .navigationBarTitle("SubWidget FAQ")
        .background(colorScheme == .dark ? .black : Color(UIColor.systemGray6))
        .onAppear {
            Task {
                AnalyticsService.shared.logFaqScreenViewed()
            }
        }
    }
}
