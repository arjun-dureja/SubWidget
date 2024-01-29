//
//  AddWidgetButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-18.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct AddWidgetButton: View {
    var action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white, Color.youtubeRed)
            }
        )
    }
}
