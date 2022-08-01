//
//  WidgetPicker.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetSizePicker: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var widgetSize = 0
    
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(maxWidth: .infinity)
                .frame(height: 100, alignment: .center)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            VStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 35, alignment: .center)
                        .foregroundColor(Color(UIColor.systemGray6))
                        .cornerRadius(14, corners: [.topLeft, .topRight])
                    
                    Text("Preview")
                        .foregroundColor(Color(UIColor.label))
                        .font(.subheadline)
                        .bold()
                }
                .padding(.horizontal, 7)
                .padding(.top, 7)
                
                Picker(selection: $widgetSize, label: Text("Select Size")) {
                    Text("Small").tag(0)
                    Text("Medium").tag(1)
                }
                .onChange(of: widgetSize, perform: { _ in
                    withAnimation {
                        animate.toggle()
                    }
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 30)
    }
}
