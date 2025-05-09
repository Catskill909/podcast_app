import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import 'package:provider/provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/providers/connectivity_provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../widgets/mini_player.dart'; // Import for buildNoConnectionSnackBar

class PlayerScreen extends StatefulWidget {
  final Episode episode;
  const PlayerScreen({super.key, required this.episode});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioProvider audioProvider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      audioProvider = Provider.of<AudioProvider>(context, listen: false);
      if (audioProvider.currentEpisode?.id != widget.episode.id) {
        audioProvider.setCurrentEpisode(widget.episode);
      }
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Pacifica Evening News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              final shareText = '''
${widget.episode.title}

Listen or read more: ${widget.episode.id}

Podcast image: ${widget.episode.podcastImageUrl}
''';
              Share.share(
                shareText,
                subject: widget.episode.title,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                        child: (widget.episode.imageUrl.isNotEmpty)
                            ? Image.network(
                                widget.episode.imageUrl,
                                width: MediaQuery.of(context).size.width,
                                height: 240,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/pacifica-news.png',
                                width: MediaQuery.of(context).size.width,
                                height: 240,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 32,
                        child: Text(
                          widget.episode.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Oswald',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                            shadows: const [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black87,
                                offset: Offset(0, 2),
                              ),
                              Shadow(
                                blurRadius: 16,
                                color: Colors.black54,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Consumer<AudioProvider>(
                    builder: (context, audioProvider, child) {
                      final mediaItem = audioProvider.audioHandler.mediaItem.value;
                      final totalDuration = mediaItem?.duration ?? Duration.zero;
                      final sliderMax = totalDuration.inSeconds.toDouble();

                      return StreamBuilder<Duration>(
                        stream: audioProvider.positionStream,
                        initialData: audioProvider.position,
                        builder: (context, snapshot) {
                          final isCompleted = audioProvider.isCompleted;
                          final position = isCompleted ? Duration.zero : (snapshot.data ?? Duration.zero);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Slider(
                                  value: position.inSeconds.toDouble().clamp(0.0, sliderMax),
                                  min: 0,
                                  max: sliderMax > 0 ? sliderMax : 1.0,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                  thumbColor: Colors.white,
                                  onChanged: (value) {
                                    audioProvider.seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(position)),
                                    Text(_formatDuration(totalDuration)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay_10),
                                      iconSize: 36,
                                      onPressed: () {
                                        audioProvider.seek(position - const Duration(seconds: 10));
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        audioProvider.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      iconSize: 56,
                                      onPressed: () {
                                        final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
                                        if (!audioProvider.isPlaying) {
                                          if (connectivityProvider.status == NetworkStatus.offline) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              buildNoConnectionSnackBar(
                                                context,
                                                widget.episode.title,
                                                () {
                                                  final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
                                                  final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                                  if (connectivityProvider.status != NetworkStatus.offline) {
                                                    audioProvider.setCurrentEpisode(widget.episode);
                                                    audioProvider.play();
                                                  } else {
                                                    // Still offline. User can tap retry on SnackBar again or main play button.
                                                    // No need to show another SnackBar from here.
                                                  }
                                                },
                                              ),
                                            );
                                          } else {
                                            audioProvider.play();
                                          }
                                        } else {
                                          audioProvider.pause();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.forward_10),
                                      iconSize: 36,
                                      onPressed: () { audioProvider.seek(position + const Duration(seconds: 10)); }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ); // Closes Padding for Slider/Controls
                        }, // Closes StreamBuilder builder
                      ); // Closes StreamBuilder
                    }, // Closes Consumer builder
                  ), // Closes Consumer
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SingleChildScrollView(
                        child: Html(
                          data: _styledHtmlContent(
                            widget.episode.contentHtml?.isNotEmpty == true
                                ? widget.episode.contentHtml!
                                : widget.episode.description,
                          ),
                          style: {
                            "body": Style(
                              color: Colors.white.withAlpha(220),
                              fontSize: FontSize(13),
                              fontFamily: 'Oswald',
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "ul": Style(margin: Margins.only(left: 12)),
                            "ol": Style(margin: Margins.only(left: 12)),
                          }, // Close the style map for Html
                        ),   // Close Html()
                      ),     // Close SingleChildScrollView()
                    ),       // Close Padding() for Html content
                  ),         // Close Expanded() for the Html content section
                ], // Closes children of the main Column
              )   // Closes main Column
            )     // Closes SafeArea
    ); // Closes Scaffold body
  } // Closes build method

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Removes <a> and <img> tags but keeps all other HTML and inner text.
  String _stripLinksAndImages(String html) {
    final document = html_parser.parse(html);
    // Remove all <img> tags
    document.querySelectorAll('img').forEach((img) => img.remove());
    // Replace <a> tags with their inner text
    document.querySelectorAll('a').forEach((a) {
      final text = a.text;
      final textNode = dom.Text(text);
      a.replaceWith(textNode);
    });
    return document.body?.innerHtml ?? html;
  }

  /// Prepends a <style> tag to force minimal list indentation.
  String _styledHtmlContent(String html) {
    const htmlListStyle = '''
<style>
ul, ol { margin-left: 8px !important; padding-left: 8px !important; }
li { margin-left: 0 !important; padding-left: 0 !important; }
</style>
''';
    return htmlListStyle + _stripLinksAndImages(html);
  }
}
