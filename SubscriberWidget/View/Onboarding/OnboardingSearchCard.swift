//
//  OnboardingSearchCard.swift
//  SubscriberWidget
//

import SwiftUI

struct OnboardingSearchCard: View {
    @Environment(\.colorScheme) private var colorScheme
    private let mediumScale: CGFloat = 0.90

    var body: some View {
        let entry = OnboardingPreviewData.mkbhdEntry(widgetType: .subscribers)

        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                Text("@mkbhd")
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 50)
            .background(searchBarFill)
            .cornerRadius(16)

            VStack(spacing: 12) {
                OnboardingSearchResultCard(
                    name: "Marques Brownlee",
                    imageName: OnboardingPreviewData.mkbhdImageName
                )

                Image(systemName: "arrow.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.youtubeRed)

                MediumWidget(entry: entry)
                    .widgetBackground(bgColor: nil, size: .medium)
                    .frame(width: WidgetSize.medium.width, height: 155)
                    .scaleEffect(mediumScale)
                    .frame(width: WidgetSize.medium.width * mediumScale, height: 155 * mediumScale)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(cardBackground)
        .cornerRadius(26)
    }

    private var searchBarFill: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color(UIColor.systemBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.youtubeRed.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.youtubeRed.opacity(0.10), lineWidth: 1)
            )
    }
}

struct OnboardingSearchResultCard: View {
    let name: String
    let imageName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .shadow(radius: 2)

            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.youtubeRed)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        )
    }
}
