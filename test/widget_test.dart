// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_app/main.dart';


import 'package:podcast_app/core/services/audio_handler.dart';

class MockPodcastAudioHandler extends PodcastAudioHandler {
  MockPodcastAudioHandler() : super();
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Provide a dummy handler for testing
    await tester.pumpWidget(PodcastApp(audioHandler: MockPodcastAudioHandler()));
    // The rest of the test is default and can be updated for your app's widgets.
  });
}
