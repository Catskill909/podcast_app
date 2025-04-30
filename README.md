# Podcast App

A modern, minimal, and slick Flutter podcasting app.

---

## Features

- **Modern UI:** Minimalist design, Material 3, Google Fonts, responsive layouts
- **Podcast Browser:** Home screen with a list of podcasts (mock data, ready for API integration)
- **Podcast Detail:** View podcast description and list of episodes
- **Audio Playback:**
  - Play, pause, seek, and skip audio with just_audio
  - Modern PlayerScreen with progress slider and controls
  - Global MiniPlayer overlay for playback control from anywhere in the app
- **State Management:** Provider for audio and playback state
- **Favorites (stub):** Local storage service ready for favorites/bookmarks
- **Navigation:** Clean, named routing via AppRouter
- **Splash Screen & Launcher Icons:** Automated branding for Android/iOS
- **Interim Dart Splash:** Custom Dart splash screen for a seamless transition after the native splash, matching icon size and background for a professional look
- **Google Fonts:** No manual font assets required
- **Ready for API:** PodcastApiService is abstracted for easy backend integration

---

## Packages Used

- [`just_audio`](https://pub.dev/packages/just_audio): Audio playback
- [`audio_service`](https://pub.dev/packages/audio_service): Background audio, lockscreen & notification controls, system/media button support
- [`audio_session`](https://pub.dev/packages/audio_session): Audio focus and session management
- [`provider`](https://pub.dev/packages/provider): State management
- [`google_fonts`](https://pub.dev/packages/google_fonts): Dynamic font loading
- [`cached_network_image`](https://pub.dev/packages/cached_network_image): Efficient image loading
- [`shared_preferences`](https://pub.dev/packages/shared_preferences): Local storage for favorites
- [`get_it`](https://pub.dev/packages/get_it): Dependency injection
- [`flutter_hooks`](https://pub.dev/packages/flutter_hooks): Cleaner stateful widgets
- [`url_launcher`](https://pub.dev/packages/url_launcher): URL handling and external link support
- [`flutter_social_button`](https://pub.dev/packages/flutter_social_button): Social media sharing buttons
- [`font_awesome_flutter`](https://pub.dev/packages/font_awesome_flutter): Icon set for UI elements
- [`http`](https://pub.dev/packages/http): API calls (for future backend)
- `flutter_launcher_icons`: App icon generation
- `flutter_native_splash`: Splash screen generation

---

## Background Audio & System Controls

This app uses [`audio_service`](https://pub.dev/packages/audio_service) to provide:
- **True background audio playback** (audio continues when the app is minimized or device is locked)
- **Lockscreen and notification controls** (play, pause, skip, seek, etc.)
- **Rich metadata** (title, artist, artwork, playback position) sent to the OS
- **Hardware/media button support** (headphones, car, Bluetooth)

> These features are being actively integrated. See the Roadmap section for progress and planned enhancements.

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
- Replace mock data in PodcastApiService with real API integration
- Add more providers or migrate to Riverpod for advanced state management
- Add more features: downloads, playlists, user profiles, recommendations, etc.
- All lints and warnings are actively managed for clean development

---

## Today's Session Summary (2025-04-28)

- Enabled full dark mode support (auto, system-based)
- Floating mini player background now adapts to dark mode
- Customized app typography: Oswald bold for headers, Nunito for body text
- Investigated scrubber/slider UX and clarified placeholder audio duration behavior
- General theme and UI polish

## Roadmap / Possible Future Developments for a World-Class Podcast App
  - Sending rich metadata to OS
- Refactoring audio logic to use a background audio handler

### 1. Dark Mode Support
- **Completed**: Implement a dark theme (ThemeData.dark) and allow users to toggle between light/dark/system mode.

### 2. Background Audio & Audio Services
- Integrate [`audio_service`](https://pub.dev/packages/audio_service) alongside `just_audio` and `audio_session`.
- Enable true background playback (audio keeps playing when the app is minimized or the screen is off).
- Handle audio focus, interruptions, and phone call events.

### 3. Lockscreen & Status Bar Controls
- Send podcast metadata (title, artist, artwork, position, etc.) to the OS for display on the lockscreen and system notification.
- Support lockscreen controls: play, pause, skip, seek, etc.
- Show playback progress and allow user interaction from outside the app.

### 4. Standard Audio Features for Modern Podcast Apps
- Playback speed control.
- Skip/replay (customizable skip intervals).
- Sleep timer.
- Download for offline listening.
- Playlist/queue management (episode queue, smart playlists, auto-play next).
- Bookmarks and resume playback per episode.
- Mini-player improvements for navigation and quick controls.
- Enhanced notification controls (show artwork, more actions).
- Android 13+ notification permissions and compatibility.
- CI/CD pipeline for automated tests and builds.
- App Store/Play Store release prep (icons, splash screens, privacy, changelog).
- Smart resume and “continue listening.”
- Chapter support and rich episode metadata.
- Hardware/media button support (headphones, car, etc.).
- Analytics and listening stats.
- Accessibility: full support for screen readers, large text, etc.

### 5. Architecture & Code Quality
- Modularize audio logic (services/providers).
- Maintain clean separation of UI, business logic, and platform integrations.
- Write unit and widget tests for all new features.

---

## Possible Future Development

- **Lockscreen & Status Bar Metadata:**
  - Display podcast title, episode, artwork, and playback controls on lockscreen and notification area (using just_audio + audio_session + [audio_service](https://pub.dev/packages/audio_service)).
  - Show playback progress and allow play/pause/seek from lockscreen or notification.
- **Background Playback:**
  - Full support for audio playback when app is in the background (audio_service integration).
- **Media Controls Integration:**
  - Handle hardware/media buttons (play/pause/skip) from headphones, car, or device.
- **Playback Speed & Skip Controls:**
  - Variable playback speed, skip intro/outro, rewind/forward buttons.
- **Podcast Downloads:**
  - Offline playback by downloading episodes to device storage.
- **Smart Playlists & Queues:**
  - Custom episode queues, smart playlists, continue listening, etc.
- **Sleep Timer:**
  - Auto-stop playback after a set time or at episode end.
- **Chapter Support:**
  - Display and jump between chapters within podcast episodes.
- **Transcripts & Search:**
  - Show episode transcripts, allow search within audio or transcript.
- **Sharing & Deep Links:**
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
