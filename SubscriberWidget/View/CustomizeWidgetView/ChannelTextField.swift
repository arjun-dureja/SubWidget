//
//  ChannelTextField.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ChannelTextField: View {
    @Binding var name: String
    var isFocused: FocusState<Bool>.Binding
    @Environment(\.colorScheme) var colorScheme

    var submitButtonTapped: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 44)
                .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))

            HStack {
                if name.isEmpty {
                    Text("Channel Name or ID")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.leading, 10)

            TextField("", text: $name)
                .disableAutocorrection(true)
                .padding(.horizontal, 10)
                .foregroundColor(Color(UIColor.label))
                .focused(isFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        isFocused.wrappedValue = true
                    }
                }
                .onSubmit {
                    submitButtonTapped()
                }
        }
    }
}
