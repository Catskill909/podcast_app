# Podcast App Network and Offline Reliability Roadmap

## Staged Development & Testing Plan

**Note:** The caching/network layer will be designed to support future episode downloads. Placeholders or refactors may be added to ensure extensibility for downloads and advanced offline features.


Our goal: best-in-class reliability, offline support, and user experience for a modern podcasting app. We will deliver this in safe, testable stages:

**Stage 1: Local Caching**
- Implement cache-first podcast feed loading (Hive/SharedPreferences)
- Background refresh updates cache after initial load
- *Test:* Simulate network loss, verify cached data loads and refreshes

---

### Hive Caching & Offline Experience (May 2025)

**Current Implementation:**
- Hive is now used for robust local storage of podcasts and episodes.
- The app uses a cache-first strategy: loads instantly from cache, refreshes in the background when online.
- On first run, podcasts and episodes are fetched from the network and cached.
- On subsequent runs (including offline), podcasts and episodes are loaded from cache.
- If images are not available offline, a default image is shown for podcasts and episodes.
- The player and episode screens work offline as long as audio is available (streaming requires network unless download/caching is added).

**Known Limitations:**
- Images are not cached and will not display offline (default/fallback image shown).
- Audio playback will not work offline unless the audio file is downloaded/cached (future feature).
- No explicit user feedback for network errors or offline state yet.

**Next Steps:**
- Add user feedback for network errors (banners, snackbars, dialogs). *(Partially addressed: Standardized "No Connection" SnackBar implemented for playback attempts)*
- Provide retry options for failed network requests or playback. *(Addressed: "Retry" button on the "No Connection" SnackBar for playback attempts)*
- Consider audio download/caching for true offline playback.
- Improve image caching (e.g., using cached_network_image).
- Enhance UI/UX: mini-player, episode queue, skip/seek controls, playback speed, sharing, and deep linking.

---

**Stage 2: Connectivity Monitoring**
- Integrate connectivity_plus for online/offline detection
- Show clear 'No Internet' messages and retry options *(Implemented for playback scenarios via standardized "No Connection" SnackBar with retry)*
- *Test:* Toggle connectivity, verify UI feedback and network checks

**Stage 3: Full Offline Support**
- Always show cached data when offline
- *Test:* Run app offline, verify full experience with cached data

**Stage 4: Advanced Error Handling**
- Categorize errors, provide user-friendly error/retry UI
- *Test:* Simulate various error conditions, verify user feedback and recovery

---

# Podcast App Network and Startup Optimization Plan

## Current Issues Identified

1. **Slow Initial Load Time**:
   - First-time podcast feed fetch takes ~3-4 seconds to complete
   - This delay only happens at startup, subsequent navigation is fast
   - Network request is the primary bottleneck (3.5+ seconds), not parsing (~0.5 seconds)

2. **Infinite Spinner Edge Case**:
   - In rare cases, the spinner runs forever and requires app restart
   - Likely causes: network request hanging, timeout not enforced, or unhandled exceptions

## Technical Approach

### 1. Robust Network Request Handling

```dart
Future<List<Podcast>> fetchPodcasts() async {
  try {
    // Add timeout to prevent hanging requests
    final response = await http.get(Uri.parse(kpfaFeedUrl))
        .timeout(const Duration(seconds: 10));
        
    if (response.statusCode != 200) {
      throw Exception('Failed to load feed: ${response.statusCode}');
    }
    
    // Parse and return podcast data...
    
  } on TimeoutException {
    // Handle timeout specifically
    throw PodcastException('Network request timed out');
  } catch (e) {
    // Categorize and handle different errors
    throw PodcastException('Error fetching podcasts: $e');
  }
}
```

### 2. Persistent Caching for Offline & Fast Startup

Implement local caching of feed data using either:
- **SharedPreferences** (simple solution)
- **Hive** (recommended structured NoSQL)
- **SQLite** (via sqflite for more complex data)

Example implementation:

```dart
Future<List<Podcast>> fetchPodcastsWithCache() async {
  // Try to load from cache first
  final cachedData = await _loadFromCache();
  if (cachedData != null) {
    // Trigger network refresh in the background
    _refreshCacheInBackground();
    return cachedData;
  }

  // No cache, do network fetch
  return await _fetchFromNetwork();
}
```

### 3. HomeScreen UI Improvements

Convert to StatefulWidget with proper error handling:

```dart
// Improved FutureBuilder implementation
FutureBuilder<List<Podcast>>(
  future: _podcastFuture,
  builder: (context, snapshot) {
    // Show loading indicator if still fetching
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading podcasts...', 
                 style: TextStyle(fontFamily: 'Oswald')),
          ],
        ),
      );
    }

    // Handle error state
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            Text('Unable to load podcasts',
                 style: TextStyle(fontFamily: 'Oswald')),
            ElevatedButton(
              onPressed: () => setState(() {
                _podcastFuture = apiService.fetchPodcastsWithCache();
              }),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Handle empty data
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text('No podcasts available',
                 style: TextStyle(fontFamily: 'Oswald')),
      );
    }

    // Show podcast list on success
    final podcasts = snapshot.data!;
    return _buildPodcastList(podcasts);
  },
)
```

### 4. Network Connectivity Monitoring

Add network connectivity monitoring using `connectivity_plus` package:

```dart
// Check connectivity before making network requests
Future<bool> hasNetworkConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
```

## Implementation Plan

### Phase 1: Core Reliability
1. Add proper timeout to all network requests
2. Implement robust error handling with specific error types
3. Create basic shared preferences caching

### Phase 2: Enhanced User Experience
4. Improve UI feedback with better loading states
5. Add retry functionality with exponential backoff
6. Implement connectivity monitoring

### Phase 3: Performance Optimization
7. Add advanced caching with background refresh
8. Implement splash screen with preloading
9. Add analytics to track and improve network performance

## Expected Outcomes

- **Initial load**: Instant load from cache, background refresh
- **Offline support**: App usable without network connection
- **Error resilience**: No infinite spinners, clear failure messages
- **User control**: Retry buttons on network failures
- **Performance metrics**: Track and optimize network performance

This plan addresses both the slow initial load and the infinite spinner issue while following Flutter best practices for network handling and UI reactivity.
