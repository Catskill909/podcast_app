import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// Custom AudioHandler for background audio, lockscreen controls, and metadata.
class PodcastAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  PodcastAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to playback events and broadcast state/metadata
    _player.playbackEventStream.listen(_broadcastState);
  }

  // Play a media item (episode)
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    await _player.setUrl(mediaItem.id);
    await _player.play();
  }

  // Load a media item without starting playback
  Future<void> loadMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    await _player.setUrl(mediaItem.id);
    // Note: _player.play() is intentionally omitted here
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  // Broadcast playback state and metadata
  void _broadcastState(_) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        playing: _player.playing,
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
    // Optionally: update mediaItem with position, etc.
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    queue.add([...queue.value, mediaItem]);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    queue.add(queue.value.where((item) => item.id != mediaItem.id).toList());
  }

  @override
  Future<void> skipToNext() async {
    // Implement skip logic if supporting playlists
  }

  @override
  Future<void> skipToPrevious() async {
    // Implement skip logic if supporting playlists
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> fastForward() async {
    final newPos = _player.position + const Duration(seconds: 30);
    await _player.seek(newPos);
  }

  @override
  Future<void> rewind() async {
    final newPos = _player.position - const Duration(seconds: 10);
    await _player.seek(newPos > Duration.zero ? newPos : Duration.zero);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Helper to register the handler at app startup
Future<AudioHandler> initPodcastAudioHandler() async {
  return await AudioService.init(
    builder: () => PodcastAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.podcast_app.channel.audio',
      androidNotificationChannelName: 'Podcast Playback',
      androidNotificationOngoing: true,
    ),
  );
}
