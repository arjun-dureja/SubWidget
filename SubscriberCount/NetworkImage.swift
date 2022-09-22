//
//  NetworkImage.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-09-21.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

// Download image from URL
struct NetworkImage: View {
    public let url: URL?

    var body: some View {
        if let url = url, let imageData = try? Data(contentsOf: url),
           let uiImage = UIImage(data: imageData) {

            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        else {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
        }
    }
}
