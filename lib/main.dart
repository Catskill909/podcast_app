import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/audio_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/services/audio_handler.dart';
import 'core/models/podcast.dart';
import 'core/models/episode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/duration_adapter.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/podcast_detail_screen.dart';
import 'ui/screens/player_screen.dart';
import 'ui/widgets/app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(PodcastAdapter());
  Hive.registerAdapter(EpisodeAdapter());
  await Hive.openBox<Podcast>('podcasts');
  await Hive.openBox('app_settings');
  final audioHandler = await initPodcastAudioHandler() as PodcastAudioHandler;
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConnectivityProvider(),
      child: PodcastApp(audioHandler: audioHandler),
    ),
  );
}


// AppScaffold moved to its own file

class PodcastApp extends StatelessWidget {
  final PodcastAudioHandler audioHandler;
  const PodcastApp({required this.audioHandler, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = AudioProvider();
        provider.init(audioHandler);
        return provider;
      },
      child: MaterialApp(
        title: 'Podcast App',
        // Light theme
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.nunitoTextTheme().copyWith(
            titleLarge: GoogleFonts.oswald(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
            titleMedium: GoogleFonts.oswald(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            // Consider adding default background color or contentTextStyle if desired globally
          ),
        ),
        // Dark theme
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          textTheme:
              GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
            titleLarge: GoogleFonts.oswald(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.oswald(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            // Consider default background color for dark theme if different
            // backgroundColor: Colors.grey[800], 
            // contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        themeMode: ThemeMode.system, // Follows system setting for light/dark
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const AppScaffold(child: HomeScreen()),
          '/podcast': (context) {
            final podcast =
                ModalRoute.of(context)!.settings.arguments as Podcast;
            return AppScaffold(
                showMiniPlayer: true,
                child: PodcastDetailScreen(podcast: podcast));
          },
          '/player': (context) {
            final episode =
                ModalRoute.of(context)!.settings.arguments as Episode;
            return AppScaffold(
                showMiniPlayer: false, child: PlayerScreen(episode: episode));
          },
        },
        // onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
