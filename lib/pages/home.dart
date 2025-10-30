import 'package:flutter/material.dart';
import 'dart:io' show Platform;
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
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Top Bar with Logo and Controls

                // Divider line
                // Content
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Continue Watching Section with Login
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Logo and Title
                            SizedBox(
                              height: 50,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Mirai',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'TV',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Logout Button (only show if authenticated)
                            if (isAuthenticated)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await widget.anilistApi.clearAccessToken();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
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
                                  icon: const Icon(
                                    Icons.login,
                                    color: Colors.white,
                                  ),
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
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 32, 25, 25),
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
                                showResumePosition: true,
                                fetchAnime: () =>
                                    widget.anilistApi.getUserWatchlist(),
                                anilistApi: widget.anilistApi,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: AnimeSection(
                          title: 'Planning',
                          fetchAnime: () =>
                              widget.anilistApi.getUserPlanningList(),
                          anilistApi: widget.anilistApi,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: AnimeSection(
                          title: 'Trending Now',
                          fetchAnime: () =>
                              widget.anilistApi.getTrendingAnime(),
                          anilistApi: widget.anilistApi,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: AnimeSection(
                          title: 'Top Rated',
                          fetchAnime: () =>
                              widget.anilistApi.getTopRatedAnime(),
                          anilistApi: widget.anilistApi,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: AnimeSection(
                          title: 'Latest Releases',
                          fetchAnime: () => widget.anilistApi.getLatestAnime(),
                          anilistApi: widget.anilistApi,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Refresh Button - Top Right (Windows only)
          if (Platform.isWindows)
            Positioned(
              top: 76,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                onPressed: _handleRefresh,
                tooltip: 'Refresh content',
              ),
            ),
        ],
      ),
    );
  }
}
