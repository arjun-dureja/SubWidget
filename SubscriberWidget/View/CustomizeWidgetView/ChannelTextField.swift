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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 200, height: 42, alignment: .center)
                .foregroundColor(Color(UIColor.systemBackground))
            HStack {
                if name.isEmpty {
                    Text("Channel Name or ID")
                        .foregroundColor(.gray)
                }
                Spacer()
                    .frame(width: 14)
            }
            TextField("", text: $name)
                .disableAutocorrection(true)
                .padding(10)
                .frame(width: 200)
                .foregroundColor(Color(UIColor.label))
                .cornerRadius(8)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 5))
        }
    }
}
