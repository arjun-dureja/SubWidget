//
//  WhatsNewView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-07-07.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WebKit

struct WhatsNewView: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Text("What's New in SubWidget")
                .font(.system(size: 26, weight: .bold, design: .default))
                .padding(.top, 56)

            WhatsNewListItem(
                iconName: "plus.circle.fill",
                heading: "Lockscreen Widgets",
                description: "You can now add widgets to your lockscreen with iOS 16!"
            )
            .frame(width: 325, height: 55, alignment: .leading)

            GifImage("lockscreen_widget")
                .frame(width: 222, height: 479)
                .cornerRadius(16)

            Button {
                isPresented = false
            } label: {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.youtubeRed)
                    .cornerRadius(12)
            }
        }
        .padding(32)
        .padding(.vertical, 32)
        .background(colorScheme == .dark ? .black : Color(UIColor.systemGray6))
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isPresented: .constant(true))
    }
}

struct GifImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = Bundle.main.url(forResource: name, withExtension: "gif")!
        let data = try? Data(contentsOf: url)
        webView.load(
            data!,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        webView.scrollView.isScrollEnabled = false
        webView.sizeToFit()

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

}
