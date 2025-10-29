import 'package:flutter/material.dart';
import 'package:mirai_tv/api/anilist.dart';
import 'package:mirai_tv/widgets/anime_section.dart';

class HomePage extends StatefulWidget {
  final AnilistAPI anilistApi;

  const HomePage({super.key, required this.anilistApi});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showAuthInput = false;
  final TextEditingController _authCodeController = TextEditingController();

  Future<void> _handleRefresh() async {
    // Trigger a rebuild which will reload all anime sections
    setState(() {});
    // Add a small delay to simulate refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    var isAuthenticated = widget.anilistApi.isAuthenticated();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.redAccent,
      backgroundColor: Colors.grey[900],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue Watching Section with Login
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isAuthenticated && !_showAuthInput) ...[
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.anilistApi.authenticate();
                          setState(() => _showAuthInput = true);
                        },
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Login with AniList',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (_showAuthInput) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _authCodeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Paste authorization code here',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          widget.anilistApi.setAccessToken(
                            _authCodeController.text.trim(),
                          );
                          setState(() {
                            _showAuthInput = false;
                            isAuthenticated = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (isAuthenticated) ...[
                    const SizedBox(height: 20),
                    AnimeSection(
                      title: 'Continue Watching',
                      showProgress: true,
                      fetchAnime: () => widget.anilistApi.getUserWatchlist(),
                      anilistApi: widget.anilistApi,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: AnimeSection(
                title: 'Trending Now',
                fetchAnime: () => widget.anilistApi.getTrendingAnime(),
                anilistApi: widget.anilistApi,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: AnimeSection(
                title: 'Top Rated',
                fetchAnime: () => widget.anilistApi.getTopRatedAnime(),
                anilistApi: widget.anilistApi,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: AnimeSection(
                title: 'Latest Releases',
                fetchAnime: () => widget.anilistApi.getLatestAnime(),
                anilistApi: widget.anilistApi,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
