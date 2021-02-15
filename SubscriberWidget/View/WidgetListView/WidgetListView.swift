//
//  AddWidgetView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct WidgetListView: View {
    @State private var newWidget = false
    @StateObject var viewModel = ViewModel()
    
    init() {
        // List row color
        UITableView.appearance().backgroundColor = .systemGray6
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header:
                                Text("Channels"))
                    {
                        ForEach(viewModel.channels, id: \.id) { channel in
                            NavigationLink(
                                destination: CustomizeWidgetView(viewModel: viewModel, channel: channel),
                                label: {
                                    ChannelListRow(channel: channel)
                                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                })
                                .listRowBackground(Color(UIColor.systemBackground))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                if viewModel.channels.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                }
            }
            .navigationBarTitle("SubWidget")
            .navigationBarItems(
                trailing:
                    Button(
                        action: addWidgetTapped,
                        label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.youtubeRed)
                        })
            )
            .sheet(isPresented: $newWidget, content: {
                CustomizeWidgetView(viewModel: viewModel, channel: viewModel.channels.last!)
            })
        }
    }
    
    func addWidgetTapped() {
        viewModel.addNewChannel { (success) in
            if success {
                self.newWidget = true
            }
        }
    }
}

struct AddWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetListView()
    }
}
