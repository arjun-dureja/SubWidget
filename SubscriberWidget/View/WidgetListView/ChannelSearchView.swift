//
//  ChannelSearchView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-15.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct ChannelSearchView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""
    @State private var searchResults: [Channel] = []
    @State private var isSearching = false
    @State private var showingNotFoundAlert = false
    @State private var showNetworkError = false
    @FocusState private var isTextFieldFocused: Bool

    let onChannelAdded: (YouTubeChannel) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                if colorScheme == .light {
                    Color(UIColor.systemGray6)
                        .ignoresSafeArea(.all)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        ChannelTextField(
                            name: $searchText,
                            isFocused: $isTextFieldFocused,
                            submitButtonTapped: searchChannels
                        )

                        SubmitButton(
                            showingAlert: $showingNotFoundAlert,
                            loading: $isSearching,
                            submitButtonTapped: searchChannels
                        )

                        HelpButton()
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    if searchResults.isEmpty {
                        searchEmptyState
                    } else {
                        searchResultsList
                    }

                    Spacer()
                }
                .navigationBarTitle("Add Channel", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.youtubeRed)
                    }
                }
            }
            .alert("Network error. Please try again later.", isPresented: $showNetworkError) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var searchEmptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Search for your channel")
                .font(.system(size: 18, weight: .semibold))
            Text("Enter a YouTube channel name or ID")
                .font(.system(size: 14))
                .foregroundColor(colorScheme == .dark ? .darkModeTitleGray2 : .titleGray)
            Spacer()
        }
        .padding()
    }

    private var searchResultsList: some View {
        List {
            ForEach(searchResults) { channel in
                ChannelSearchResultRow(channel: channel, onAdd: { addChannel(channel) })
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private func searchChannels() {
        guard !searchText.isEmpty else { return }
        isTextFieldFocused = false

        Task {
            isSearching = true
            defer { isSearching = false }

            do {
                searchResults = try await viewModel.searchChannels(for: searchText)
            } catch SubWidgetError.channelNotfound {
                searchResults = []
                AnalyticsService.shared.logChannelSearchFailed(searchText)
                showingNotFoundAlert = true
            } catch {
                showNetworkError = true
            }
        }
    }

    private func addChannel(_ channel: Channel) {
        Task {
            do {
                let fullChannel = try await viewModel.youtubeService.getChannelDetailsFromId(for: channel.channelId)
                let addedChannel = viewModel.addChannel(fullChannel)
                presentationMode.wrappedValue.dismiss()
                onChannelAdded(addedChannel)
            } catch {
                showNetworkError = true
            }
        }
    }
}

struct ChannelSearchResultRow: View {
    @Environment(\.colorScheme) var colorScheme
    let channel: Channel
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: URL(string: channel.profileImage))
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                .shadow(radius: 2)

            Text(channel.channelName)
                .fontWeight(.bold)
                .font(.system(size: 16))
                .foregroundColor(Color("AccentColor"))
                .lineLimit(2)
                .minimumScaleFactor(0.5)

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.youtubeRed)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
