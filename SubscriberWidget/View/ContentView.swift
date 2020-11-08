//
//  ContentView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import SwiftUI
import UIKit
import WidgetKit

struct ContentView: View {
    @AppStorage("channel", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var channelData: Data = Data()
    @AppStorage("backgroundColor", store: UserDefaults(suiteName: "group.com.arjundureja.SubscriberWidget")) var backgroundColor: Data = Data()
    
    @ObservedObject var viewModel = ViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @State private var name: String = ""
    @State private var showingAlert = false
    @State public var widgetSize = 0
    @State private var animate = false
    @State private var rotateIn3D = false
    @State private var helpAlert = false
    @State private var bgColor: CGColor?
    @State private var colorChanged = false
    
    init() {
        // Segmented control colors
        UISegmentedControl.appearance().backgroundColor = .systemGray6
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.youtubeRed)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBackground], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            
            // MARK: Title
            Text("SubWidget")
                .foregroundColor(Color(UIColor.label))
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            HStack {
                // MARK: Textfield
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 200, height: 42, alignment: .center)
                        .foregroundColor(Color(UIColor.systemBackground))
                    HStack {
                        if name.isEmpty {
                            Text("Channel Name or ID")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                            .frame(width: 14)
                    }
                    TextField("", text: $name)
                        .disableAutocorrection(true)
                        .padding(10)
                        .frame(width: 200)
                        .foregroundColor(Color(UIColor.label))
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 5))
                }
                
                // MARK: Submit Button
                Button(action: {
                    if name.count > 0 {
                        self.viewModel.getChannelDetails(for: name) { (success, channel) in
                            if success {
                                UIApplication.shared.endEditing()
                                guard let channelData = try? JSONEncoder().encode(channel!.channelId) else { return }
                                self.channelData = channelData
                                WidgetCenter.shared.reloadAllTimelines()
                            } else {
                                self.showingAlert = true
                            }
                            name.removeAll()
                        }
                    }
                }, label: {
                    Text("Submit")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .bold()
                })
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .foregroundColor(.white)
                .font(.subheadline)
                .background(Color.youtubeRed)
                .cornerRadius(8)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Unable to find channel"), message: Text("Please enter the correct channel username or ID"), primaryButton: .default(Text("Find my ID")) {
                        openURL(URL(string: "https://commentpicker.com/youtube-channel-id.php")!)
                    }, secondaryButton: .default(Text("OK")) {

                    })
                }
                
                // MARK: Help Button
                Button(action: {
                    self.helpAlert = true
                }, label: {
                    Image(systemName: "info.circle")
                })
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                .alert(isPresented: $helpAlert) {
                    Alert(title: Text("Can't find your channel?"), message: Text("Try entering your YouTube channel ID instead"), primaryButton: .default(Text("Find my ID")) {
                        openURL(URL(string: "https://commentpicker.com/youtube-channel-id.php")!)
                    }, secondaryButton: .default(Text("OK")) {

                    })
                }
            }
            
            Spacer()
            
            VStack {
                // MARK: Color Picker
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 215, height: 50, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    
                    ColorPicker("Background Color", selection: Binding(get: {
                        bgColor ?? (colorScheme == .dark ? UIColor.black.cgColor : UIColor.white.cgColor)
                    }, set: { newValue in
                        self.updateColorInAppStorage(color: UIColor(cgColor: newValue))
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

                //MARK: Reset Button
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
            
            // MARK: Widget Preview
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: self.animate ? 329 : 155, height: 155, alignment: .leading)
                    .foregroundColor(Color(bgColor ?? (colorScheme == .dark ? UIColor.black.cgColor : UIColor.white.cgColor)))
                                    .shadow(radius: 16)
                                    .animation(.easeInOut(duration: 0.25))

                SmallWidget(entry: YouTubeChannel(channelName: "\(viewModel.channelDetails[0].channelName)", profileImage: "\(viewModel.channelDetails[0].profileImage)", subCount: "\(Int(viewModel.subCount[0].subscriberCount)!)", channelId: "\(viewModel.channelDetails[0].channelId)"), bgColor: UIColor.clear)
                    .frame(width: 155, height: 155, alignment: .leading)
                    .opacity(self.animate ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5))
                
                MediumWidget(entry: YouTubeChannel(channelName: "\(viewModel.channelDetails[0].channelName)", profileImage: "\(viewModel.channelDetails[0].profileImage)", subCount: "\(Int(viewModel.subCount[0].subscriberCount)!)", channelId: "\(viewModel.channelDetails[0].channelId)"), bgColor: UIColor.clear)
                    .frame(width: 329, height: 155, alignment: .leading)
                    .opacity(self.animate ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5))
            }
            .rotation3DEffect(
                .degrees(rotateIn3D ? 12 : -12),
                axis: (x: rotateIn3D ? 90 : -45, y: rotateIn3D ? -45 : -90, z: 0))
            .animation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true))
            .onAppear() {
                rotateIn3D.toggle()
            }
              
            Spacer()
            
            // MARK: Segmented Control
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: UIScreen.main.bounds.width-40, height: 100, alignment: .center)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                VStack(spacing: 12) {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width-47, height: 35, alignment: .center)
                            .foregroundColor(Color(UIColor.systemGray6))
                            .cornerRadius(16, corners: [.topLeft, .topRight])
                        Text("Preview")
                            .foregroundColor(Color(UIColor.label))
                            .font(.subheadline)
                            .bold()
                    }
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
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    Spacer()
                        .frame(height: 3)
                }
            }
            
            Spacer()
        
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(UIColor.systemGray6)).edgesIgnoringSafeArea(.all)
        // MARK: View On Appear
        .onAppear() {
            guard let channelId = try? JSONDecoder().decode(String.self, from: channelData) else {
                self.viewModel.getChannelDetails(for: "pewdiepie") { (success, channel)   in
                    if success {
                        guard let channelData = try? JSONEncoder().encode(channel!.channelId) else { return }
                        self.channelData = channelData
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                return
            }
            self.viewModel.getChannelDetailsFromId(for: channelId) { (success, _) in
                if !success {
                    self.showingAlert = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Only reload timelines if the color was changed
            if self.colorChanged {
                print("Color changed, reloading timelines")
                WidgetCenter.shared.reloadAllTimelines()
                self.colorChanged = false
            }
        }
    }
    
    // MARK: Update Color Function
    func updateColorInAppStorage(color: UIColor?) {
        do {
            backgroundColor = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        } catch let error {
            print("\(error.localizedDescription)")
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

