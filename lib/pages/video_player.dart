import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mirai_tv/api/anicli.dart';

class AnimeVideoPlayer extends StatefulWidget {
  final String showId;
  final String episodeNumber;
  final String animeName;

  const AnimeVideoPlayer({
    super.key,
    required this.showId,
    required this.episodeNumber,
    required this.animeName,
  });

  @override
  State<AnimeVideoPlayer> createState() => _AnimeVideoPlayerState();
}

class _AnimeVideoPlayerState extends State<AnimeVideoPlayer> {
  static const String agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0";
  static const String allanimeRefr = "https://allmanga.to";

  Player? _player;
  VideoController? _controller;
  List<Map<String, String>> _sources = [];
  Map<String, String>? _currentSource;
  bool _loading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadEpisode();
  }

  Future<void> _loadEpisode() async {
    final api = AnicliAPI();
    setState(() => _loading = true);
    try {
      final urls = await api.getEpisodeUrls(
        widget.showId,
        widget.episodeNumber,
      );
      if (urls == null || urls.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No video sources found")),
          );
        }
        return;
      }
      _sources = urls;
      _currentSource = _sources.first;
      await _setupPlayer(_currentSource!);
    } catch (e) {
      debugPrint("Error loading episode: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setupPlayer(Map<String, String> source) async {
    await _player?.dispose();
    _player = Player();
    _controller = VideoController(_player!);

    // Create media with HTTP headers
    final media = Media(
      source['url']!,
      httpHeaders: {'User-Agent': agent, 'Referer': allanimeRefr},
    );

    await _player!.open(media);

    // Listen for playback completion
    _player!.stream.completed.listen((completed) {
      if (completed && mounted) {
        _nextEpisode();
      }
    });

    // Load subtitles if available
    final subtitleUrl = source['subtitles'];
    if (subtitleUrl != null && subtitleUrl.isNotEmpty) {
      await _loadSubtitles(subtitleUrl);
    }
  }

  Future<void> _loadSubtitles(String subtitleUrl) async {
    try {
      await _player?.setSubtitleTrack(
        SubtitleTrack.uri(subtitleUrl, title: 'English', language: 'en'),
      );
      debugPrint('[DEBUG] Subtitles loaded: $subtitleUrl');
    } catch (e) {
      debugPrint('[DEBUG] Error loading subtitles: $e');
    }
  }

  Future<void> _changeSource(Map<String, String> newSource) async {
    if (_isDisposed) return;
    setState(() => _currentSource = newSource);

    // Create media with HTTP headers
    final media = Media(
      newSource['url']!,
      httpHeaders: {'User-Agent': agent, 'Referer': allanimeRefr},
    );

    await _player?.open(media, play: true);

    // Load subtitles if available
    final subtitleUrl = newSource['subtitles'];
    if (subtitleUrl != null && subtitleUrl.isNotEmpty) {
      await _loadSubtitles(subtitleUrl);
    }
  }

  void _nextEpisode() {
    final nextEpisodeNum = int.parse(widget.episodeNumber) + 1;
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AnimeVideoPlayer(
            showId: widget.showId,
            episodeNumber: nextEpisodeNum.toString(),
            animeName: widget.animeName,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const redAccent = Colors.redAccent;
    final darkBg = const Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        title: Text(
          "${widget.animeName} — Ep ${widget.episodeNumber}",
          style: const TextStyle(color: redAccent),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: redAccent))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _controller != null
                          ? Video(
                              controller: _controller!,
                              controls: AdaptiveVideoControls,
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: redAccent,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quality Selector and Next Episode Button
                          Row(
                            children: [
                              const Text(
                                "Quality: ",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Expanded(
                                child: DropdownButton<Map<String, String>>(
                                  isExpanded: true,
                                  dropdownColor: darkBg,
                                  value: _currentSource,
                                  items: _sources
                                      .map(
                                        (src) => DropdownMenuItem(
                                          value: src,
                                          child: Text(
                                            '${src['source']} - ${src['quality'] ?? "Unknown"}',
                                            style: const TextStyle(
                                              color: redAccent,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (src) {
                                    if (src != null) _changeSource(src);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _nextEpisode,
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: redAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Subtitle Info
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
