class Episode {
  String title;
  String thumbnailUrl;
  int episodeNumber;

  Episode({
    required this.title,
    required this.thumbnailUrl,
    required this.episodeNumber,
  });
}

class Anime {
  int id;
  int malId;
  String title;
  String description;
  int episodes;
  List<String> genres;
  String bannerUrl;
  String thumbnailUrl;
  String status;
  String userStatus;
  double rating;
  int year;
  int progress;
  List<Episode> episodesList;

  Anime({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.thumbnailUrl,
    required this.malId,
    required this.episodes,
    required this.genres,
    required this.status,
    required this.rating,
    required this.year,
    this.userStatus = "None",
    this.progress = 0,
    this.episodesList = const [],
  });
}
