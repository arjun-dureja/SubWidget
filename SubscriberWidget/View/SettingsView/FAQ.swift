//
//  FAQ.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-18.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FAQ: View {
    @StateObject var viewModel: ViewModel
    @State var faqData: [FAQItem] = []
    @State var loading = true
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if loading {
                ProgressView()
                    .scaleEffect(1.5, anchor: .center)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(faqData) { item in
                            FAQCell(question: item.question, answer: item.answer)
                        }
                    }
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                }
            }
        }
        .navigationBarTitle("SubWidget FAQ")
        .background(colorScheme == .dark ? .black : Color(UIColor.systemGray6))
        .onAppear {
            Task {
                faqData = try await viewModel.getFaq()
                loading = false
            }
        }
    }
}
