import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mirai_tv/api/anicli.dart';
import 'package:mirai_tv/api/anilist.dart';
import 'package:mirai_tv/utils/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String showId;
  final String episodeNumber;
  final Anime anime;
  final AnilistAPI anilistAPI;
  final VoidCallback? onNextEpisode;

  const InlineVideoPlayer({
    super.key,
    required this.showId,
    required this.episodeNumber,
    required this.anime,
    required this.anilistAPI,
    this.onNextEpisode,
  });

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  static const String agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0";
  static const String allanimeRefr = "https://allmanga.to";

  Player? _player;
  VideoController? _controller;
  List<Map<String, String>> _sources = [];
  Map<String, String>? _currentSource;
  bool _loading = true;
  bool _isDisposed = false;
  bool _progressUpdated = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadEpisode();
  }

  @override
  void didUpdateWidget(InlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload episode when episodeNumber changes
    if (oldWidget.episodeNumber != widget.episodeNumber) {
      _progressUpdated = false;
      _loadEpisode();
    }
  }

  String _getTimestampKey() => 'watch_timestamp_${widget.anime.id}';
  String _getLastWatchedKey() => 'last_watched_${widget.anime.id}';

  Future<void> _saveTimestamp(Duration position) async {
    await _prefs.setInt(_getTimestampKey(), position.inMilliseconds);
    await _prefs.setInt(
      _getLastWatchedKey(),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<Duration?> _loadSavedTimestamp() async {
    final savedMs = _prefs.getInt(_getTimestampKey());
    return savedMs != null ? Duration(milliseconds: savedMs) : null;
  }

  Future<void> _clearTimestamp() async {
    await _prefs.remove(_getTimestampKey());
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
      httpHeaders: {
        'User-Agent': source['user-agent'] ?? agent,
        'Referer': source['referrer'] ?? allanimeRefr,
      },
    );

    await _player!.open(media);

    // Resume from saved timestamp if available
    final savedPosition = await _loadSavedTimestamp();

    // Wait for player and video to be fully loaded before seeking
    if (savedPosition != null && savedPosition.inSeconds > 0) {
      while (_player!.state.duration.inMilliseconds <= 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      try {
        await _player!.seek(savedPosition);
      } catch (e) {
        print('Error seeking: $e');
      }
    }

    // Listen for playback completion
    _player!.stream.completed.listen((completed) {
      if (completed && mounted) {
        _handleEpisodeComplete();
      }
    });

    // Listen for playback position to update progress at 80% and save timestamp
    _player!.stream.position.listen((position) async {
      if (_player != null && _player!.state.duration.inMilliseconds > 0) {
        final progress =
            (position.inMilliseconds / _player!.state.duration.inMilliseconds);

        // Save timestamp every 10 seconds
        if (position.inSeconds % 10 == 0 && !_progressUpdated) {
          await _saveTimestamp(position);
        }

        // Update progress when 80% is reached
        if (progress >= 0.8 && !_progressUpdated) {
          _progressUpdated = true;

          if (widget.anime.userStatus == "COMPLETED") {
            widget.anilistAPI.updateAnime(
              widget.anime.id,
              "REPEATING",
              int.parse(widget.episodeNumber),
            );
          } else if (widget.anime.userStatus == "PLANNING") {
            widget.anilistAPI.updateAnime(
              widget.anime.id,
              "CURRENT",
              int.parse(widget.episodeNumber),
            );
          } else if (widget.anime.userStatus == "CURRENT" &&
              widget.episodeNumber == widget.anime.episodes.toString()) {
            widget.anilistAPI.updateAnime(
              widget.anime.id,
              "COMPLETED",
              int.parse(widget.episodeNumber),
            );
          }

          await _clearTimestamp();
        }
      }
    });

    // Load subtitles if available
    final subtitleUrl = source['subtitles'];
    if (subtitleUrl != null && subtitleUrl.isNotEmpty) {
      await _loadSubtitles(subtitleUrl);
    }
  }

  Future<void> _handleEpisodeComplete() async {
    // Clear timestamp when episode is completed
    await _clearTimestamp();
    _handleNextEpisode();
  }

  Future<void> _loadSubtitles(String subtitleUrl) async {
    try {
      await _player?.setSubtitleTrack(
        SubtitleTrack.uri(subtitleUrl, title: 'English', language: 'en'),
      );
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
    final savedPosition = await _loadSavedTimestamp();

    // Wait for player and video to be fully loaded before seeking
    if (savedPosition != null && savedPosition.inSeconds > 0) {
      while (_player!.state.duration.inMilliseconds <= 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      try {
        await _player!.seek(savedPosition);
      } catch (e) {
        print('Error seeking: $e');
      }
    }

    // Load subtitles if available
    final subtitleUrl = newSource['subtitles'];
    if (subtitleUrl != null && subtitleUrl.isNotEmpty) {
      await _loadSubtitles(subtitleUrl);
    }
  }

  void _handleNextEpisode() {
    _progressUpdated = false;
    widget.onNextEpisode?.call();
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

    return Container(
      color: darkBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video Player
          if (_loading)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator(color: redAccent)),
            )
          else if (_controller != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Video(
                controller: _controller!,
                controls: AdaptiveVideoControls,
              ),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: const Center(
                child: CircularProgressIndicator(color: redAccent),
              ),
            ),
          // Controls Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Episode Info
                Text(
                  'Episode ${widget.episodeNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // Quality Selector and Next Episode Button
                Row(
                  children: [
                    const Text(
                      "Quality: ",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                                    fontSize: 12,
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
                      onPressed: _handleNextEpisode,
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
