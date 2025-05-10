import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/podcast_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PodcastApiService _apiService = PodcastApiService();
  
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }
  
  Future<void> _initializeAppAndNavigate() async {
    // Start loading data immediately on app startup
    try {
      // This will either load from cache and trigger a background refresh,
      // or fetch from network if cache is empty
      await _apiService.fetchPodcasts();
    } catch (e) {
      // If there's an error, we'll still navigate to home screen
      // where the error handling UI will be shown
    }
    
    // Ensure we show splash for at least 2 seconds for branding purposes
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/icon.png',
          width: width * 0.5, // 50% of screen width for smooth transition
        ),
      ),
    );
  }
}
