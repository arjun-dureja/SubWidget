//
//  WidgetShareRenderer.swift
//  SubscriberWidget
//
//  Created by Codex on 2025-02-14.
//

import SwiftUI
import UIKit

enum WidgetShareRendererError: LocalizedError {
    case imageGenerationFailed

    var errorDescription: String? {
        switch self {
        case .imageGenerationFailed:
            return "Could not generate the widget image."
        }
    }
}

@MainActor
struct WidgetShareRenderer {
    func renderImage(
        channel: YouTubeChannel,
        page: WidgetPreviewPage,
        hasProAccess: Bool,
        colorScheme: ColorScheme,
        configuration: ShareCardConfiguration
    ) async throws -> UIImage {
        let previewImage = await loadImage(from: channel.profileImage)
        let view = ShareableWidgetCard(
            channel: channel,
            page: page,
            channelImage: previewImage,
            hasProAccess: hasProAccess,
            configuration: configuration
        )
        .environment(\.colorScheme, colorScheme)
        .frame(
            width: ShareableWidgetCard.canvasSize.width,
            height: ShareableWidgetCard.canvasSize.height
        )

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1

        guard let image = renderer.uiImage else {
            throw WidgetShareRendererError.imageGenerationFailed
        }

        return image
    }

    func render(
        channel: YouTubeChannel,
        page: WidgetPreviewPage,
        hasProAccess: Bool,
        colorScheme: ColorScheme,
        configuration: ShareCardConfiguration
    ) async throws -> URL {
        let image = try await renderImage(
            channel: channel,
            page: page,
            hasProAccess: hasProAccess,
            colorScheme: colorScheme,
            configuration: configuration
        )

        guard let pngData = image.pngData() else {
            throw WidgetShareRendererError.imageGenerationFailed
        }

        let sanitizedName = channel.channelName
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter(\.isASCII)
        let fileName = "subwidget-\(sanitizedName)-\(page.analyticsName).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }

        try pngData.write(to: url)
        return url
    }

    private func loadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
