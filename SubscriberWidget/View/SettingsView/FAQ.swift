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
            if colorScheme == .light {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea(.all)
            }

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
            .frame(maxWidth: 850)
        }
        .navigationBarTitle("SubWidget FAQ")
        .task {
            AnalyticsService.shared.logFaqScreenViewed()
        }
    }
}
