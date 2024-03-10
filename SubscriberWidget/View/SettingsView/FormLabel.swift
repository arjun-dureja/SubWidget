//
//  FormLabel.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-26.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FormLabel: View {
    var text: LocalizedStringResource
    var icon: String

    var body: some View {
        HStack {
            Label {
                Text(text)
                    .foregroundColor(Color(UIColor.label))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.white, Color.youtubeRed)
            }

            Spacer()

            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(UIColor.systemGray2))
        }
    }
}
