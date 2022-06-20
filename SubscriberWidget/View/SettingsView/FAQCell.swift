//
//  FAQCell.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-05-29.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FAQCell: View {
    @State private var tapped = false
    @Environment(\.colorScheme) var colorScheme
    var question: String
    var answer: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(question)
                    .foregroundColor(tapped ? .youtubeRed : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .rotationEffect(.degrees(tapped ? 90 : 0))
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 8)


            if tapped {
                Text(answer)
                    .foregroundColor(colorScheme == .dark ? .darkModeTitleGray2 : .titleGray)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom)
            }

            Divider()
        }
        .background(colorScheme == . dark ? Color(UIColor.systemGray6) : .white).edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation {
                tapped.toggle()
            }
        }
    }
}

struct FAQCell_Previews: PreviewProvider {
    static var previews: some View {
        FAQCell(question: "Placeholder question", answer: "Placeholder answer")
    }
}
