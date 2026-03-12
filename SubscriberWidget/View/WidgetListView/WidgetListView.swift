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
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false

    @State private var showSearch = false
    @State private var navigateToChannelId: String?
    @State private var tooManyChannels = false
    @State private var showWhatsNew = false
    @State private var showUpdateAlert = false
    @State private var showNetworkError = false
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                if colorScheme == .light {
                    Color(UIColor.systemGray6)
                        .ignoresSafeArea(.all)
                }

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
                                            channel: channel
                                        ),
                                        tag: channel.id,
                                        selection: $navigateToChannelId,
                                        label: {
                                            ChannelListRow(channel: channel)
                                                .redacted(
                                                    reason: viewModel.state == .loading ? .placeholder : []
                                                )
                                        })
                                    .contextMenu {
                                        Button {
                                            viewModel.deleteChannel(channel)
                                        } label: {
                                            Text("Delete")
                                        }
                                    }
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
            .navigationBarItems(
                leading: hasProAccess ? nil : Button {
                    AnalyticsService.shared.logPaywallShown(source: "pro_button")
                    showPaywall = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.gold)
                        Text("Pro")
                            .foregroundColor(.youtubeRed)
                    }
                },
                trailing: viewModel.channels.isEmpty ? nil : AddWidgetButton(action: addWidgetTapped)
            )
            .sheet(isPresented: $showSearch, content: {
                ChannelSearchView(
                    viewModel: viewModel,
                    onChannelAdded: { channel in
                        navigateToChannelId = channel.id
                        if viewModel.channels.count > 1 {
                            AnalyticsService.shared.logReviewRequested()
                            DispatchQueue.main.async {
                                requestReview()
                            }
                        }
                    }
                )
            })
            .sheet(isPresented: $showWhatsNew, content: {
                WhatsNewView(isPresented: $showWhatsNew)
            })
            .paywallSheet(isPresented: $showPaywall)
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
        .onReceive(NotificationCenter.default.publisher(for: .addWidgetRequested)) { _ in
            addWidgetTapped()
        }
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
        AnalyticsService.shared.logAddNewChannelTapped()
        if !hasProAccess && viewModel.channels.count >= 1 {
            AnalyticsService.shared.logPaywallShown(source: "add_channel")
            showPaywall = true
            return
        }

        if hasProAccess && viewModel.channels.count >= 10 {
            tooManyChannels = true
        } else {
            showSearch = true
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
