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
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Channels"))
                    {
                        ForEach(viewModel.channels, id: \.id) { channel in
                            NavigationLink(
                                destination: CustomizeWidgetView(
                                    viewModel: viewModel,
                                    channel: channel,
                                    isNewWidget: false
                                ),
                                label: {
                                    ChannelListRow(channel: channel)
                                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                })
                        }
                        .onDelete(perform: delete)
                    }
                }
                .listStyle(InsetGroupedListStyle())

                if viewModel.channels.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                    Text("Tap + to add a widget")
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
                CustomizeWidgetView(
                    viewModel: viewModel,
                    channel: viewModel.channels.last!,
                    isNewWidget: true
                )
            })
        }
    }
    
    func addWidgetTapped() {
        Task {
            do {
                try await viewModel.addNewChannel()
                self.newWidget = true
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            viewModel.deleteChannel(at: index)
        }
    }
}

struct AddWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetListView()
    }
}
