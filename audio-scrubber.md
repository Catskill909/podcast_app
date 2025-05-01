# Audio Scrubber Fix Plan

## Problem Summary

The audio scrubber in the Flutter podcast app exhibits several issues:
1.  **Missing Duration:** The scrubber doesn't display the total audio length upon loading.
2.  **No Tracking:** The scrubber doesn't update its position as the audio plays.
3.  **State Reset:** When navigating away from the `PlayerScreen` (while audio plays via the `MiniPlayer`) and then returning, the scrubber resets to the beginning (0:00).

Analysis points to issues in how audio state (duration and position) is managed and consumed:
*   `PodcastAudioHandler` doesn't include the `duration` in its broadcasted `PlaybackState`.
*   `PlayerScreen` uses a static `episode.duration` for the slider's max value, not the dynamic state from the audio handler.
*   UI components might not be consistently listening to the single source of truth (`AudioProvider`/`AudioHandler`) for updates, especially during navigation.

## Proposed Plan

1.  **Enhance `PodcastAudioHandler` (`lib/core/services/audio_handler.dart`):**
    *   Modify `_broadcastState` to include `duration: _player.duration` within the `PlaybackState` object added to the stream. This ensures the total duration is broadcast alongside the position.

2.  **Refactor `PlayerScreen` Scrubber (`lib/ui/screens/player_screen.dart`):**
    *   Update the `Slider` widget's `max` value. Instead of `widget.episode.duration`, use the duration from the `AudioProvider`'s `PlaybackState` (e.g., `audioProvider.playbackState.value.duration?.inSeconds.toDouble() ?? 0.0`). This ensures the slider reflects the actual duration reported by the player.

3.  **Ensure Consistent State in UI (`lib/ui/widgets/app_scaffold.dart`):**
    *   Verify that the `MiniPlayer` widget within `AppScaffold` correctly consumes `isPlaying`, `position`, and `duration` from the `AudioProvider`'s `PlaybackState`.
    *   If a progress indicator/scrubber is intended for the `MiniPlayer` area, implement it using the state from `AudioProvider`.

## Mermaid Diagram

```mermaid
graph TD
    A[User Action: Play Audio] --> B(AudioProvider: setCurrentEpisode);
    B --> C{PodcastAudioHandler: loadMediaItem};
    C --> D[just_audio: setUrl];
    D --> E{just_audio: playbackEventStream};
    E --> F[PodcastAudioHandler: _broadcastState];
    F -- Currently Missing Duration --> G(PlaybackState Stream);
    G --> H{AudioProvider: notifyListeners};
    H --> I[UI Widgets: PlayerScreen / MiniPlayer];
    I -- Reads position --> J(Slider Value);
    I -- Reads static episode.duration --> K(Slider Max - Incorrect);

    subgraph Proposed Fix
        F -- Add player.duration --> L(PlaybackState Stream with Duration);
        L --> H;
        I -- Reads playbackState.duration --> M(Slider Max - Correct);
    end

    style K fill:#f9f,stroke:#333,stroke-width:2px
    style M fill:#ccf,stroke:#333,stroke-width:2px
## Update (2025-04-30): Attempt 1 Failure

The initial fix attempt involved updating `PlayerScreen` to use `audioProvider.audioHandler.mediaItem.value?.duration` for the slider's max value.

**Result:** Failed.
*   Scrubber still defaults to a fixed duration (reported as 30 mins).
*   Scrubber does not move/track playback.
*   Issue persists after navigation.

**Next Steps:** Re-examine `PlayerScreen`, `AudioProvider`, `PodcastAudioHandler`, and potentially the `Episode` model to understand why the duration isn't loading correctly and why position updates aren't reflected in the UI.
## Update (2025-04-30): Attempt 2 Result

**Partial Fix:**  
- The audio scrubber now displays the correct total duration and allows seeking.  
- The audio resumes from the scrubber position after seeking.

**Remaining Issue:**  
- The scrubber does **not** automatically move to track the current playback position as the audio plays. This is not standard podcast audio behavior.

**Next Required Fix:**  
- Standard `just_audio` usage for position tracking is to listen to the player's `positionStream` and update the UI as new positions arrive.
- The `AudioProvider` should expose a `Stream<Duration>` for the current position, sourced from `audioHandler._player.positionStream` (or equivalent).
- The `PlayerScreen` should use a `StreamBuilder` (or similar) to rebuild the scrubber as the position updates, ensuring smooth tracking.

**Reference:**  
See the [`just_audio` documentation on position tracking](https://pub.dev/packages/just_audio#position-and-buffered-position) for the recommended approach.