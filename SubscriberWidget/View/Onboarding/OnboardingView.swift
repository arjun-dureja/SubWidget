//
//  OnboardingView.swift
//  SubscriberWidget
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep: OnboardingStep = .welcome

    let onStepViewed: (OnboardingStep) -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(currentStep: currentStep)

            TabView(selection: $currentStep) {
                ForEach(OnboardingStep.allCases) { step in
                    OnboardingPageView(step: step)
                        .tag(step)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            OnboardingFooterView(
                currentStep: currentStep,
                onContinue: handleContinueTapped
            )
        }
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            AnalyticsService.shared.logOnboardingShown()
            AnalyticsService.shared.logOnboardingStepViewed(currentStep.analyticsName, stepIndex: currentStep.rawValue + 1)
            onStepViewed(currentStep)
        }
        .onChange(of: currentStep) { step in
            AnalyticsService.shared.logOnboardingStepViewed(step.analyticsName, stepIndex: step.rawValue + 1)
            onStepViewed(step)
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : Color(UIColor.systemGray6)
    }

    private func handleContinueTapped() {
        if currentStep == .addWidget {
            AnalyticsService.shared.logOnboardingCompleted()
            onComplete()
            return
        }

        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        AnalyticsService.shared.logOnboardingAdvanced(
            from: currentStep.analyticsName,
            to: nextStep.analyticsName,
            nextStepIndex: nextStep.rawValue + 1
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = nextStep
        }
    }
}

#Preview {
    OnboardingView(onStepViewed: { _ in }, onComplete: {})
}

struct OnboardingHeaderView: View {
    let currentStep: OnboardingStep

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases) { step in
                    Capsule()
                        .fill(step == currentStep ? Color.youtubeRed : Color.primary.opacity(0.10))
                        .frame(height: 6)
                }
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, OnboardingStyle.horizontalPadding)
        .padding(.bottom, OnboardingStyle.verticalSpacing)
    }
}

struct OnboardingFooterView: View {
    let currentStep: OnboardingStep
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Divider()

            Button(action: onContinue) {
                Text(currentStep.buttonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 54)
            }
            .background(Color.youtubeRed)
            .clipShape(RoundedRectangle(cornerRadius: OnboardingStyle.buttonCornerRadius))
            .padding(.horizontal, OnboardingStyle.horizontalPadding)
            .padding(.bottom, OnboardingStyle.verticalSpacing)
        }
    }
}

struct OnboardingPageView: View {
    @Environment(\.colorScheme) private var colorScheme

    let step: OnboardingStep

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(step.eyebrow)
                    .font(.caption.bold())
                    .tracking(1.4)
                    .foregroundStyle(Color.youtubeRed)

                Text(step.title)
                    .font(.title.bold())
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(step.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            switch step {
            case .welcome:
                OnboardingWelcomeCard()
            case .addChannels:
                OnboardingSearchCard()
            case .addWidget:
                OnboardingAddWidgetCard()
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, OnboardingStyle.horizontalPadding)
        .padding(.bottom, 8)
    }
}

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case addChannels
    case addWidget

    var id: Int { rawValue }

    var eyebrow: LocalizedStringKey {
        switch self {
        case .welcome:
            "AT A GLANCE"
        case .addChannels:
            "FIND A CHANNEL"
        case .addWidget:
            "START FREE"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .welcome:
            "YouTube channel statistics, at a glance"
        case .addChannels:
            "Search a channel. Add the widget."
        case .addWidget:
            "Add your first channel for free"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .welcome:
            "See subscriber and view counts on your home screen or lock screen."
        case .addChannels:
            "Search by name, @handle, or channel ID. See a preview instantly."
        case .addWidget:
            "Add your first channel now, then place the widget when you’re ready."
        }
    }

    var buttonTitle: LocalizedStringKey {
        switch self {
        case .addWidget:
            "Get Started"
        default:
            "Continue"
        }
    }

    var analyticsName: String {
        switch self {
        case .welcome:
            "welcome"
        case .addChannels:
            "search_preview"
        case .addWidget:
            "get_started"
        }
    }
}

enum OnboardingStyle {
    static let horizontalPadding: CGFloat = 24
    static let verticalSpacing: CGFloat = 18
    static let cardCornerRadius: CGFloat = 26
    static let buttonCornerRadius: CGFloat = 18
    static let compactSpacing: CGFloat = 10
}

enum OnboardingPreviewData {
    static let mkbhdImageName = "OnboardingAvatar-mkbhd"

    static func mkbhdChannel(displayName: String = "Marques Brownlee") -> YouTubeChannel {
        var preview = YouTubeChannel.preview
        preview.channelName = displayName
        preview.profileImage = mkbhdImageName
        preview.subCount = "20100000"
        preview.viewCount = "4700000000"
        preview.channelId = "UCBJycsmduvYEL83R_U4JriQ"
        return preview
    }

    static func mkbhdEntry(widgetType: WidgetType, displayName: String = "Marques Brownlee") -> SimpleEntry {
        SimpleEntry(
            channel: mkbhdChannel(displayName: displayName),
            channelImage: UIImage(named: mkbhdImageName) ?? UIImage(systemName: "person.circle")!,
            widgetType: widgetType
        )
    }
}
