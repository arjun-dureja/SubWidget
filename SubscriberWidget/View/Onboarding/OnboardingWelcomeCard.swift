//
//  OnboardingWelcomeCard.swift
//  SubscriberWidget
//

import SwiftUI
import UIKit

struct OnboardingWelcomeCard: View {
    private let widgetScale: CGFloat = 0.86
    private let carouselSpacing: CGFloat = 8
    private let lockscreenWidth: CGFloat = 172
    private let lockscreenHeight: CGFloat = 78
    private let rowSpacing: CGFloat = 16
    private let showcaseItems: [OnboardingWidgetShowcaseItem] = Self.makeShowcaseItems()

    var body: some View {
        let cardShape = RoundedRectangle(cornerRadius: 26, style: .continuous)

        ZStack {
            cardShape
                .fill(Color(UIColor.secondarySystemGroupedBackground))

            VStack(spacing: rowSpacing) {
                showcaseRow(phaseOffset: 0.0)
                showcaseRow(phaseOffset: 0.36)
            }
            .padding(.vertical, 14)
        }
        .clipShape(cardShape)
        .overlay {
            cardShape
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        }
        .frame(height: 350)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func showcaseRow(phaseOffset: Double) -> some View {
        OnboardingCarousel(
            pointsPerSecond: 32,
            contentWidth: sequenceWidth,
            spacing: carouselSpacing,
            phaseOffset: phaseOffset
        ) {
            HStack(spacing: carouselSpacing) {
                ForEach(showcaseItems) { item in
                    OnboardingWidgetShowcaseItemView(
                        item: item,
                        widgetScale: widgetScale,
                        lockscreenWidth: lockscreenWidth,
                        lockscreenHeight: lockscreenHeight
                    )
                }
            }
        }
    }

    private var sequenceWidth: CGFloat {
        showcaseItems.reduce(CGFloat.zero) { partialResult, item in
            partialResult + item.displaySize(
                widgetScale: widgetScale,
                lockscreenWidth: lockscreenWidth,
                lockscreenHeight: lockscreenHeight
            ).width
        } + (CGFloat(showcaseItems.count - 1) * carouselSpacing)
    }

    private static func makeShowcaseItems() -> [OnboardingWidgetShowcaseItem] {
        let palettes = Palette.presets

        return [
            .init(channel: channel(
                name: "MrBeast",
                subscribers: "389000000",
                views: "75800000000",
                imageName: "OnboardingAvatar-mrbeast",
                palette: palettes[6]
            ), family: .small, widgetType: .subscribers, channelImage: channelImage(named: "OnboardingAvatar-mrbeast")),
            .init(channel: channel(
                name: "Marques Brownlee",
                subscribers: "20100000",
                views: "4700000000",
                imageName: "OnboardingAvatar-mkbhd",
                palette: palettes[11]
            ), family: .medium, widgetType: .combined, channelImage: channelImage(named: "OnboardingAvatar-mkbhd")),
            .init(channel: channel(
                name: "PewDiePie",
                subscribers: "111000000",
                views: "29300000000",
                imageName: "OnboardingAvatar-pewdiepie",
                palette: palettes[13]
            ), family: .lockscreen, widgetType: .subscribers, channelImage: channelImage(named: "OnboardingAvatar-pewdiepie")),
            .init(channel: channel(
                name: "iShowSpeed",
                subscribers: "39500000",
                views: "4300000000",
                imageName: "OnboardingAvatar-ishowspeed",
                palette: palettes[14],
            ), family: .small, widgetType: .views, channelImage: channelImage(named: "OnboardingAvatar-ishowspeed")),
            .init(channel: channel(
                name: "Mark Rober",
                subscribers: "69800000",
                views: "140000000",
                imageName: "OnboardingAvatar-mark-rober",
                palette: palettes[0],
            ), family: .medium, widgetType: .views, channelImage: channelImage(named: "OnboardingAvatar-mark-rober")),
            .init(channel: channel(
                name: "Linus Tech Tips",
                subscribers: "16200000",
                views: "4600000000",
                imageName: "OnboardingAvatar-linus-tech-tips",
                palette: palettes[10]
            ), family: .lockscreen, widgetType: .views, channelImage: channelImage(named: "OnboardingAvatar-linus-tech-tips")),
            .init(channel: channel(
                name: "Veritasium",
                subscribers: "17100000",
                views: "2300000000",
                imageName: "OnboardingAvatar-veritasium",
                palette: palettes[2]
            ), family: .medium, widgetType: .subscribers, channelImage: channelImage(named: "OnboardingAvatar-veritasium"))
        ]
    }

    private static func channel(
        name: String,
        subscribers: String,
        views: String,
        imageName: String,
        palette: Palette
    ) -> YouTubeChannel {
        YouTubeChannel(
            channelName: name,
            profileImage: imageName,
            subCount: subscribers,
            viewCount: views,
            channelId: "",
            bgColor: UIColor(palette.background),
            accentColor: UIColor(palette.accent),
            numberColor: UIColor(palette.number)
        )
    }

    private static func channelImage(named name: String) -> UIImage {
        UIImage(named: name) ?? UIImage(systemName: "person.circle")!
    }
}

struct OnboardingWidgetShowcaseItem: Identifiable {
    static let widgetHeight: CGFloat = 155
    static let shadowPadding: CGFloat = 12

    enum Family {
        case small
        case medium
        case lockscreen
    }

    let id: String
    let channel: YouTubeChannel
    let family: Family
    let widgetType: WidgetType
    let channelImage: UIImage

    init(channel: YouTubeChannel, family: Family, widgetType: WidgetType, channelImage: UIImage) {
        self.id = "\(channel.channelId)-\(String(describing: family))-\(widgetType.rawValue)"
        self.channel = channel
        self.family = family
        self.widgetType = widgetType
        self.channelImage = channelImage
    }

    var widgetSize: WidgetSize? {
        switch family {
        case .small:
            .small
        case .medium:
            .medium
        case .lockscreen:
            nil
        }
    }

    var baseSize: CGSize {
        switch family {
        case .small:
            CGSize(width: WidgetSize.small.width, height: Self.widgetHeight)
        case .medium:
            CGSize(width: WidgetSize.medium.width, height: Self.widgetHeight)
        case .lockscreen:
            .zero
        }
    }

    func displaySize(widgetScale: CGFloat, lockscreenWidth: CGFloat, lockscreenHeight: CGFloat) -> CGSize {
        switch family {
        case .small, .medium:
            let baseSize = baseSize
            return CGSize(
                width: (baseSize.width * widgetScale) + (Self.shadowPadding * 2),
                height: (baseSize.height * widgetScale) + (Self.shadowPadding * 2)
            )
        case .lockscreen:
            return CGSize(width: lockscreenWidth, height: lockscreenHeight)
        }
    }
}

struct OnboardingWidgetShowcaseItemView: View {
    let item: OnboardingWidgetShowcaseItem
    let widgetScale: CGFloat
    let lockscreenWidth: CGFloat
    let lockscreenHeight: CGFloat

    var body: some View {
        switch item.family {
        case .small:
            scaledWidgetPreview {
                SmallWidget(entry: entry)
            }
        case .medium:
            scaledWidgetPreview {
                MediumWidget(entry: entry)
            }
        case .lockscreen:
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                LockscreenWidget(entry: entry)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .frame(width: lockscreenWidth, height: lockscreenHeight)
        }
    }

    @ViewBuilder
    private func scaledWidgetPreview<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let baseSize = item.baseSize
        let displaySize = item.displaySize(
            widgetScale: widgetScale,
            lockscreenWidth: lockscreenWidth,
            lockscreenHeight: lockscreenHeight
        )

        content()
            .widgetBackground(bgColor: item.channel.bgColor, size: item.widgetSize ?? .small)
            .frame(width: baseSize.width, height: baseSize.height)
            .scaleEffect(widgetScale)
            .padding(OnboardingWidgetShowcaseItem.shadowPadding)
            .frame(width: displaySize.width, height: displaySize.height)
    }

    private var entry: SimpleEntry {
        SimpleEntry(
            channel: item.channel,
            channelImage: item.channelImage,
            widgetType: item.widgetType
        )
    }
}

struct OnboardingCarousel<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let pointsPerSecond: CGFloat
    let contentWidth: CGFloat
    let spacing: CGFloat
    let phaseOffset: Double
    @ViewBuilder let content: () -> Content

    @State private var startDate = Date()

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.periodic(from: startDate, by: 1.0 / 60.0)) { timeline in
                ZStack(alignment: .leading) {
                    HStack(spacing: spacing) {
                        content()
                        content()
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .compositingGroup()
                    .drawingGroup()
                    .offset(x: offset(for: timeline.date))
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            .clipped()
        }
        .onAppear {
            startDate = .now
        }
    }

    private var travelDistance: CGFloat {
        contentWidth + spacing
    }

    private var animationDuration: Double {
        Double(travelDistance / pointsPerSecond)
    }

    private func offset(for date: Date) -> CGFloat {
        guard !reduceMotion else {
            return -travelDistance * CGFloat((0.18 + phaseOffset).truncatingRemainder(dividingBy: 1))
        }

        let elapsed = date.timeIntervalSince(startDate)
        let progress = (elapsed.truncatingRemainder(dividingBy: animationDuration) / animationDuration + phaseOffset)
            .truncatingRemainder(dividingBy: 1)
        return -travelDistance * progress
    }
}
