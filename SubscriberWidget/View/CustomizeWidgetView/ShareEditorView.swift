//
//  ShareEditorView.swift
//  SubscriberWidget
//
//  Created by Codex on 2025-02-14.
//

import SwiftUI

struct ShareEditorView: View {
    let channel: YouTubeChannel
    let page: WidgetPreviewPage
    let hasProAccess: Bool
    let colorScheme: ColorScheme

    @Environment(\.dismiss) private var dismiss

    @State private var configuration: ShareCardConfiguration
    @State private var isSharing = false
    @State private var previewImage: UIImage?
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var errorMessage: String?
    @State private var previewRenderTask: Task<Void, Never>?

    init(channel: YouTubeChannel, page: WidgetPreviewPage, hasProAccess: Bool, colorScheme: ColorScheme) {
        self.channel = channel
        self.page = page
        self.hasProAccess = hasProAccess
        self.colorScheme = colorScheme
        _configuration = State(initialValue: ShareCardConfiguration())
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    previewSection
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            controlsSection
                                .padding(.bottom, 28)
                        }

                        LinearGradient(
                            colors: [
                                Color(UIColor.systemGroupedBackground).opacity(0.0),
                                Color(UIColor.systemGroupedBackground).opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 38)
                        .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer(minLength: 0)
                shareButtonBar
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle("Share", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
        .onAppear {
            schedulePreviewRender()
        }
        .onDisappear {
            previewRenderTask?.cancel()
        }
        .onChange(of: configuration) { _ in
            schedulePreviewRender()
        }
        .onChange(of: configuration.backgroundStyle) { style in
            AnalyticsService.shared.logWidgetShareBackgroundSelected(name: style.rawValue)
        }
        .alert("Couldn't Share Widget", isPresented: errorBinding) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Something went wrong while generating the widget image.")
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview")
                .font(.headline)
                .padding(.horizontal, 2)

            ZStack {
                if let previewImage {
                    GeometryReader { geometry in
                        let side = min(geometry.size.width, geometry.size.height) - 18

                        Image(uiImage: previewImage)
                            .resizable()
                            .interpolation(.high)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: side, height: side)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    ProgressView()
                }
            }
            .frame(height: 270)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 12) {
            ShareControlCard(title: "Background") {
                VStack(alignment: .leading, spacing: 14) {
                    BackgroundSwatchPicker(
                        options: ShareBackgroundStyle.allCases,
                        selection: $configuration.backgroundStyle,
                        solidBackgroundColor: configuration.solidBackgroundColor
                    )

                    if configuration.backgroundStyle == .solid {
                        ColorPicker(
                            "Color",
                            selection: Binding(
                                get: { configuration.solidBackgroundColor },
                                set: { configuration.solidBackgroundHex = UIColor($0).hexStringFromColor() }
                            ),
                            supportsOpacity: false
                        )
                    }
                }
            }

            ShareControlCard {
                HStack(spacing: 14) {
                    Text("Zoom")
                        .font(.subheadline.bold())
                        .frame(width: 70, alignment: .leading)

                    Slider(value: $configuration.zoom, in: 0.85...1.2)
                        .tint(.youtubeRed)
                }
            }

            ShareControlCard {
                HStack(spacing: 14) {
                    Text("Shadow")
                        .font(.subheadline.bold())
                        .frame(width: 70, alignment: .leading)

                    Slider(value: $configuration.shadowStrength, in: 0...1)
                        .tint(.youtubeRed)
                }
            }

            ShareToggleCard(title: "Glow", isOn: $configuration.showsGlow)

            ShareToggleCard(title: "Border", isOn: $configuration.showsBorder) {
                VStack(spacing: 14) {
                    HStack(spacing: 24) {
                        Text("Thickness")
                            .font(.subheadline.bold())

                        Slider(value: $configuration.borderWidth, in: 1...8)
                            .tint(.youtubeRed)
                    }

                    ColorPicker(
                        "Color",
                        selection: Binding(
                            get: { configuration.borderColor },
                            set: { configuration.borderHex = UIColor($0).hexStringFromColor() }
                        ),
                        supportsOpacity: false
                    )
                }
            }
        }
    }

    private var shareButtonBar: some View {
        VStack(spacing: 0) {
            Button(action: share) {
                HStack {
                    Spacer()
                    if isSharing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Share Image", systemImage: "square.and.arrow.up")
                            .font(.headline)
                    }
                    Spacer()
                }
                .padding(.vertical, 18)
                .background(Color.youtubeRed)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(isSharing)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(UIColor.systemGroupedBackground).opacity(0.0),
                    Color(UIColor.systemGroupedBackground),
                    Color(UIColor.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func share() {
        isSharing = true
        AnalyticsService.shared.logWidgetShareTapped(
            page: page.analyticsName,
            channelName: channel.channelName
        )

        Task {
            do {
                let url = try await WidgetShareRenderer().render(
                    channel: channel,
                    page: page,
                    hasProAccess: hasProAccess,
                    colorScheme: colorScheme,
                    configuration: configuration
                )

                await MainActor.run {
                    shareItems = [url]
                    showShareSheet = true
                    isSharing = false
                    AnalyticsService.shared.logWidgetShareSucceeded(
                        page: page.analyticsName,
                        channelName: channel.channelName
                    )
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSharing = false
                    AnalyticsService.shared.logWidgetShareFailed(
                        page: page.analyticsName,
                        channelName: channel.channelName,
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    private func renderPreview() async {
        do {
            let image = try await WidgetShareRenderer().renderImage(
                channel: channel,
                page: page,
                hasProAccess: hasProAccess,
                colorScheme: colorScheme,
                configuration: configuration
            )

            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                previewImage = image
            }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                previewImage = nil
            }
        }
    }

    private func schedulePreviewRender() {
        previewRenderTask?.cancel()
        previewRenderTask = Task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            guard !Task.isCancelled else { return }
            await renderPreview()
        }
    }
}

private struct ShareControlCard<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    init(@ViewBuilder content: () -> Content) {
        self.title = nil
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.subheadline.bold())
            }

            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

private struct ShareToggleCard<Content: View>: View {
    let title: String
    @Binding var isOn: Bool
    let content: Content?

    init(title: String, isOn: Binding<Bool>) where Content == EmptyView {
        self.title = title
        self._isOn = isOn
        self.content = nil
    }

    init(title: String, isOn: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isOn = isOn
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.youtubeRed)
            }

            if isOn, let content {
                content
                    .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

private struct BackgroundSwatchPicker: View {
    let options: [ShareBackgroundStyle]
    @Binding var selection: ShareBackgroundStyle
    let solidBackgroundColor: Color

    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 48, maximum: 56), spacing: 10)
        ]

        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                option.isSolid
                                    ? AnyShapeStyle(solidBackgroundColor)
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: option.colors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay {
                                Circle()
                                    .fill(option.glowColor.opacity(option.isSolid ? 0.18 : 0.28))
                                    .frame(width: 36, height: 36)
                                    .blur(radius: option.isSolid ? 20 : 28)
                                    .offset(x: -8, y: 10)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        selection == option ? Color.white.opacity(0.9) : Color.white.opacity(0.08),
                                        lineWidth: selection == option ? 2.5 : 1
                                    )
                            }
                            .frame(height: 48)

                        if selection == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(.black.opacity(0.24))
                                .clipShape(Circle())
                                .padding(6)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
