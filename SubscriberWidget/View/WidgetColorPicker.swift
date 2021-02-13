//
//  WidgetColorPicker.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetColorPicker: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var bgColor: CGColor?
    @Binding var colorChanged: Bool
    @Binding var backgroundColor: Data
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 215, height: 50, alignment: .leading)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            ColorPicker("Background Color", selection: Binding(get: {
                bgColor ?? (colorScheme == .dark ? UIColor.black.cgColor : UIColor.white.cgColor)
            }, set: { newValue in
                do {
                    backgroundColor = try NSKeyedArchiver.archivedData(withRootObject: UIColor(cgColor: newValue), requiringSecureCoding: false)
                } catch let error {
                    print("\(error.localizedDescription)")
                }
                self.bgColor = newValue
                self.colorChanged = true
            }), supportsOpacity: false)
            .frame(width: 190, height: 50)
            .font(.headline)
            .onAppear {
                var color: UIColor?
                
                do {
                    color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backgroundColor)
                } catch let error {
                    print("\(error.localizedDescription)")
                }
                
                bgColor = color?.cgColor ?? nil
            }
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
    }
}
