import 'dart:convert';
import 'package:mirai_tv/utils/types.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AnilistAPI {
  static const String _baseUrl = 'https://graphql.anilist.co';
  static const String _clientId = '31463';
  static final Uri _authUrl = Uri.parse(
    'https://anilist.co/api/v2/oauth/authorize?client_id=$_clientId&response_type=token',
  );

  final SharedPreferences prefs;
  String? _accessToken;

  AnilistAPI(this.prefs)
    : _accessToken = prefs.getString('anilist_access_token');

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await prefs.setString('anilist_access_token', token);
  }

  Future<void> clearAccessToken() async {
    _accessToken = null;
    await prefs.remove('anilist_access_token');
  }

  bool isAuthenticated() {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  Future<void> authenticate() async {
    if (!await launchUrl(_authUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_authUrl');
    }
  }

  Future<Map<String, dynamic>?> _queryAnilist(
    String query,
    Map<String, dynamic> variables,
  ) async {
    http.Response response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Anilist API Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<List<Anime>> searchAnime(String searchQuery) async {
    const String query = """
      query (\$search: String!) {
        Page {
          media(search: \$search, type: ANIME) {
            id
            title {
              romaji
              english
            }
            idMal
            status
            episodes
            description
            averageScore
            genres
            bannerImage
            seasonYear
            coverImage {
              extraLarge
            }
            nextAiringEpisode {
              episode
            }
          }
        }
      }
    """;

    Map<String, dynamic> variables = {'search': searchQuery};

    final response = await _queryAnilist(query, variables);

    if (response == null) {
      return [];
    } else {
      List<dynamic> mediaList = response['data']['Page']['media'];
      List<Anime> animeList = [];
      for (var media in mediaList) {
        int episodes;

        if (media['status'] == 'RELEASING' &&
            media['nextAiringEpisode'] != null) {
          episodes = media['nextAiringEpisode']['episode'] - 1;
        } else {
          episodes = media['episodes'] ?? 1;
        }

        Anime anime = Anime(
          id: media['id'],
          title: media['title']['english'] ?? media['title']['romaji'],
          malId: media['idMal'] ?? 0,
          status: media['status'] ?? 'UNKNOWN',
          episodes: episodes,
          description: media['description'] ?? '',
          rating: (media['averageScore'] ?? 0.0).toDouble(),
          genres: List<String>.from(media['genres']),
          bannerUrl: media['bannerImage'] ?? '',
          thumbnailUrl: media['coverImage']['extraLarge'] ?? '',
          year: media['seasonYear'] ?? 0,
          userStatus: 'None',
        );
        animeList.add(anime);
      }
      return animeList;
    }
  }

  Future<void> updateAnimeProgress(int animeId, int progress) async {
    const String mutation = """
      mutation (\$animeId: Int!, \$progress: Int!) {
        SaveMediaListEntry(mediaId: \$animeId, progress: \$progress) {
          id
          progress
        }
      }
    """;

    Map<String, dynamic> variables = {'animeId': animeId, 'progress': progress};

    final response = await _queryAnilist(mutation, variables);

    if (response == null) {
      throw Exception('Failed to update anime progress');
    }
  }

  Future<Anime?> getAnimeById(int id) async {
    const String query = """
      query (\$id: Int!) {
        Media(id: \$id, type: ANIME) {
          id
          title {
            romaji
            english
          }
          idMal
          status
          episodes
          description
          averageScore
          genres
          seasonYear
          bannerImage
          coverImage {
            extraLarge
          }
          nextAiringEpisode {
            episode
          }
          streamingEpisodes {
            title
            thumbnail
          }
          mediaListEntry {
            status  
            progress
          }
        }
      }
    """;

    Map<String, dynamic> variables = {'id': id};

    final response = await _queryAnilist(query, variables);

    if (response == null) {
      return null;
    } else {
      Map<String, dynamic> media = response['data']['Media'];

      int episodes;

      if (media['status'] == 'RELEASING' &&
          media['nextAiringEpisode'] != null) {
        episodes = media['nextAiringEpisode']['episode'] - 1;
      } else {
        episodes = media['episodes'] ?? 1;
      }

      Anime anime = Anime(
        id: media['id'],
        title: media['title']['english'] ?? media['title']['romaji'],
        malId: media['idMal'],
        status: media['status'],
        episodes: episodes,
        description: media['description'],
        rating: (media['averageScore'] ?? 0.0).toDouble(),
        genres: List<String>.from(media['genres']),
        bannerUrl: media['bannerImage'] ?? '',
        thumbnailUrl: media['coverImage']['extraLarge'] ?? '',
        year: media['seasonYear'] ?? 0,
        userStatus: media['mediaListEntry'] != null
            ? media['mediaListEntry']['status'] ?? 'None'
            : 'None',
        progress: media['mediaListEntry'] != null
            ? media['mediaListEntry']['progress'] ?? 0
            : 0,
      );

      return anime;
    }
  }

  Future<List<Anime>> getUserWatchlist() async {
    const String userQuery = """
      query {
        Viewer {
          id
          name
        }
      }
    """;

    final response = await _queryAnilist(userQuery, {});

    if (response == null) {
      return [];
    } else {
      int userId = response['data']['Viewer']['id'];

      const String watchlistQuery = """
        query (\$userId: Int!) {
          MediaListCollection(userId: \$userId, type: ANIME, status: CURRENT) {
            lists {
              entries {
                progress
                media {
                  id
                  title {
                    romaji
                    english
                  }
                  idMal
                  status
                  episodes
                  description
                  averageScore
                  genres
                  bannerImage
                  seasonYear
                  coverImage {
                    extraLarge
                  }
                  nextAiringEpisode {
                    episode
                  }
                }
              }
            }
          }
        }
      """;

      Map<String, dynamic> variables = {'userId': userId};
      final watchlistResponse = await _queryAnilist(watchlistQuery, variables);

      if (watchlistResponse == null) {
        return [];
      } else {
        List<dynamic> entries =
            watchlistResponse['data']['MediaListCollection']['lists'][0]['entries'];
        List<Anime> watchlist = [];
        for (var entry in entries) {
          int episodes;

          if (entry['media']['status'] == 'RELEASING' &&
              entry['media']['nextAiringEpisode'] != null) {
            episodes = entry['media']['nextAiringEpisode']['episode'] - 1;
          } else {
            episodes = entry['media']['episodes'] ?? 1;
          }

          Anime anime = Anime(
            id: entry['media']['id'],
            title:
                entry['media']['title']['english'] ??
                entry['media']['title']['romaji'],
            malId: entry['media']['idMal'] ?? 0,
            status: entry['media']['status'] ?? 'UNKNOWN',
            episodes: episodes,
            description: entry['media']['description'] ?? '',
            rating: (entry['media']['averageScore'] ?? 0.0).toDouble(),
            genres: List<String>.from(entry['media']['genres']),
            bannerUrl: entry['media']['bannerImage'] ?? '',
            thumbnailUrl: entry['media']['coverImage']['extraLarge'] ?? '',
            year: entry['media']['seasonYear'] ?? 0,
            progress: entry['progress'] ?? 0,
          );
          watchlist.add(anime);
        }
        return watchlist;
      }
    }
  }

  Future<List<Anime>> getTrendingAnime() async {
    const String query = """
      query {
        Page(perPage: 10) {
          media(sort: TRENDING_DESC, type: ANIME) {
            id
            title {
              romaji
              english
            }
            idMal
            status
            episodes
            description
            averageScore
            genres
            bannerImage
            seasonYear
            coverImage {
              extraLarge
            }
            nextAiringEpisode {
              episode
            }
          }
        }
      }
    """;

    final response = await _queryAnilist(query, {});
    if (response == null) {
      return [];
    } else {
      List<dynamic> mediaList = response['data']['Page']['media'];
      List<Anime> animeList = [];
      for (var media in mediaList) {
        int episodes;

        if (media['status'] == 'RELEASING' &&
            media['nextAiringEpisode'] != null) {
          episodes = media['nextAiringEpisode']['episode'] - 1;
        } else {
          episodes = media['episodes'] ?? 1;
        }

        Anime anime = Anime(
          id: media['id'],
          title: media['title']['english'] ?? media['title']['romaji'],
          malId: media['idMal'] ?? 0,
          status: media['status'] ?? 'UNKNOWN',
          episodes: episodes,
          description: media['description'] ?? '',
          rating: (media['averageScore'] ?? 0.0).toDouble(),
          genres: List<String>.from(media['genres']),
          bannerUrl: media['bannerImage'] ?? '',
          thumbnailUrl: media['coverImage']['extraLarge'] ?? '',
          year: media['seasonYear'] ?? 0,
          userStatus: 'None',
        );
        animeList.add(anime);
      }
      return animeList;
    }
  }

  Future<List<Anime>> getTopRatedAnime() async {
    const String query = """
      query {
        Page(perPage: 10) {
          media(sort: SCORE_DESC, type: ANIME) {
            id
            title {
              romaji
              english
            }
            idMal
            status
            episodes
            description
            averageScore
            genres
            bannerImage
            seasonYear
            coverImage {
              extraLarge
            }
            nextAiringEpisode {
              episode
            }
          }
        }
      }
    """;

    final response = await _queryAnilist(query, {});
    if (response == null) {
      return [];
    } else {
      List<dynamic> mediaList = response['data']['Page']['media'];
      List<Anime> animeList = [];
      for (var media in mediaList) {
        int episodes;

        if (media['status'] == 'RELEASING' &&
            media['nextAiringEpisode'] != null) {
          episodes = media['nextAiringEpisode']['episode'] - 1;
        } else {
          episodes = media['episodes'] ?? 1;
        }

        Anime anime = Anime(
          id: media['id'],
          title: media['title']['english'] ?? media['title']['romaji'],
          malId: media['idMal'] ?? 0,
          status: media['status'] ?? 'UNKNOWN',
          episodes: episodes,
          description: media['description'] ?? '',
          rating: (media['averageScore'] ?? 0.0).toDouble(),
          genres: List<String>.from(media['genres']),
          bannerUrl: media['bannerImage'] ?? '',
          thumbnailUrl: media['coverImage']['extraLarge'] ?? '',
          year: media['seasonYear'] ?? 0,
          userStatus: 'None',
        );
        animeList.add(anime);
      }
      return animeList;
    }
  }

  Future<List<Anime>> getLatestAnime() async {
    const String query = """
      query {
        Page(perPage: 10) {
          media(sort: START_DATE_DESC, type: ANIME) {
            id
            title {
              romaji
              english
            }
            idMal
            status
            episodes
            description
            averageScore
            genres
            bannerImage
            seasonYear
            coverImage {
              extraLarge
            }
            nextAiringEpisode {
              episode
            }
          }
        }
      }
    """;

    final response = await _queryAnilist(query, {});
    if (response == null) {
      return [];
    } else {
      List<dynamic> mediaList = response['data']['Page']['media'];
      List<Anime> animeList = [];
      for (var media in mediaList) {
        int episodes;

        if (media['status'] == 'RELEASING' &&
            media['nextAiringEpisode'] != null) {
          episodes = media['nextAiringEpisode']['episode'] - 1;
        } else {
          episodes = media['episodes'] ?? 1;
        }

        Anime anime = Anime(
          id: media['id'],
          title: media['title']['english'] ?? media['title']['romaji'],
          malId: media['idMal'] ?? 0,
          status: media['status'] ?? 'UNKNOWN',
          episodes: episodes,
          description: media['description'] ?? '',
          rating: (media['averageScore'] ?? 0.0).toDouble(),
          genres: List<String>.from(media['genres']),
          bannerUrl: media['bannerImage'] ?? '',
          thumbnailUrl: media['coverImage']['extraLarge'] ?? '',
          year: media['seasonYear'] ?? 0,
          userStatus: 'None',
        );
        animeList.add(anime);
      }
      return animeList;
    }
  }
}
