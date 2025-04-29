import 'package:flutter/material.dart';
import 'ui/navigation/app_router.dart';
import 'package:provider/provider.dart';
import 'core/providers/audio_provider.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const PodcastApp());
}

// AppScaffold moved to its own file

class PodcastApp extends StatelessWidget {
  const PodcastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioProvider(),
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

