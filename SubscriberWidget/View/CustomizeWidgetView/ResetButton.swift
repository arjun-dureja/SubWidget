//
//  ResetButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ResetButton: View {
    let onReset: () -> Void

    @Binding var channel: YouTubeChannel

    var body: some View {
        Button(action: onReset, label: {
            Text("Reset")
                .bold()
                .font(.footnote)
        })
    }
}
