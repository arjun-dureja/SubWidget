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
    @State private var showWhatsNew = false
    @State private var showUpdateAlert = false
    @State private var showNetworkError = false
    @StateObject var viewModel: ViewModel
    
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
                
                if viewModel.networkError {
                    VStack {
                        Text("Network error. Please try again.")
                        Button(
                            action: tryAgainTapped,
                            label: {
                                Text("Try Again")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 250, height: 15)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.youtubeRed)
                                    .cornerRadius(16)
                            }
                        )
                        .padding(.top, 16)
                    }
                } else if viewModel.isLoading && viewModel.channels.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                } else if viewModel.channels.isEmpty {
                    EmptyState(addWidgetTapped: addWidgetTapped)
                }
            }
            .navigationBarTitle("SubWidget")
            .if(viewModel.channels.count > 0) { view in
                view.navigationBarItems(
                    trailing:
                        Button(
                            action: addWidgetTapped,
                            label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white, Color.youtubeRed)
                            }
                        )
                )
            }
            .sheet(isPresented: $newWidget, content: {
                CustomizeWidgetView(
                    viewModel: viewModel,
                    channel: viewModel.channels.last!,
                    isNewWidget: true
                )
            })
            .sheet(isPresented: $showWhatsNew, onDismiss: {
                if viewModel.isMigratedUser {
                    showUpdateAlert = true
                }
            }, content: {
                WhatsNewView(isPresented: $showWhatsNew)
            })
            .alert("Can't see your widgets?", isPresented: $showUpdateAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("Please remove them from your homescreen and add them back.")
            })
            .alert("You can only add 10 channels. Swipe left on a channel to delete it.", isPresented: $tooManyChannels) {
                Button("OK", role: .cancel) { }
            }
            .alert("Network error. Please try again later.", isPresented: $showNetworkError) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if viewModel.shouldShowWhatsNew() {
                showWhatsNew = true
            }
        }
    }
    
    func tryAgainTapped() {
        viewModel.tryInitAgain()
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
                    showNetworkError = true
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
        WidgetListView(viewModel: ViewModel())
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
