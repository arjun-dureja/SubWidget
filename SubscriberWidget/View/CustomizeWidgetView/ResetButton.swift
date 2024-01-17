//
//  ResetButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ResetButton: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var channel: YouTubeChannel
    @Binding var colorChanged: Bool
    
    var body: some View {
        Button(action: resetTapped, label: {
            Text("Reset")
                .font(.subheadline)
                .bold()
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
    }
    
    func resetTapped() {
        viewModel.updateColorForChannel(id: channel.id, color: nil)
        channel.bgColor = nil
        colorChanged = true
    }
}
