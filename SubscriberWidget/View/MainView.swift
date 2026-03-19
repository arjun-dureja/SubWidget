//
//  MainView.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2021-02-13.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import SwiftUI
import WishKit
import WidgetKit
import ConfettiSwiftUI

struct MainView: View {
    private enum OnboardingAction {
        case none
        case completed
    }

    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var currentTab = 0
    @State private var confettiTrigger = 0
    @State private var showPaywall = false
    @State private var showWidgetUpgradeAlert = false
    @State private var showOnboarding = false
    @State private var hasPreparedInitialPresentation = false
    @State private var onboardingAction: OnboardingAction = .none
    @State private var widgetPaywallSource = "widget_free"
    @AppStorage("pendingPaywallFromWidget", store: .shared) private var pendingPaywallFromWidget: Bool = false
    @AppStorage("pendingWidgetPaywallSource", store: .shared) private var pendingWidgetPaywallSource: String = "widget_free"
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false
    @AppStorage("hasCompletedOnboarding", store: .shared) private var hasCompletedOnboarding: Bool = false

    init() {
        WishKit.configure(with: Constants.wishKitApiKey)
        WishKit.config.statusBadge = .hide
        WishKit.config.commentSection = .hide
        WishKit.config.emailField = .none
        WishKit.config.buttons.addButton.bottomPadding = .large
        WishKit.config.buttons.segmentedControl.display = .hide
        WishKit.config.allowUndoVote = true

        WishKit.theme.primaryColor = .youtubeRed
        WishKit.theme.secondaryColor = .set(light: .white, dark: Color(UIColor.systemGray6))
        WishKit.theme.tertiaryColor = .set(light: Color(UIColor.systemGray6), dark: .black)
    }

    var body: some View {
        TabView(selection: $currentTab) {
            WidgetListView(viewModel: viewModel)
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .onAppear {
                    currentTab = 0
                }

            WishKit.FeedbackListView().withNavigation()
                .tag(1)
                .tabItem {
                    Label("Wishlist", systemImage: "lightbulb.fill")
                }
                .onAppear {
                    currentTab = 1
                }

            SettingsView(viewModel: viewModel)
                .tag(2)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .onAppear {
                    currentTab = 2
                }
        }
        .accentColor(.youtubeRed)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onReceive(NotificationCenter.default.publisher(for: .revenueCatPurchaseCompleted)) { _ in
            confettiTrigger += 1
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onReceive(NotificationCenter.default.publisher(for: .paywallRequested)) { notification in
            let source = notification.object as? String ?? "widget_free"
            handleWidgetPaywallRequest(source: source)
        }
        .onChange(of: hasProAccess) { hasProAccess in
            guard hasProAccess else { return }
            hasCompletedOnboarding = true
            showOnboarding = false
        }
        .onAppear {
            if pendingPaywallFromWidget {
                pendingPaywallFromWidget = false
                handleWidgetPaywallRequest(source: pendingWidgetPaywallSource)
            }
        }
        .task {
            await prepareInitialPresentation()
        }
        .alert("Open in YouTube", isPresented: $showWidgetUpgradeAlert) {
            Button("Close", role: .cancel) {}
            Button("Upgrade now") {
                AnalyticsService.shared.logPaywallShown(source: widgetPaywallSource)
                showPaywall = true
            }
        } message: {
            Text("Upgrade to Pro to open your YouTube channel directly from the widget")
        }
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 40,
            rainHeight: 750,
            radius: 500,
            repetitions: 1,
        )
        .sheet(
            isPresented: $showOnboarding,
            onDismiss: handleOnboardingDismissed
        ) {
            OnboardingView(onComplete: completeOnboarding)
            .interactiveDismissDisabled()
            .presentationDragIndicator(.hidden)
        }
        .paywallSheet(isPresented: $showPaywall)
    }

    @MainActor
    private func handleWidgetPaywallRequest(source: String) {
        Task {
            await SubscriptionService().checkAccess()
            if !hasProAccess {
                if source == "widget_locked" {
                    AnalyticsService.shared.logPaywallShown(source: source)
                    showPaywall = true
                    return
                }

                widgetPaywallSource = source
                AnalyticsService.shared.logWidgetUpgradeAlertShown(source: source)
                showWidgetUpgradeAlert = true
            }
        }
    }

    @MainActor
    private func prepareInitialPresentation() async {
        guard !hasPreparedInitialPresentation else { return }
        hasPreparedInitialPresentation = true

        await SubscriptionService().checkAccess()
        let hasSavedChannels = !ChannelStorageService().getChannels().isEmpty

        guard !hasProAccess else {
            hasCompletedOnboarding = true
            return
        }

        guard !hasSavedChannels else {
            hasCompletedOnboarding = true
            return
        }

        guard !hasCompletedOnboarding else { return }
        
        showOnboarding = true
    }

    private func completeOnboarding() {
        onboardingAction = .completed
        hasCompletedOnboarding = true
        showOnboarding = false
    }

    private func handleOnboardingDismissed() {
        hasCompletedOnboarding = true

        if onboardingAction == .completed {
            currentTab = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(name: .addWidgetRequested, object: nil)
            }
        }

        onboardingAction = .none
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
