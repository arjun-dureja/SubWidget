# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
SubWidget is an iOS app with WidgetKit extensions that displays YouTube channel subscriber and view counts on the home screen. The app fetches data from the YouTube Data API v3 and supports customizable widgets with multiple channels, refresh frequencies, and color schemes.

## Build and Run Commands

### Build the project
```bash
xcodebuild -project SubscriberWidget.xcodeproj -scheme SubscriberWidget -configuration Debug build
```

### Build for device
```bash
xcodebuild -project SubscriberWidget.xcodeproj -scheme SubscriberWidget -configuration Release -sdk iphoneos build
```

### Clean build
```bash
xcodebuild -project SubscriberWidget.xcodeproj -scheme SubscriberWidget clean
```

### Resolve package dependencies
```bash
xcodebuild -resolvePackageDependencies -project SubscriberWidget.xcodeproj
```

### Run SwiftLint
```bash
swiftlint lint
```

SwiftLint is configured to lint only the `SubscriberWidget`, `SubscriberCount`, and `SubWidgetIntents` directories. Configuration is in `.swiftlint.yml`.

## Project Structure

### Targets
The project contains three main targets:

1. **SubscriberWidget** - Main iOS app target
2. **SubscriberCountExtension** - Widget extension for displaying subscriber/view counts
3. **SubWidgetIntents** - App intents extension for Siri/Shortcuts integration

### Architecture

**Main App (SubscriberWidget)**
- **MVVM pattern**: `ViewModel.swift` is the central view model that manages app state
- **Services layer**: Protocol-based services for separation of concerns
  - `YouTubeService`: Fetches channel data from YouTube Data API with caching (2-minute expiry)
  - `ChannelStorageService`: Persists channels and settings to shared UserDefaults
  - `AnalyticsService`: Mixpanel event tracking singleton
- **Model**: Core data models in `Model/` directory
  - `YouTubeChannel`: Main channel model with color customization
  - `RefreshFrequencies`: Enum defining widget refresh intervals (30 min - 12 hours)
  - Custom `Codable` implementations for `UIColor` persistence via `CustomColor` struct
- **Shared state**: Uses `UserDefaults.shared` (App Group: `group.com.arjundureja.SubscriberWidget`) to share data between app and widget extensions

**Widget Extension (SubscriberCount)**
- Uses `IntentTimelineProvider` pattern via `SubWidgetIntentTimelineProvider`
- Supports three widget families: `.systemSmall`, `.systemMedium`, `.accessoryRectangular` (lockscreen)
- Two widget types defined by `WidgetType` enum: `.subscribers` and `.views`
- Widget views: `SmallWidget`, `MediumWidget`, `LockscreenWidget`
- Timeline refresh based on user-configured `RefreshFrequencies`

**App Intents (SubWidgetIntents)**
- `IntentHandler`: Provides channel list for widget configuration picker
- Integrates with `ChannelStorageService` to populate available channels

### Data Flow
1. User adds/updates channels in main app → stored via `ChannelStorageService` to shared UserDefaults
2. Widget extension reads from shared UserDefaults via same service
3. Widget timeline provider fetches fresh data from `YouTubeService` (with caching)
4. Widget updates according to refresh frequency setting

### API Integration
- **YouTube Data API v3** endpoint: `https://www.googleapis.com/youtube/v3/`
- API key stored in `Constants.swift` (also contains Mixpanel and WishKit tokens)
- Three primary API queries:
  - Channel search by name: `search?part=snippet&q={name}&type=channel`
  - Channel details by ID: `channels?part=snippet&id={id}`
  - Channel statistics: `channels?part=statistics&id={channelId}`
- Caching: Uses the `Cache` library (Hyperoslo) with 120-second expiry for channel data
- Response handling via generic `Response<T>` wrapper and custom error types in `SubWidgetError`

### Dependencies (Swift Package Manager)
- **Mixpanel** (`mixpanel/mixpanel-swift@master`): Analytics tracking
- **Cache** (`hyperoslo/Cache@d048bf4`): In-memory and disk caching for API responses
- **WishKit** (`wishkit/wishkit-ios@4.3.1`): Feature request and feedback system

## Key Development Patterns

### Color Customization
- Channels support three customizable colors: `bgColor`, `accentColor`, `numberColor` (all optional `UIColor?`)
- Colors are persisted via `CustomColor` struct that breaks down RGBA components for Codable conformance
- Extensions in `Extensions.swift` provide `Color(hex:)` initializer and `UIColor.hexStringFromColor()` for hex conversion

### Async/Await
- All API calls use Swift concurrency (`async/await`)
- Main actor isolation on `ViewModel` via `@MainActor` attribute
- Concurrent channel updates use `withThrowingTaskGroup` for parallel fetching

### Error Handling
- Custom `SubWidgetError` enum for domain-specific errors (e.g., `.channelNotfound`, `.invalidURL`, `.serverError`)
- Loading states tracked via `LoadingState` enum: `.loading`, `.loaded`, `.error`
- Failed channel decoding is logged but skipped (non-fatal) to prevent showing errors for individual bad channels

### SwiftUI Patterns
- Conditional view modifiers via custom `.if()` extension
- Custom shape for partial corner rounding via `RoundedCorner: Shape`
- Environment-based widget family detection: `@Environment(\.widgetFamily)`

### Number Formatting
- String extension `.simplified()` formats large numbers (e.g., "1.5M", "2.3B")
- `.formattedWithSeparator()` adds locale-appropriate thousands separators
- Both used for displaying subscriber/view counts

## Testing
This project does not currently have automated tests configured in the Xcode schemes.

## Important Notes
- The app uses deeplinks with scheme `subwidget://` for channel-specific navigation
- Widget timeline policy uses `.after()` with user-configured refresh frequency
- All widget timeline entries include fetched channel images resized to 400x400 to stay within widget size limits
- When updating channels, always generate new UUIDs to avoid ID conflicts with existing channels
