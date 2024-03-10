//
//  SafariSheet.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-26.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct SafariSheet: View {
    var text: LocalizedStringResource
    var icon: String
    var url: URL

    @State var showingSheet = false

    var body: some View {
        Button {
            showingSheet.toggle()
        } label: {
            FormLabel(text: text, icon: icon)
        }
        .sheet(isPresented: $showingSheet) {
            SafariView(url: url)
        }
    }
}
