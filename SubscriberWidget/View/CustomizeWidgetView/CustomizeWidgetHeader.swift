//
//  CustomizeWidgetHeader.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-15.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct CustomizeWidgetHeader: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            Button("Cancel") {
                viewModel.deleteChannel(at: viewModel.channels.count-1)
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

