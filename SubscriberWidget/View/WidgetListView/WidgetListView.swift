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
    @State private var tooManyChannels = false
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Channels"))
                    {
                        ForEach(viewModel.channels, id: \.id) { channel in
                            NavigationLink(
                                destination: CustomizeWidgetView(
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

                if viewModel.isLoading && viewModel.channels.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                } else if viewModel.channels.isEmpty {
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
                    channel: viewModel.channels.last!,
                    isNewWidget: true
                )
            })
            .alert("You can only add 10 channels. Swipe left on a channel to delete it.", isPresented: $tooManyChannels) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func addWidgetTapped() {
        if viewModel.channels.count >= 10 {
            tooManyChannels = true
        } else {
            Task {
                do {
                    try await viewModel.addNewChannel()
                    newWidget = true
                } catch let error {
                    print(error.localizedDescription)
                }
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
