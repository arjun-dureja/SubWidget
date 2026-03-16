//
//  LatestUploadMediumWidget.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import SwiftUI
import WidgetKit

struct LatestUploadMediumWidget: View {
    var entry: LatestUploadEntry?
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("showWidgetRefreshButton", store: .shared) private var showWidgetRefreshButton: Bool = false
    @AppStorage("hasProAccess", store: .shared) private var hasProAccess: Bool = false
    @AppStorage("simplifyNumbers", store: .shared) private var simplifyNumbers: Bool = false

    private var channel: YouTubeChannel? {
        entry?.channel
    }

    private var latestUpload: LatestUploadVideo? {
        entry?.latestUpload
    }

    private var displayUpload: LatestUploadVideo {
        latestUpload ?? .placeholder
    }

    private var shouldShowRefreshButton: Bool {
        guard hasProAccess else { return false }
        guard showWidgetRefreshButton else { return false }
        guard channel?.channelName != YouTubeChannel.preview.channelName else { return false }
        return latestUpload != nil
    }

    private var accentColor: Color {
        if let color = channel?.accentColor {
            return Color(color)
        }

        return Color("AccentColor")
    }

    private var numberColor: Color {
        if let color = channel?.numberColor {
            return Color(color)
        }

        return .youtubeRed
    }

    private var isPlaceholder: Bool {
        latestUpload == nil && channel != nil
    }

    var body: some View {
        ZStack {
            if let channel {
                HStack(spacing: 12) {
                    thumbnailView

                    VStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 0)

                        HStack(alignment: .center, spacing: 8) {
                            Text(channel.channelName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(accentColor.opacity(0.78))
                                .lineLimit(1)

                            Spacer(minLength: 6)

                            Group {
                                if shouldShowRefreshButton {
                                    WidgetRefreshButton(widgetKind: LatestUploadWidget.kind)
                                } else {
                                    YouTubeLogo()
                                        .scaleEffect(0.9)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(displayUpload.title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(accentColor)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .minimumScaleFactor(0.75)
                                .padding(.top, 6)

                            HStack(alignment: .top, spacing: 10) {
                                statView(icon: "eye.fill", value: displayUpload.viewCount, label: "Views")
                                statView(icon: "hand.thumbsup.fill", value: displayUpload.likeCount, label: "Likes")
                                statView(icon: "bubble.left.fill", value: displayUpload.commentCount, label: "Comments")
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
                .redacted(reason: isPlaceholder ? .placeholder : [])
                .minimumScaleFactor(0.3)
                .containerBackground(for: .widget) {
                    if let bgColor = channel.bgColor {
                        Color(bgColor)
                    }
                }
            } else {
                ConfigurationView(baselineOffset: 0.0)
                    .containerBackground(for: .widget) {
                        if let bgColor = channel?.bgColor {
                            Color(bgColor)
                        }
                    }
            }
        }
    }

    private var thumbnailView: some View {
        Group {
            if Utils.isInWidget(), let entry {
                Image(uiImage: entry.thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let url = URL(string: displayUpload.thumbnailUrl), !displayUpload.thumbnailUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Image(systemName: "play.rectangle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.youtubeRed)
                            .padding(24)
                    } else {
                        ProgressView()
                            .scaleEffect(1.2, anchor: .center)
                    }
                }
            } else {
                Image(systemName: "play.rectangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.youtubeRed)
                    .padding(24)
                    .background(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05))
            }
        }
        .frame(width: 114, height: 97)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statView(icon: String, value: String?, label: String) -> some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(numberColor)
                Text(formatted(value))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(numberColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(accentColor.opacity(0.58))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatted(_ value: String?) -> String {
        guard let value else {
            return "—"
        }

        if simplifyNumbers {
            return value.simplified()
        }

        if let intValue = Int(value), intValue >= 10_000 {
            return value.simplified()
        }

        return value.formattedWithSeparator()
    }
}

#Preview {
    LatestUploadMediumWidget(
        entry: LatestUploadEntry(
            channel: .preview,
            latestUpload: .preview
        )
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
}
