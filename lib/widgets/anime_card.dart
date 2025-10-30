import 'package:flutter/material.dart';
import 'package:mirai_tv/utils/types.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final bool showProgress;
  final String? resumePosition;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onTap,
    this.showProgress = false,
    this.resumePosition,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  color: Colors.grey[800],
                  image: anime.thumbnailUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(anime.thumbnailUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    if (anime.thumbnailUrl.isEmpty)
                      const Icon(Icons.image, color: Colors.grey),
                    // Black translucent overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black12),
                      ),
                    ),
                    // Rating Badge Overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              anime.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Anime Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!showProgress) const Spacer(),
                    if (showProgress && anime.episodes > 0)
                      const SizedBox(height: 8),

                    if (!showProgress && resumePosition == null)
                      // Year & Episodes
                      Text(
                        '${anime.year} • ${anime.episodes} eps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (showProgress && anime.episodes > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: anime.progress / anime.episodes,
                          minHeight: 6,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            anime.progress >= anime.episodes
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            resumePosition != null
                                ? TextSpan(
                                    text: '${resumePosition}   ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : const TextSpan(),
                            TextSpan(
                              text: '${anime.progress} / ${anime.episodes} eps',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
