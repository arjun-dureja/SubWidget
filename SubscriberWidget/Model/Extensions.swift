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

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
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

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self
        let truncated = Double(Int(newDecimal))
        let originalDecimal = truncated / multiplier
        return originalDecimal
    }
}

extension String {
    static var currentTime: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeStyle = .short
        return formatter.string(from: .now)
    }
    
    func formattedWithSeparator() -> String {
        guard let number = Int(self) else {
            return self
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return self
        }

        return formattedNumber
    }
    
    func simplified() -> String {
        guard let asDouble = Double(self) else {
            return self
        }

        let num = abs(asDouble)
        switch num {
        case 1_000_000_000...:
            return "\(String(format: "%g", (num / 1_000_000_000).reduceScale(to: 1)))B"
        case 1_000_000...:
            return "\(String(format: "%g", (num / 1_000_000).reduceScale(to: 1)))M"
        case 1_000...:
            return "\(String(format: "%g", (num / 1_000).reduceScale(to: 1)))K"
        default:
            return self
        }
    }
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")
}
