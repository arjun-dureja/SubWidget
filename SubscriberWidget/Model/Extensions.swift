//
//  Extensions.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

extension Color {
    // Custom colors
    static let youtubeRed = Color(.sRGB, red: 212/255, green: 35/255, blue: 34/255, opacity: 1)
    static let titleGray = Color(.sRGB, red: 96/255, green: 96/255, blue: 96/255, opacity: 1)
    
    static let darkModeTitleGray = Color(.sRGB, red: 229/255, green: 229/255, blue: 229/255, opacity: 1)
    static let darkModeTitleGray2 = Color(.sRGB, red: 200/255, green: 200/255, blue: 200/255, opacity: 1)
    static let darkModeBG = Color(.sRGB, red: 41/255, green: 20/255, blue: 20/255, opacity: 1)
}

extension UIColor {
    func hexStringFromColor() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
     }

}

extension View {
    // Round specific corners only of any shape
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Dismiss keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension YouTubeChannelParam {
    
    convenience init(channel: YouTubeChannel) {
        self.init(identifier: channel.id, display: channel.channelName)
    }
    
    static var global: YouTubeChannelParam {
        YouTubeChannelParam(channel: .init(channelName: "", profileImage: "", subCount: "0", channelId: ""))
    }
}
