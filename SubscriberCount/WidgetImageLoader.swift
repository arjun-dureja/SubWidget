//
//  WidgetImageLoader.swift
//  SubscriberWidget
//
//  Created by OpenAI on 2026-03-14.
//

import UIKit
import ImageIO

enum WidgetImageLoader {
    static func getImageForUrl(
        _ urlString: String,
        fallbackSystemName: String,
        size: CGSize
    ) async -> UIImage {
        guard let url = URL(string: urlString) else {
            return UIImage(systemName: fallbackSystemName) ?? UIImage()
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            return downsampleImage(from: data, to: size)
                ?? UIImage(systemName: fallbackSystemName)
                ?? UIImage()
        } catch {
            AnalyticsService.shared.logWidgetImageFetchFailed(
                url: url.absoluteString,
                error: error.localizedDescription
            )
        }

        return UIImage(systemName: fallbackSystemName) ?? UIImage()
    }

    private static func downsampleImage(from data: Data, to size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return nil
        }

        let maxDimension = max(size.width, size.height)
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            downsampleOptions as CFDictionary
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
