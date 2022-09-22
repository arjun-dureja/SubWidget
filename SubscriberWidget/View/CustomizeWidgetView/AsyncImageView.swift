//
//  AsyncImageView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-09-21.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct AsyncImageView: View {
    public let url: URL?

    var body: some View {
        AsyncImage(url: url, content: { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        }, placeholder: {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
        })
    }
}
