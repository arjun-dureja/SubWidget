//
//  CustomizeWidgetHeader.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-15.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import StoreKit

struct CustomizeWidgetHeader: View {
    let onCancel: () -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Button("Cancel") {
                onCancel()
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.youtubeRed)

            Spacer()

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.youtubeRed)
        }
        .padding()
    }
}
