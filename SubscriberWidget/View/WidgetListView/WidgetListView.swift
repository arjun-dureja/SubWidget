//
//  AddWidgetView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-12.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WishKit

struct WidgetListView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.requestReview) private var requestReview

    @State private var newWidget = false
    @State private var tooManyChannels = false
    @State private var showWhatsNew = false
    @State private var showUpdateAlert = false
    @State private var showNetworkError = false

    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                case .error:
                    NetworkError(retryHandler: tryAgainTapped)
                case .loaded:
                    if viewModel.channels.isEmpty {
                        EmptyState(addWidgetTapped: addWidgetTapped)
                    } else {
                        List {
                            Section(header: Text("Channels")) {
                                ForEach(viewModel.channels, id: \.id) { channel in
                                    NavigationLink(
                                        destination: CustomizeWidgetView(
                                            viewModel: viewModel,
                                            channel: channel,
                                            isNewWidget: false
                                        ),
                                        label: {
                                            ChannelListRow(channel: channel)
                                                .redacted(
                                                    reason: viewModel.state == .loading ? .placeholder : []
                                                )
                                        })
                                }
                                .onDelete(perform: deleteChannel)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .frame(maxWidth: 850)
                    }
                }
            }
            .navigationBarTitle("SubWidget")
            .if(!viewModel.channels.isEmpty) { view in
                view.navigationBarItems(trailing: AddWidgetButton(action: addWidgetTapped))
            }
            .sheet(
                isPresented: $newWidget,
                onDismiss: {
                    if viewModel.channels.count > 1 {
                        AnalyticsService.shared.logReviewRequested()
                        DispatchQueue.main.async {
                            requestReview()
                        }
                    }
                },
                content: {
                    CustomizeWidgetView(
                        viewModel: viewModel,
                        channel: viewModel.channels.last!,
                        isNewWidget: true
                    )
                    .background(Color(UIColor.systemBackground))
                }
            )
            .sheet(isPresented: $showWhatsNew, content: {
                WhatsNewView(isPresented: $showWhatsNew)
            })
            .alert(
                "You can only add 10 channels. Swipe left on a channel to delete it.",
                isPresented: $tooManyChannels
            ) {
                Button("OK", role: .cancel) { }
            }
            .alert(
                "Network error. Please try again later.",
                isPresented: $showNetworkError
            ) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .task {
            await viewModel.loadChannels()

            if viewModel.shouldShowWhatsNew() {
                showWhatsNew = true
            }

            if let name = viewModel.channels.first?.channelName,
               name != YouTubeChannel.preview.channelName {
                WishKit.updateUser(name: name)
            }
        }
    }

    func tryAgainTapped() {
        viewModel.retryLoadChannels()
    }

    func addWidgetTapped() {
        if viewModel.channels.count >= 10 {
            tooManyChannels = true
        } else {
            Task {
                do {
                    try await viewModel.addNewChannel()
                    newWidget = true
                } catch {
                    AnalyticsService.shared.logNetworkError(error.localizedDescription)
                    showNetworkError = true
                }
            }
        }
    }

    func deleteChannel(at offsets: IndexSet) {
        if let index = offsets.first {
            viewModel.deleteChannel(at: index)
        }
    }
}

struct WidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetListView(viewModel: ViewModel())
    }
}
