# KPFA News Feed Integration Plan

## 1. App Structure Review

Your podcast app is a modern, minimalist Flutter app with:
- Modular architecture: services, models, providers, screens, widgets
- Podcast/Episode data models in `lib/core/models/`
- API abstraction in `lib/core/services/podcast_api_service.dart`
- UI: Home, Podcast Detail, Player, MiniPlayer
- State management via Provider
- Minimalist dark theme, Oswald for headers, CircleAvatar for covers, border decorations with transparency

## 2. KPFA Feed Structure (RSS 2.0 w/ iTunes extensions)

### Channel (Podcast-level)
- `title`: KPFA - The Pacifica Evening News, Weekdays
- `link`: https://kpfa.org/program/the-pacifica-evening-news-weekdays/
- `language`: en-us
- `copyright`: 2025KPFA 312700
- `itunes:type`: episodic
- `itunes:author`: KPFA
- `itunes:subtitle`: M-F 6pm
- `itunes:summary`/`description`: Show summary
- `itunes:owner`: name/email
- `itunes:category`: News > Politics
- `itunes:explicit`: clean
- `itunes:image`: Podcast cover (may be empty)

### Item (Episode-level)
- `title`: Episode title (e.g., "Trump nominates Mike Waltz as UN ambassador – May 1, 2025")
- `description`/`itunes:summary`: Episode summary (HTML, may include news rundown)
- `content:encoded`: Full HTML content (may include images, links, rundown)
- `itunes:author`: KPFA
- `itunes:image`: Episode image
- `enclosure`: url (audio mp3), length, type
- `guid`: Unique episode ID
- `pubDate`: Publication date
- `itunes:duration`: Duration (e.g., 59:58)
- `itunes:explicit`: clean

## 3. View Model Proposal

### Podcast Model (Channel)
- id (guid or URL)
- title
- author
- subtitle
- summary/description
- imageUrl
- language
- copyright
- category
- explicit

### Episode Model
- id (guid)
- title
- summary/description
- contentHtml
- imageUrl
- audioUrl
- audioLength
- audioType
- pubDate
- duration
- explicit

## 4. Step-by-Step Integration Plan

### Step 1: Model Extensions
- Extend existing Podcast/Episode models (or subclass) to support:
  - `subtitle`, `itunes:summary`, `itunes:image`, `enclosure`, `content:encoded`

### Step 2: Feed Parsing
- Add RSS (and iTunes) parsing logic to PodcastApiService
- Use `xml` package for parsing
- Map channel/item fields to view models
- Handle HTML in summaries/content
- Fallback to default image if missing

### Step 3: API Service
- Add a method to fetch and parse the KPFA feed URL
- Return a Podcast object with Episode list

### Step 4: UI Integration
- Add KPFA as a podcast in the browser/home screen
- Show episodes with titles, dates, images, and summaries
- Use CircleAvatar for images, Oswald for headers, 8px spacing, dark theme
- Play audio using existing player

### Step 5: Testing
- Validate parsing with multiple episodes
- Check for missing fields, broken images, audio links

### Step 6: Polish
- Ensure full dark theme compliance
- Add subtle border decorations and transparency to match app style

---

## Example: KPFA Episode (Parsed)
```
title: Trump nominates Mike Waltz as UN ambassador – May 1, 2025
description: ...
contentHtml: ...
audioUrl: https://archives.kpfa.org/data/20250501-Thu1800.mp3
imageUrl: https://kpfa.org/app/uploads/2025/05/AP25121535541884-scaled.jpg
pubDate: Thu, 01 May 2025 18:00:00 +0000
duration: 59:58
explicit: clean
```

---

## References
- [KPFA Feed](https://kpfa.org/program/the-pacifica-evening-news-weekdays/feed/)
- [Flutter xml package](https://pub.dev/packages/xml)
- [Podcast app README](./README.md)

---

This plan ensures the KPFA feed is integrated cleanly, matches your app’s style, and is robust to feed variations. Ready for implementation!
