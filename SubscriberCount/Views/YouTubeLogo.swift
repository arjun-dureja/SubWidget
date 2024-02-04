//
//  YouTubeLogo.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-10-02.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct YouTubeLogo: View {
    let youtubeLogo = UIImage(named: "youtube-logo")!

    var body: some View {
        Image(uiImage: (youtubeLogo.resized(toWidth: 800)!))
            .resizable()
            .frame(width: 20.5, height: 14.6)
            .cornerRadius(4)
    }
}

extension UIImage {
  func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
    let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
    let format = imageRendererFormat
    format.opaque = isOpaque
    return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
        draw(in: CGRect(origin: .zero, size: canvas))
    }
  }
}
