import 'package:flutter/material.dart';
import 'package:mirai_tv/api/anilist.dart';
import 'package:mirai_tv/api/anicli.dart';
import 'package:mirai_tv/pages/video_player.dart';
import 'package:mirai_tv/utils/types.dart';

class AnimeDetailPage extends StatefulWidget {
  final int animeId;
  final AnilistAPI anilistApi;

  const AnimeDetailPage({
    super.key,
    required this.animeId,
    required this.anilistApi,
  });

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final AnicliAPI _anicliApi = AnicliAPI();
  Anime? _anime;
  String? _showId;
  bool _isLoading = true;

  // Pagination and search
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAnime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadAnime() async {
    try {
      final anime = await widget.anilistApi.getAnimeById(widget.animeId);

      // Fetch show ID from AnicliAPI
      String? showId;
      if (anime != null) {
        final result = await _anicliApi.getAnimeByAnilistId(
          anime.id.toString(),
          anime.title,
        );
        showId = result?['id'] as String?;
      }

      setState(() {
        _anime = anime;
        _showId = showId;
        _isLoading = false;
      });
    } catch (e) {
      print('[DEBUG] Error loading anime: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
          ),
        ),
      );
    }

    if (_anime == null) {
      return const Center(child: Text('Failed to load anime'));
    }

    final anime = _anime!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner with gradient overlay and cover/title overlay
            Stack(
              children: [
                // Banner Image
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: anime.bannerUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(anime.bannerUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[800],
                  ),
                  child: anime.bannerUrl.isEmpty
                      ? const Icon(Icons.image, size: 80, color: Colors.grey)
                      : null,
                ),
                // Translucent black gradient overlay (top to bottom)
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Cover Image, Title and Stats
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left Side - Cover Image and Play Button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cover Image
                          Container(
                            height: 180,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: anime.thumbnailUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(anime.thumbnailUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[700],
                            ),
                            child: anime.thumbnailUrl.isEmpty
                                ? const Icon(Icons.image, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          // Play Button
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_showId != null) {
                                  int episodeToPlay = anime.progress + 1;
                                  if (episodeToPlay > anime.episodes) {
                                    episodeToPlay = anime.episodes;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AnimeVideoPlayer(
                                        animeId: anime.id,
                                        showId: _showId!,
                                        episodeNumber: episodeToPlay.toString(),
                                        animeName: anime.title,
                                        anilistAPI: widget.anilistApi,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to load show ID'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size.fromHeight(52),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    anime.progress == 0
                                        ? 'Play'
                                        : 'Continue Ep ${anime.progress + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Right Side - Title and Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Title
                            Text(
                              anime.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Stats Row
                            Row(
                              children: [
                                // Rating
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${anime.rating}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Year
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${anime.year}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Episodes
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.subscriptions,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${anime.episodes}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Watch Status Badges
            if (anime.userStatus != 'None') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Status Badge
                    _buildStatusBadge(anime.userStatus),
                    const SizedBox(width: 12),
                    // Progress Display
                    if (anime.episodes > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${anime.progress}/${anime.episodes}',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Genres
            if (anime.genres.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: anime.genres
                      .map(
                        (genre) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            border: Border.all(color: Colors.redAccent),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description
            if (anime.description.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  anime.description
                      .replaceAll('<br>', '')
                      .replaceAll('<i>', '')
                      .replaceAll('</i>', ''),
                  style: TextStyle(
                    color: Colors.grey[300],
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Episode List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Episodes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 1; // Reset to first page on search
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search episodes...',
                  prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _currentPage = 1;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Episode List with Pagination
            _buildEpisodeList(anime),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeList(Anime anime) {
    List<int> episodes = List.generate(anime.episodes, (index) => index + 1);

    if (_searchQuery.isNotEmpty) {
      episodes = episodes
          .where((ep) => ep.toString().contains(_searchQuery))
          .toList();
    }

    // Calculate pagination
    final totalPages = (episodes.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, episodes.length);
    final paginatedEpisodes = episodes.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Episode items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedEpisodes.length,
          itemBuilder: (context, index) {
            final episodeNumber = paginatedEpisodes[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  if (_showId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AnimeVideoPlayer(
                          animeId: anime.id,
                          showId: _showId!,
                          episodeNumber: episodeNumber.toString(),
                          animeName: anime.title,
                          anilistAPI: widget.anilistApi,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to load show ID')),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Episode Thumbnail
                      Container(
                        width: 180,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.grey[600],
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Episode Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Episode $episodeNumber',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Episode $episodeNumber',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Play Icon
                      Icon(
                        Icons.play_circle_filled,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Pagination controls
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                          _scrollToTop();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.redAccent,
                  disabledColor: Colors.grey[700],
                ),
                const SizedBox(width: 16),
                // Page indicator
                Text(
                  'Page $_currentPage of $totalPages',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                // Next button
                IconButton(
                  onPressed: _currentPage < totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          _scrollToTop();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  color: Colors.redAccent,
                  disabledColor: Colors.grey[700],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    late Color badgeColor;
    late String displayText;

    switch (status) {
      case 'CURRENT':
        badgeColor = Colors.blueAccent;
        displayText = 'Currently watching';
        break;
      case 'PLANNING':
        badgeColor = Colors.purpleAccent;
        displayText = 'Planning to watch';
        break;
      case 'COMPLETED':
        badgeColor = Colors.greenAccent;
        displayText = 'Finished watching';
        break;
      default:
        badgeColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
