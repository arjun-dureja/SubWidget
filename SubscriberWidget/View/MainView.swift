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
        case purchasedPro
    }

    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var currentTab = 0
    @State private var confettiTrigger = 0
    @State private var showPaywall = false
    @State private var showOnboarding = false
    @State private var hasPreparedInitialPresentation = false
    @State private var onboardingAction: OnboardingAction = .none
    @State private var onboardingLastViewedStep: OnboardingStep = .welcome
    @AppStorage("pendingPaywallFromWidget", store: .shared) private var pendingPaywallFromWidget: Bool = false
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
        .onReceive(NotificationCenter.default.publisher(for: .paywallRequested)) { _ in
            handleWidgetPaywallRequest(source: "widget")
        }
        .onChange(of: hasProAccess) { hasProAccess in
            guard hasProAccess else { return }
            if showOnboarding {
                onboardingAction = .purchasedPro
            }
            hasCompletedOnboarding = true
            showOnboarding = false
        }
        .onAppear {
            if pendingPaywallFromWidget {
                pendingPaywallFromWidget = false
                handleWidgetPaywallRequest(source: "widget_cold_start")
            }
        }
        .task {
            await prepareInitialPresentation()
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
            OnboardingView(
                onStepViewed: { step in
                    onboardingLastViewedStep = step
                },
                onComplete: completeOnboarding
            )
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
                AnalyticsService.shared.logPaywallShown(source: source)
                showPaywall = true
            }
        }
    }

    @MainActor
    private func prepareInitialPresentation() async {
        guard !hasPreparedInitialPresentation else { return }
        hasPreparedInitialPresentation = true

        await SubscriptionService().checkAccess()

        guard !hasProAccess else {
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

        switch onboardingAction {
        case .completed:
            currentTab = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(name: .addWidgetRequested, object: nil)
            }
        case .purchasedPro:
            break
        case .none:
            AnalyticsService.shared.logOnboardingDismissed(
                step: onboardingLastViewedStep.analyticsName,
                stepIndex: onboardingLastViewedStep.rawValue + 1,
                source: "sheet_dismiss"
            )
        }

        onboardingAction = .none
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
