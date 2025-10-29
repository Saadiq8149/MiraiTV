import 'dart:convert';
import 'package:mirai_tv/utils/types.dart';
import 'package:http/http.dart' as http;

class AnilistAPI {
  static const String _baseUrl = 'https://graphql.anilist.co';

  Future<Map<String, dynamic>?> _queryAnilist(
    String query,
    Map<String, dynamic> variables,
  ) async {
    http.Response response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
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
        );
        animeList.add(anime);
      }
      return animeList;
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
      List<Episode> episodesList = [];

      for (var i = 0; i < media['streamingEpisodes'].length; i++) {
        var ep = media['streamingEpisodes'][i];
        episodesList.add(
          Episode(
            title: ep['title'] ?? 'Episode ${ep['episode']}',
            thumbnailUrl: ep['thumbnail'] ?? '',
            episodeNumber: i + 1,
          ),
        );
      }

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
        episodesList: episodesList,
      );

      return anime;
    }
  }
}
