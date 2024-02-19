//
//  ColorPalette.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-02-10.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ColorPalette: View {
    let palette: Palette
    let onPress: (_ palette: Palette) -> Void

    @State private var tapped = false

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                palette.background
                    .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                palette.accent
                palette.number
                    .cornerRadius(8, corners: [.topRight, .bottomRight])
            }
            .frame(width: 75, height: 25)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(Color.titleGray)
                    .opacity(0.5)
            }

            Text(palette.name)
                .font(.footnote)
                .fontWeight(.light)
        }
        .opacity(tapped ? 0.7 : 1)
        .onTapGesture {
            onPress(palette)

            let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator.impactOccurred()

            tapped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.tapped = false
            }
        }
    }
}

#Preview {
    ColorPalette(
        palette: .init(
            name: "Preview",
            background: .init(hue: 27/360, saturation: 97/100, brightness: 48/100),
            accent: .init(hue: 208/360, saturation: 96/100, brightness: 69/100),
            number: .init(hue: 269/360, saturation: 96/100, brightness: 74/100)
        ),
        onPress: { _ in }
    )
}
