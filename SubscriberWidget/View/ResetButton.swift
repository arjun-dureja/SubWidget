//
//  ResetButton.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ResetButton: View {
    @Binding var backgroundColor: Data
    @Binding var bgColor: CGColor?
    @Binding var colorChanged: Bool
    
    var body: some View {
        Button(action: {
            if bgColor != nil {
                self.updateColorInAppStorage(color: nil)
                self.bgColor = nil
                self.colorChanged = true
            }
        }, label: {
            Text("Reset")
                .font(.subheadline)
                .bold()
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 45, trailing: 10))
    }
    
    func updateColorInAppStorage(color: UIColor?) {
        do {
            backgroundColor = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
