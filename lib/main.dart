import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/audio_provider.dart';
import 'core/services/audio_handler.dart';
import 'ui/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await initPodcastAudioHandler() as PodcastAudioHandler;
  runApp(PodcastApp(audioHandler: audioHandler));
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: GoogleFonts.roboto().fontFamily,
        ),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

