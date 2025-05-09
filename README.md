# Podcast App

A modern, minimal, and slick Flutter podcasting app.

---

## Features

- **Core Functionality**
  - Browse and discover podcasts
  - View detailed podcast information and episode lists
  - Play, pause, seek, and skip audio playback
  - Control playback from anywhere in the app with the MiniPlayer
  - Share episodes with title, description, and artwork
  - Navigate between screens using clean, named routing

- **Audio Features**
  - Background audio playback
  - Lockscreen controls
  - Media button support
  - Rich metadata with artwork and progress

- **Technical Architecture**
  - Modern state management with Provider
  - Abstracted API service for easy backend integration
  - Standardized error handling and notifications
  - Automated branding and splash screens
  - Dynamic font loading with Google Fonts

- **Future Features (Planned)**
  - Local storage for favorites and bookmarks
  - Offline support for downloaded episodes
  - Advanced caching system
  - Custom episode queues and playlists

---

## Technical Details

- **Current Implementation**
  - Network-based podcast discovery and playback
  - Basic caching of images and metadata
  - Connectivity monitoring with retry options
  - Standardized error handling

- **Planned Enhancements**
  - Full offline support with Hive database
  - Episode downloading and local playback
  - Favorite podcasts and episodes
  - Advanced caching strategies

---

## Packages Used

- **Core Audio & Playback**


---

## Packages Used

- [`just_audio`](https://pub.dev/packages/just_audio): Audio playback
- [`audio_service`](https://pub.dev/packages/audio_service): Background audio, lockscreen & notification controls, system/media button support
- [`audio_session`](https://pub.dev/packages/audio_session): Audio focus and session management
- [`provider`](https://pub.dev/packages/provider): State management
- [`http`](https://pub.dev/packages/http): Network requests for fetching podcast feeds
- [`xml`](https://pub.dev/packages/xml): XML parsing for RSS feeds
- [`html`](https://pub.dev/packages/html): HTML parsing (used by flutter_html and for descriptions)
- [`flutter_html`](https://pub.dev/packages/flutter_html): Renders HTML content for episode descriptions
- [`hive`](https://pub.dev/packages/hive): Fast, lightweight NoSQL database for local caching
- [`hive_flutter`](https://pub.dev/packages/hive_flutter): Flutter helpers for Hive
- [`connectivity_plus`](https://pub.dev/packages/connectivity_plus): Checks network connectivity status
- [`google_fonts`](https://pub.dev/packages/google_fonts): Dynamic font loading
- [`cached_network_image`](https://pub.dev/packages/cached_network_image): Efficient image loading and caching
- [`shared_preferences`](https://pub.dev/packages/shared_preferences): Simple local storage (e.g., for user preferences, can be used for favorites)
- [`get_it`](https://pub.dev/packages/get_it): Dependency injection / Service locator
- [`flutter_hooks`](https://pub.dev/packages/flutter_hooks): Cleaner stateful widget logic
- [`url_launcher`](https://pub.dev/packages/url_launcher): Launching URLs in external apps/browsers
- [`share_plus`](https://pub.dev/packages/share_plus): Native sharing functionality
- [`font_awesome_flutter`](https://pub.dev/packages/font_awesome_flutter): Additional icon set
- [`flutter_social_button`](https://pub.dev/packages/flutter_social_button): Pre-styled social media buttons (if used)

---

## Background Audio & System Controls

This app uses [`audio_service`](https://pub.dev/packages/audio_service) to provide:
- **True background audio playback** (audio continues when the app is minimized or device is locked)
- **Lockscreen and notification controls** (play, pause, skip, seek, etc.)
- **Rich metadata** (title, artist, artwork, playback position) sent to the OS
- **Hardware/media button support** (headphones, car, Bluetooth)

> These features are fully implemented.

---

## Architecture Overview

- `lib/core/services/`: Audio, API, and storage services
- `lib/core/models/`: Data models for Podcast and Episode
- `lib/core/providers/`: Provider for audio state
- `lib/ui/screens/`: Home, Podcast Detail, Player screens
- `lib/ui/widgets/`: Reusable widgets like MiniPlayer
- `lib/ui/navigation/`: AppRouter for named navigation

---

## Future AI/Developer Notes

- All services and models are designed for easy extension (API, favorites, downloads, etc.)
- Add more API feeds
- Add more providers or migrate to Riverpod for advanced state management
- Add more features: downloads, playlists, user profiles, recommendations, etc.
- All lints and warnings are actively managed for clean development

---

## 2025-05-09: Development Session Summary

### UI/UX Enhancements - SnackBar Consistency
- **Global SnackBar Theming:**
  - Established a global `SnackBarThemeData` in `main.dart` to ensure all SnackBars default to `SnackBarBehavior.floating` with a consistent rounded shape.
- **Standardized "No Connection" SnackBar:**
  - Implemented a reusable `buildNoConnectionSnackBar` function.
  - This SnackBar provides a consistent message, "Offline" icon, and a "Retry" button.
  - Features a crucial `margin` with `bottom: 80.0` to ensure it always displays above the mini-player, enhancing visibility.
- **Consistent Application Across Screens:**
  - The `MiniPlayer` now uses this standardized SnackBar when a user attempts to play content while offline.
  - The `PlayerScreen` (both main play button and refresh button) also utilizes this SnackBar for offline scenarios.
- **Improved Retry Logic:**
  - The "Retry" button on the SnackBar correctly attempts to play the episode by calling `setCurrentEpisode()` and `play()` on the `AudioProvider`.
  - Simplified the UX to prevent cascading SnackBars on repeated offline retries.

---

## 2025-05-06: Development Session Summary

### Network Optimization and Reliability
- **Robust Network Handling**:
  - Implemented timeout handling for network requests (10-second timeout)
  - Added specific error handling for network timeouts and failures
  - Improved error categorization and user feedback
- **Caching Strategy**:
  - Added local caching of podcast feed data
  - Implemented background refresh mechanism
  - Added cache-first strategy for faster startup
- **Connectivity Monitoring**:
  - Added network connectivity checks using `connectivity_plus`
  - Improved offline support with better error states

### UI/UX Enhancements
- **Loading States**:
  - Improved loading indicators with better feedback
  - Added retry functionality for failed network requests
  - Enhanced error messages and user guidance
- **Performance**:
  - Optimized image loading with `cached_network_image`
  - Improved startup time through caching
  - Added better error boundaries for network operations
- **Sharing**:
  - Added native sharing functionality using `share_plus`
  - Users can now share current episodes from the player view
  - Share includes episode title, description, and artwork

### Technical Improvements
- **Code Quality**:
  - Added proper null safety checks for network operations
  - Improved error handling patterns
  - Enhanced type safety in network-related code
- **Architecture**:
  - Separated network concerns into dedicated services
  - Improved state management for network operations
  - Added better separation of concerns in network handling

## 2025-05-02: Development Session Summary

### Major Fixes and Improvements
- **Restored all missing podcast and episode text**: Improved XML parsing logic to robustly extract text from RSS feeds, including CDATA and value fallbacks, ensuring all descriptions, titles, and summaries display correctly.
- **UI/UX Enhancements**:
  - Episode images now use Material border and drop shadow for depth, matching Material Design best practices.
  - Episode description text is lighter for better readability on dark backgrounds.
  - Episode list rows are now minimalist: only the bold episode title (with date) is shown, with all redundant or cluttered text removed.
  - All headers use Oswald font and are styled with the app's minimalist dark theme.
- **Performance Refactor**:
  - Episode lists now use `ListView.builder` for lazy loading, ensuring smooth scrolling and low memory usage even with long feeds.
  - Transparency and shadow effects now use `.withAlpha` for better performance and to resolve deprecation warnings.

### Technical and Code Quality
- All lints and warnings (including deprecated API usage) have been addressed.
- No redundant or duplicate information is present in this README or the codebase as of this update.
- All existing app functions, navigation, and audio features remain unchanged and stable.

---
- Investigated scrubber/slider UX and clarified placeholder audio duration behavior
- General theme and UI polish

## Possible Future Development

- Centralized configuration file for feeds, colors, menu items, and app constants.
- Add even richer metadata (e.g., chapters, transcripts, segment artwork), smarter resume/queueing, or analytics.
- Enhance smart playlists, recommendations, and user profiles.
- Add advanced sharing, deep links, and social features.
- Expand accessibility and localization support.
- Implement advanced analytics and listening stats.
- Further modularize audio and state management for scalability.
- App Store/Play Store release prep (icons, splash screens, privacy, changelog).
- Monetization: support for premium feeds, donations, or ad-insertion.

**Aspirational Podcast App Features:**

- **Resume Playback Patterns:**
  1. **Auto-resume silently (for ongoing playback or recent episodes):**
     - When a user navigates back to the same episode, the app automatically resumes from where they left off, without asking.
     - The scrubber (seek bar) reflects the last position.
     - Common in: Spotify, Apple Podcasts, Pocket Casts.
  2. **Prompt with "Resume or Start Over" (if position is old or episode changed):**
     - If the user hasn’t listened in a while, or the episode is long:
     - A prompt like:
       > “Resume from 12:43?”  
       > ▶️ Resume | ⏪ Start Over
     - Some apps show a mini progress bar under each episode in the list, indicating how much has been listened.
  3. **Progress tracking per episode:**
     - The app saves playback position per episode.
     - When an episode is fully played, it’s marked as "played", and progress resets.
  4. **UI elements typically used:**
     - Progress bar / scrubber: shows current position.
     - Timestamp indicator: e.g., "Last played at 12:43".
     - "Resume playing" button on episode screen or player.
     - Episode list UI with progress bar under titles.
- **Standard Audio Features:**
  - Variable playback speed, skip intro/outro, rewind/forward buttons.
  - Sleep timer (auto-stop after set time or at episode end).
  - Download for offline listening.
  - Playlist/queue management (episode queue, smart playlists, auto-play next).
  - Bookmarks and resume playback per episode.
  - Mini-player improvements for navigation and quick controls.
  - Enhanced notification controls (show artwork, more actions).
  - Hardware/media button support (headphones, car, Bluetooth, etc.).
  - Chapter support and rich episode metadata.
  - Show episode transcripts, allow search within audio or transcript.
  - Share episodes or podcasts with deep linking support.
  - Analytics and listening stats (track listening habits, completion rates, insights).
  - Accessibility: full support for screen readers, large text, etc.

**Architecture & Code Quality Goals:**
- Maintain clean separation of UI, business logic, and platform integrations.
- Write unit and widget tests for all new features.
- Further modularize audio logic (services/providers) for scalability.

---

## Roadmap

### Next Steps
- Add user feedback for network errors (e.g., banners, snackbars, or dialogs when offline or playback fails).
- Provide retry options for failed network requests or playback.
- Consider audio download/caching for true offline playback.
- Improve image caching (e.g., using cached_network_image).
- Enhance UI/UX: mini-player, episode queue, skip/seek controls, playback speed, sharing, and deep linking.

### Best-in-Class Podcast App Network & Offline Experience

### Extensibility for Downloads
Our cache and network layer is being architected to support not only feed caching and offline playback, but also robust episode downloads in the future. Download logic, storage, and offline playback will build on this unified infrastructure. As we proceed, we may add placeholders or refactor current code to ensure extensibility for downloads and other advanced features.


Our next major goal: deliver the best solution for a modern podcasting app—reliable, offline-ready, and seamless. Staged, testable development:

**Stage 1: Local Caching**
- Cache podcast feed data (Hive/SharedPreferences)
- Load from cache on startup; background refresh updates cache
- *Test:* Simulate network loss, verify cached data loads/refreshes

**Stage 2: Connectivity Monitoring**
- Use connectivity_plus for online/offline detection
- Show clear 'No Internet' messages, retry options
- *Test:* Toggle connectivity, verify UI feedback

**Stage 3: Full Offline Support**
- Always show cached data offline
- *Test:* Run offline, verify full cached experience

**Stage 4: Advanced Error Handling**
- Categorize errors, user-friendly error/retry UI
- *Test:* Simulate errors, verify feedback/recovery

---

## Possible Future Development

- Variable playback speed, skip intro/outro, rewind/forward buttons.
- Offline playback by downloading episodes to device storage.
- Custom episode queues, smart playlists, continue listening, etc.
- Auto-stop playback after a set time or at episode end (sleep timer).
- Display and jump between chapters within podcast episodes.
- Show episode transcripts, allow search within audio or transcript.
- Share episodes or podcasts with deep linking support.
- Add even richer metadata (e.g., chapters, transcripts, segment artwork), smarter resume/queueing, or analytics.
- Enhance smart playlists, recommendations, and user profiles.
- Add advanced sharing, deep links, and social features.
- Expand accessibility and localization support.
- Implement advanced analytics and listening stats.
- Further modularize audio and state management for scalability.
  - Share episodes or podcasts with deep linking support.
- **Analytics & Listening Stats:**
  - Track listening habits, completion rates, and provide insights to users.
- **Monetization:**
  - Support for premium feeds, donations, or ad-insertion.
- **Accessibility:**
  - VoiceOver/TalkBack, larger text, and other accessibility improvements.

**Note:** Many of these features can be built with the current audio stack (just_audio, audio_session, and audio_service) and by extending the app’s existing architecture.

---

## Getting Started

1. Install dependencies:
   ```sh
   flutter pub get
   ```
2. Run the app:
   ```sh
   flutter run
   ```
3. To update icons or splash:
   ```sh
   flutter pub run flutter_launcher_icons:main
   flutter pub run flutter_native_splash:create
   ```

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
