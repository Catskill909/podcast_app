import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../widgets/app_scaffold.dart';
import '../screens/podcast_detail_screen.dart';
import '../screens/player_screen.dart';
import '../../core/models/podcast.dart';
import '../../core/models/episode.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const AppScaffold(child: HomeScreen()));
      case '/podcast':
        final podcast = settings.arguments as Podcast;
        return MaterialPageRoute(
          builder: (_) => AppScaffold(
              showMiniPlayer: true,
              child: PodcastDetailScreen(podcast: podcast)),
        );
      case '/player':
        final episode = settings.arguments as Episode;
        return MaterialPageRoute(
          builder: (_) => AppScaffold(
              showMiniPlayer: false, child: PlayerScreen(episode: episode)), 
        );
      default:
        return MaterialPageRoute(
          builder: (_) => AppScaffold(
            child: Scaffold(
              body:
                  Center(child: Text('No route defined for ${settings.name}')),
            ),
          ),
        );
    }
  }
}
