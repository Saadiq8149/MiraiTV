import 'package:flutter/material.dart';
import 'package:mirai_tv/pages/anime_details.dart';
import 'package:mirai_tv/utils/types.dart';
import 'package:mirai_tv/widgets/anime_card.dart';
import 'package:mirai_tv/api/anilist.dart';
import 'dart:ui';

class AnimeSection extends StatelessWidget {
  final String title;
  final Future<List<Anime>> Function() fetchAnime;
  final AnilistAPI anilistApi;
  final bool showProgress;
  final bool showResumePosition;

  const AnimeSection({
    super.key,
    required this.title,
    required this.fetchAnime,
    this.showProgress = false,
    this.showResumePosition = false,
    required this.anilistApi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: FutureBuilder<List<Anime>>(
            future: fetchAnime(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No anime found',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final animeList = snapshot.data!;
              return ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: animeList.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 200,
                      child: FutureBuilder<String?>(
                        future: showResumePosition
                            ? anilistApi.getFormattedWatchPosition(
                                animeList[index].id,
                              )
                            : Future.value(null),
                        builder: (context, resumeSnapshot) {
                          return AnimeCard(
                            showProgress: showProgress,
                            anime: animeList[index],
                            resumePosition: resumeSnapshot.data,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnimeDetailPage(
                                    animeId: animeList[index].id,
                                    anilistApi: anilistApi,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
