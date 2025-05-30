import 'package:flutter/material.dart';
import '../services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import '../models/episode.dart';

class AudioProvider extends ChangeNotifier {
  late final PodcastAudioHandler audioHandler;
  Episode? _currentEpisode;
  Episode? get currentEpisode => _currentEpisode;

  // Listen to handler state and notify listeners
  void init(PodcastAudioHandler handler) {
    audioHandler = handler;
    audioHandler.playbackState.listen((_) => notifyListeners());
    audioHandler.mediaItem.listen((_) => notifyListeners());
  }

  void setCurrentEpisode(Episode episode) async {
    _currentEpisode = episode;
    // Create a MediaItem for audio_service
    final mediaItem = MediaItem(
      id: episode.audioUrl,
      title: episode.title,
      album: '',
      artist: '',
      duration: episode.duration,
      artUri: Uri.parse(episode.podcastImageUrl),
      extras: {'episodeId': episode.id},
    );
    // Changed from playMediaItem to loadMediaItem to prevent auto-play
    await audioHandler.loadMediaItem(mediaItem);
    notifyListeners();
  }

  void play() => audioHandler.play();
  void pause() => audioHandler.pause();
  void seek(Duration position) => audioHandler.seek(position);
  void stop() => audioHandler.stop();

  bool get isPlaying => audioHandler.playbackState.value.playing;
  Duration get position => audioHandler.playbackState.value.updatePosition;
  // Expose a stream of the current playback position for real-time tracking
  Stream<Duration> get positionStream => audioHandler.player.positionStream;

  // Expose if playback is completed and at end
  bool get isCompleted {
    final state = audioHandler.playbackState.value;
    final media = audioHandler.mediaItem.value;
    return state.processingState == AudioProcessingState.completed ||
      (media != null && position >= (media.duration ?? Duration.zero) && !isPlaying);
  }

}
