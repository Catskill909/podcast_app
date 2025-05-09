# Pull-to-Refresh Implementation Plan

## 1. Introduction

This document outlines the plan to implement the "pull-to-refresh" feature in the Podcast app. This feature will allow users to swipe down on lists of podcasts and episodes to fetch the latest data from the network.

The standard Flutter `RefreshIndicator` widget will be used for this purpose.

## 2. Current Data Flow Analysis

### 2.1. HomeScreen (`lib/ui/screens/home_screen.dart`)

-   **Data Source:** Displays a list of podcasts.
-   **Fetching:** Uses a `FutureBuilder` tied to `_podcastFuture`.
-   `_podcastFuture` is initialized in `initState` by calling `PodcastApiService.fetchPodcasts()` (via `_fetchWithTimeout`).
-   `PodcastApiService.fetchPodcasts()`:
    -   Checks a Hive cache (`podcasts` box).
    -   If cache hit, returns cached data and starts a background refresh (`_refreshPodcastsInBackground`).
    -   If cache miss, fetches from network (`_fetchAndCacheFromNetwork`), updates cache, and returns data.
-   A "Retry" button in the offline banner also re-initiates `_fetchWithTimeout`.

### 2.2. PodcastDetailScreen (`lib/ui/screens/podcast_detail_screen.dart`)

-   **Data Source:** Displays details and a list of episodes for a single `Podcast` object.
-   **Fetching:** The `Podcast` object (including its `episodes`) is passed to the screen via its constructor (`final Podcast podcast`). No independent data fetching occurs on this screen for the initial display of episodes; they are assumed to be part of the passed `Podcast` object.

### 2.3. PodcastApiService (`lib/core/services/podcast_api_service.dart`)

-   `fetchPodcasts()`: Fetches the main podcast feed (currently hardcoded to KPFA). This method is suitable for `HomeScreen`'s refresh.
-   `_fetchAndCacheFromNetwork()`: Handles the actual network request for the KPFA feed, parses it into a `Podcast` object (with all its episodes), and updates the Hive cache. This is the core logic for getting fresh data.
-   **Missing:** There isn't a dedicated method to refresh a *specific* podcast by its ID or to refresh the episodes of an already loaded `Podcast` object without re-fetching the entire main feed. However, since the app currently only handles one primary podcast feed, `fetchPodcasts()` effectively refreshes that single podcast and its episodes.

## 3. Proposed Implementation Plan

### 3.1. HomeScreen (`lib/ui/screens/home_screen.dart`)

1.  **Wrap `FutureBuilder`'s child:** The `Column` (or `ListView` if directly used) inside the `Expanded` widget that `FutureBuilder` returns when `snapshot.hasData` will be wrapped with `RefreshIndicator`.
2.  **`onRefresh` Callback:**
    ```dart
    RefreshIndicator(
      onRefresh: () async {
        // Option 1: Reuse existing retry logic
        // _fetchWithTimeout(); 
        // return _podcastFuture; // Ensure the future completes for the indicator

        // Option 2: More direct refresh
        setState(() {
          _podcastFuture = apiService.fetchPodcasts().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Network request timed out'),
          );
        });
        await _podcastFuture; // Await the new future to ensure indicator shows
      },
      child: // ... existing ListView.builder setup ...
    );
    ```
    Using Option 2 (direct refresh) is generally cleaner as it explicitly awaits the new data fetch operation required by `onRefresh`.
3.  **State Update:** `setState` within `_fetchWithTimeout` or directly in `onRefresh` (as in Option 2) will cause the `FutureBuilder` to rebuild with the new `_podcastFuture`, showing a loading indicator and then the refreshed data.

### 3.2. PodcastDetailScreen (`lib/ui/screens/podcast_detail_screen.dart`)

This screen is slightly more complex due to receiving `Podcast` data via the constructor.

1.  **Convert to `StatefulWidget` (if not already):** It is already a `StatefulWidget` (`_PodcastDetailScreenState`).
2.  **Maintain Local Podcast State:** The `_PodcastDetailScreenState` will need to manage its own copy of the podcast data to allow for updates.
    ```dart
    class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
      late Podcast _currentPodcast;
      final PodcastApiService _apiService = PodcastApiService(); // Add service instance

      @override
      void initState() {
        super.initState();
        _currentPodcast = widget.podcast; // Initialize with passed data
      }
      // ... build method uses _currentPodcast ...
    }
    ```
3.  **Wrap `ListView.builder`:** The `ListView.builder` displaying episodes will be wrapped with `RefreshIndicator`.
4.  **`onRefresh` Callback:**
    ```dart
    RefreshIndicator(
      onRefresh: () async {
        try {
          // Fetch all podcasts (which includes the one we are viewing, updated)
          List<Podcast> refreshedPodcasts = await _apiService.fetchPodcasts(); 
          // Find the updated version of the current podcast
          // Assuming podcast IDs are unique and reliable
          Podcast? updatedPodcast = refreshedPodcasts.firstWhere(
            (p) => p.id == _currentPodcast.id,
            orElse: () => _currentPodcast, // Fallback to old if not found (should not happen)
          );
          if (mounted && updatedPodcast.id == _currentPodcast.id) { // Check if still mounted and ID matches
            setState(() {
              _currentPodcast = updatedPodcast;
            });
          }
        } catch (e) {
          // Handle error (e.g., show a SnackBar)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to refresh episodes: ${e.toString()}')),
            );
          }
        }
      },
      child: ListView.builder(
        itemCount: _currentPodcast.episodes.length,
        itemBuilder: (context, index) {
          final episode = _currentPodcast.episodes[index];
          // ... rest of the item builder ...
        },
      ),
    );
    ```
5.  **Data Update:** When `onRefresh` completes and `setState` is called with the `updatedPodcast`, the UI will rebuild showing the (potentially) new list of episodes.

## 4. Key Considerations

-   **Error Handling:** The `onRefresh` callbacks must handle potential network errors (e.g., `TimeoutException`, HTTP errors). Displaying a `SnackBar` is a common way to inform the user.
-   **Loading Indicators:** `RefreshIndicator` provides its own visual indicator. The existing `FutureBuilder` on `HomeScreen` also handles loading states.
-   **State Management:** The proposed changes align with the existing state management (local state with `setState` and `FutureBuilder`).
-   **Network Efficiency:** `PodcastApiService.fetchPodcasts()` refreshes the entire main feed. For `PodcastDetailScreen`, this is acceptable given the current app structure (one primary feed). If multiple distinct feeds were managed, a more targeted `fetchPodcastById(id)` would be preferable.
-   **User Experience:** Ensure the refresh action feels responsive and provides clear feedback.

## 5. Next Steps (Post-Documentation Approval)

1.  Implement pull-to-refresh on `HomeScreen.dart` as described.
2.  Implement pull-to-refresh on `PodcastDetailScreen.dart` as described.
3.  Thoroughly test both implementations, including successful refresh, refresh with no new data, and refresh with network errors.
