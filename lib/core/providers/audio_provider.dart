import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../models/episode.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  AudioService get audioService => _audioService;

  Episode? _currentEpisode;
  Episode? get currentEpisode => _currentEpisode;

  void setCurrentEpisode(Episode episode) {
    _currentEpisode = episode;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
