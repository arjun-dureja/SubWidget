//
//  OnboardingAddWidgetCard.swift
//  SubscriberWidget
//

import SwiftUI

struct OnboardingAddWidgetCard: View {
    private let mediumScale: CGFloat = 0.90

    var body: some View {
        let entry = OnboardingPreviewData.mrBeastEntry(widgetType: .combined)

        VStack(spacing: 16) {
            MediumWidget(entry: entry)
                .widgetBackground(bgColor: nil, size: .medium)
                .frame(width: WidgetSize.medium.width, height: 155)
                .scaleEffect(mediumScale)
                .frame(width: WidgetSize.medium.width * mediumScale, height: 155 * mediumScale)

            OnboardingInlineStepsView(
                firstStep: "Add your channel",
                secondStep: "Place the widget"
            )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

struct OnboardingInlineStepsView: View {
    let firstStep: LocalizedStringKey
    let secondStep: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingInlineStepRow(number: "1", text: firstStep)
            OnboardingInlineStepRow(number: "2", text: secondStep)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

struct OnboardingInlineStepRow: View {
    let number: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 10) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(Color.youtubeRed)
                )

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}
