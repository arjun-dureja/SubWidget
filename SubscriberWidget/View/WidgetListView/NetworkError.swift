//
//  NetworkError.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-18.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct NetworkError: View {
    var retryHandler: () -> Void
    
    var body: some View {
        VStack {
            Text("Network error. Please try again.")
            Button(
                action: retryHandler,
                label: {
                    Text("Try Again")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 250, height: 15)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.youtubeRed)
                        .cornerRadius(16)
                }
            )
            .padding(.top, 16)
        }
    }
}
