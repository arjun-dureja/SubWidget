//
//  ShareableWidgetCard.swift
//  SubscriberWidget
//
//  Created by Codex on 2025-02-14.
//

import SwiftUI
import UIKit

enum ShareBackgroundStyle: String, CaseIterable, Identifiable {
    case ember
    case ocean
    case violet
    case aurora
    case rose
    case sunrise
    case citrus
    case blush
    case lagoon
    case solid

    var id: String { rawValue }

    var colors: [Color] {
        switch self {
        case .ember:
            return [Color(hex: "140D0D"), Color(hex: "3A1515"), Color(hex: "0B0B0E")]
        case .ocean:
            return [Color(hex: "0A1722"), Color(hex: "153E62"), Color(hex: "0B0D11")]
        case .violet:
            return [Color(hex: "171225"), Color(hex: "3F2A68"), Color(hex: "0E0D17")]
        case .aurora:
            return [Color(hex: "071A19"), Color(hex: "0E5B57"), Color(hex: "0A1020")]
        case .rose:
            return [Color(hex: "21101B"), Color(hex: "7C284F"), Color(hex: "120D12")]
        case .sunrise:
            return [Color(hex: "FFF1D6"), Color(hex: "FDBA74"), Color(hex: "FB7185")]
        case .citrus:
            return [Color(hex: "FEF3C7"), Color(hex: "FDE047"), Color(hex: "F59E0B")]
        case .blush:
            return [Color(hex: "FCE7F3"), Color(hex: "F9A8D4"), Color(hex: "C084FC")]
        case .lagoon:
            return [Color(hex: "D1FAE5"), Color(hex: "67E8F9"), Color(hex: "3B82F6")]
        case .solid:
            return [.black, .black, .black]
        }
    }

    var glowColor: Color {
        switch self {
        case .ember:
            return .youtubeRed
        case .ocean:
            return Color(hex: "38BDF8")
        case .violet:
            return Color(hex: "A78BFA")
        case .aurora:
            return Color(hex: "2DD4BF")
        case .rose:
            return Color(hex: "FB7185")
        case .sunrise:
            return Color(hex: "FB7185")
        case .citrus:
            return Color(hex: "F59E0B")
        case .blush:
            return Color(hex: "E879F9")
        case .lagoon:
            return Color(hex: "22D3EE")
        case .solid:
            return .white
        }
    }

    var isSolid: Bool {
        self == .solid
    }

}

struct ShareCardConfiguration {
    var backgroundStyle: ShareBackgroundStyle
    var zoom: Double = 1.0
    var showsGlow: Bool = true
    var shadowStrength: Double = 0.75
    var showsBorder: Bool = false
    var borderWidth: Double = 2.5
    var solidBackgroundHex: String = "#0B0B0D"
    var borderHex: String = "#FFFFFF"

    init() {
        self.backgroundStyle = .ember
    }

    var solidBackgroundColor: Color {
        Color(hex: solidBackgroundHex)
    }

    var borderColor: Color {
        Color(hex: borderHex)
    }
}

extension ShareCardConfiguration: Equatable {
    static func == (lhs: ShareCardConfiguration, rhs: ShareCardConfiguration) -> Bool {
        lhs.backgroundStyle == rhs.backgroundStyle &&
        lhs.zoom == rhs.zoom &&
        lhs.showsGlow == rhs.showsGlow &&
        lhs.shadowStrength == rhs.shadowStrength &&
        lhs.showsBorder == rhs.showsBorder &&
        lhs.borderWidth == rhs.borderWidth &&
        lhs.solidBackgroundHex == rhs.solidBackgroundHex &&
        lhs.borderHex == rhs.borderHex
    }
}

struct ShareableWidgetCard: View {
    static let canvasSize = CGSize(width: 1_200, height: 1_200)

    @Environment(\.colorScheme) private var colorScheme

    let channel: YouTubeChannel
    let page: WidgetPreviewPage
    let channelImage: UIImage?
    let hasProAccess: Bool
    let configuration: ShareCardConfiguration

    private var baseWidgetScale: CGFloat {
        let baseScale: CGFloat
        switch page.size {
        case .small:
            baseScale = 4.35
        case .medium:
            baseScale = 2.9
        }
        return baseScale * configuration.zoom
    }

    private var widgetOffsetY: CGFloat {
        page.size == .small ? -18 : -8
    }

    private var widgetBackgroundColor: Color {
        if let bgColor = channel.bgColor {
            return Color(bgColor)
        }
        return colorScheme == .dark ? .black : .white
    }

    private var backgroundColors: [Color] {
        configuration.backgroundStyle.isSolid
            ? Array(repeating: configuration.solidBackgroundColor, count: 3)
            : configuration.backgroundStyle.colors
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if configuration.showsGlow {
                Circle()
                    .fill(configuration.backgroundStyle.glowColor.opacity(configuration.backgroundStyle.isSolid ? 0.18 : 0.30))
                    .frame(width: Self.canvasSize.width * 0.54, height: Self.canvasSize.width * 0.54)
                    .blur(radius: configuration.backgroundStyle.isSolid ? 150 : 220)
                    .offset(x: -Self.canvasSize.width * 0.17, y: -Self.canvasSize.height * 0.16)

                Circle()
                    .fill(
                        (configuration.backgroundStyle.isSolid ? configuration.solidBackgroundColor : .white)
                            .opacity(configuration.backgroundStyle.isSolid ? 0.08 : 0.16)
                    )
                    .frame(width: Self.canvasSize.width * 0.40, height: Self.canvasSize.width * 0.40)
                    .blur(radius: configuration.backgroundStyle.isSolid ? 120 : 190)
                    .offset(x: Self.canvasSize.width * 0.18, y: Self.canvasSize.height * 0.19)

                Circle()
                    .fill(configuration.backgroundStyle.glowColor.opacity(configuration.backgroundStyle.isSolid ? 0.08 : 0.05))
                    .frame(width: Self.canvasSize.width * 0.78, height: Self.canvasSize.width * 0.78)
                    .blur(radius: configuration.backgroundStyle.isSolid ? 140 : 120)
                    .offset(x: 0, y: Self.canvasSize.height * 0.06)
            }

            RoundedRectangle(cornerRadius: 25)
                .fill(widgetBackgroundColor)
                .frame(width: page.size.width, height: 155)
                .scaleEffect(baseWidgetScale)
                .shadow(
                    color: .black.opacity(0.24 + configuration.shadowStrength * 0.34),
                    radius: 22 + configuration.shadowStrength * 50,
                    y: 16 + configuration.shadowStrength * 28
                )
                .offset(y: widgetOffsetY)

            ShareableWidgetPreview(
                channel: channel,
                page: page,
                channelImage: channelImage,
                hasProAccess: hasProAccess,
                exportMode: true,
                onUpgrade: nil
            )
            .overlay {
                if configuration.showsBorder {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(configuration.borderColor.opacity(0.9), lineWidth: configuration.borderWidth)
                        .frame(width: page.size.width, height: 155)
                }
            }
            .scaleEffect(baseWidgetScale)
            .offset(y: widgetOffsetY)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    HStack(spacing: 12) {
                        AppIcon()
                            .cornerRadius(12)
                            .opacity(0.75)
                            .frame(width: 36, height: 36)

                        Text("Made with SubWidget")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(.black.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(.trailing, 42)
            .padding(.bottom, 38)
        }
        .frame(width: Self.canvasSize.width, height: Self.canvasSize.height)
        .clipped()
    }
}
