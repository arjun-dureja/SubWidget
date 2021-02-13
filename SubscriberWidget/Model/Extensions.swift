//
//  Extensions.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

extension Color {
    static let youtubeRed = Color(.sRGB, red: 212/255, green: 35/255, blue: 34/255, opacity: 1)
    static let titleGray = Color(.sRGB, red: 96/255, green: 96/255, blue: 96/255, opacity: 1)
    
    static let darkModeTitleGray = Color(.sRGB, red: 229/255, green: 229/255, blue: 229/255, opacity: 1)
    static let darkModeBG = Color(.sRGB, red: 41/255, green: 20/255, blue: 20/255, opacity: 1)
}

extension View {
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

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
