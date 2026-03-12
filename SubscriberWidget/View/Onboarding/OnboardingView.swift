//
//  OnboardingView.swift
//  SubscriberWidget
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep: OnboardingStep = .welcome

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
            AnalyticsService.shared.logOnboardingStepViewed()
        }
        .onChange(of: currentStep) { _ in
            AnalyticsService.shared.logOnboardingStepViewed()
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
        AnalyticsService.shared.logOnboardingAdvanced()
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = nextStep
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
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
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
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
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
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
        .padding(.horizontal, 24)
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
}

enum OnboardingPreviewData {
    static let mkbhdImageName = "OnboardingAvatar-mkbhd"
    static let mrBeastImageName = "OnboardingAvatar-mrbeast"

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

    static func mrBeastEntry(widgetType: WidgetType, displayName: String = "MrBeast") -> SimpleEntry {
        var preview = YouTubeChannel.preview
        preview.channelName = displayName
        preview.profileImage = mrBeastImageName
        preview.subCount = "389000000"
        preview.viewCount = "75800000000"
        preview.channelId = "UCX6OQ3DkcsbYNE6H8uQQuVA"

        return SimpleEntry(
            channel: preview,
            channelImage: UIImage(named: mrBeastImageName) ?? UIImage(systemName: "person.circle")!,
            widgetType: widgetType
        )
    }
}
