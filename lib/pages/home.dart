import 'package:flutter/material.dart';
import 'package:mirai_tv/api/anilist.dart';
import 'package:mirai_tv/widgets/anime_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AnilistAPI anilistAPI = AnilistAPI();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          AnimeSection(
            title: 'Continue Watching',
            fetchAnime: () => anilistAPI.searchAnime("naruto"),
          ),
          const SizedBox(height: 24),
          AnimeSection(
            title: 'Trending Now',
            fetchAnime: () => anilistAPI.searchAnime("naruto"),
          ),
          const SizedBox(height: 24),
          AnimeSection(
            title: 'Top Rated',
            fetchAnime: () => anilistAPI.searchAnime("naruto"),
          ),
          const SizedBox(height: 24),
          AnimeSection(
            title: 'Currently Airing',
            fetchAnime: () => anilistAPI.searchAnime("naruto"),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
