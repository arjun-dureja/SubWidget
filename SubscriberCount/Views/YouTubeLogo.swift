//
//  YouTubeLogo.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-10-02.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct YouTubeLogo: View {
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.youtubeRed)
                .frame(width: 21.3, height: 14.8)
            Triangle()
                .foregroundStyle(Color.white)
                .frame(width: 6, height: 6)
                .blendMode(widgetRenderingMode == .fullColor ? .normal : .destinationOut)
        }
        .environment(\.layoutDirection, .leftToRight)
        .compositingGroup()
    }

    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return path
        }
    }
}
