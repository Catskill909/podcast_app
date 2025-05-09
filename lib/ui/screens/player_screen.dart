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
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withAlpha(204)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.4, 1.0], // Gradient starts at 40% from the top
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32, // 16px padding on each side
                          child: Text(
                            widget.episode.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontFamily: 'Oswald',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay_10),
                                      iconSize: 36,
                                      color: Colors.white70,
                                      onPressed: () { audioProvider.seek(position - const Duration(seconds: 10)); }
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 30, // iconSize is 48
                                      child: IconButton(
                                        padding: EdgeInsets.zero, 
                                        constraints: const BoxConstraints(), 
                                        icon: Icon(audioProvider.isPlaying ? Icons.pause : Icons.play_arrow),
                                        iconSize: 48,
                                        color: Colors.black, // Icon color
                                        onPressed: () {
                                          final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
                                          if (!audioProvider.isPlaying) {
                                            if (connectivityProvider.status == NetworkStatus.offline) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                buildNoConnectionSnackBar(
                                                  context,
                                                  widget.episode.title,
                                                  () {
                                                    if (connectivityProvider.status != NetworkStatus.offline) {
                                                      audioProvider.setCurrentEpisode(widget.episode);
                                                      audioProvider.play(); 
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
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.forward_10),
                                      iconSize: 36,
                                      color: Colors.white70,
                                      onPressed: () { audioProvider.seek(position + const Duration(seconds: 10)); }
                                    ),
                                  ],
                                ),
                                if (totalDuration > Duration.zero) ...[
                                  const SizedBox(height: 12), 
                                  Slider(
                                    value: position.inSeconds.toDouble().clamp(0.0, sliderMax),
                                    min: 0.0,
                                    max: sliderMax > 0 ? sliderMax : 1.0,
                                    onChanged: (value) {
                                      audioProvider.seek(Duration(seconds: value.toInt()));
                                    },
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10), 
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDuration(position), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text(_formatDuration(totalDuration), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ); 
                        }, 
                      ); 
                    }, 
                  ), 
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
                          }, 
                        ),   
                      ),     
                    ),       
                  ),         
                ], 
              )   
            )     
    ); // Closes Scaffold body
  } // Closes build method

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _stripLinksAndImages(String html) {
    final document = html_parser.parse(html);
    document.querySelectorAll('img').forEach((img) => img.remove());
    document.querySelectorAll('a').forEach((a) {
      final text = a.text;
      final textNode = dom.Text(text);
      a.replaceWith(textNode);
    });
    return document.body?.innerHtml ?? html;
  }

  String _styledHtmlContent(String html) {
    const htmlListStyle = '''
<style>
ul, ol { margin-left: 8px !important; padding-left: 8px !important; }
li { margin-left: 0 !important; padding-left: 0 !important; }
</style>
''';
    return htmlListStyle + _stripLinksAndImages(html);
  }
} // Closes _PlayerScreenState class
