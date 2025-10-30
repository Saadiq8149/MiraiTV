import 'dart:convert';
import 'package:http/http.dart' as http;

class AnicliAPI {
  static const String agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0";
  static const String allanimeRefr = "https://allmanga.to";
  static const String allanimeBase = "allanime.day";
  static const String allanimeApi = "https://api.$allanimeBase";

  Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    const searchGql = '''
      query(\$search: SearchInput \$limit: Int \$page: Int \$translationType: VaildTranslationTypeEnumType \$countryOrigin: VaildCountryOriginEnumType) {
        shows(search: \$search limit: \$limit page: \$page translationType: \$translationType countryOrigin: \$countryOrigin) {
          edges {
            _id
            aniListId
            name
          }
        }
      }
    ''';

    final variables = {
      "search": {"allowAdult": false, "allowUnknown": false, "query": query},
      "limit": 40,
      "page": 1,
      "translationType": "sub",
      "countryOrigin": "ALL",
    };

    final response = await http.get(
      Uri.parse('$allanimeApi/api').replace(
        queryParameters: {
          'variables': jsonEncode(variables),
          'query': searchGql,
        },
      ),
      headers: {'Referer': allanimeRefr, 'User-Agent': agent},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final shows = data['data']?['shows']?['edges'] as List<dynamic>? ?? [];

      return shows.map((show) {
        return {
          'id': show['_id'] as String,
          'anilistId': show['aniListId'] as String?,
        };
      }).toList();
    }

    return [];
  }

  Future<Map<String, dynamic>?> getAnimeByAnilistId(
    String anilistId,
    String title,
  ) async {
    title = title.replaceAll("!", "").replaceAll("?", "").replaceAll(".", "");
    final results = await searchAnime(title);

    for (var anime in results) {
      if (anime['anilistId'] == anilistId) {
        return anime;
      }
    }
    return null;
  }

  Future<List<String>> getEpisodesList(String showId) async {
    const episodesListGql = '''
      query (\$showId: String!) {
        show(_id: \$showId) {
          _id
          availableEpisodesDetail
        }
      }
    ''';

    final variables = {"showId": showId};

    final response = await http.get(
      Uri.parse('$allanimeApi/api').replace(
        queryParameters: {
          'variables': jsonEncode(variables),
          'query': episodesListGql,
        },
      ),
      headers: {'Referer': allanimeRefr, 'User-Agent': agent},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final episodesDetail = data['data']?['show']?['availableEpisodesDetail'];

      if (episodesDetail != null && episodesDetail['sub'] != null) {
        return List<String>.from(episodesDetail['sub']);
      }
    }

    return [];
  }

  /// Decode provider ID from hex encoding
  String _decodeProviderId(String encoded) {
    final decodeMap = {
      '79': 'A',
      '7a': 'B',
      '7b': 'C',
      '7c': 'D',
      '7d': 'E',
      '7e': 'F',
      '7f': 'G',
      '70': 'H',
      '71': 'I',
      '72': 'J',
      '73': 'K',
      '74': 'L',
      '75': 'M',
      '76': 'N',
      '77': 'O',
      '68': 'P',
      '69': 'Q',
      '6a': 'R',
      '6b': 'S',
      '6c': 'T',
      '6d': 'U',
      '6e': 'V',
      '6f': 'W',
      '60': 'X',
      '61': 'Y',
      '62': 'Z',
      '59': 'a',
      '5a': 'b',
      '5b': 'c',
      '5c': 'd',
      '5d': 'e',
      '5e': 'f',
      '5f': 'g',
      '50': 'h',
      '51': 'i',
      '52': 'j',
      '53': 'k',
      '54': 'l',
      '55': 'm',
      '56': 'n',
      '57': 'o',
      '48': 'p',
      '49': 'q',
      '4a': 'r',
      '4b': 's',
      '4c': 't',
      '4d': 'u',
      '4e': 'v',
      '4f': 'w',
      '40': 'x',
      '41': 'y',
      '42': 'z',
      '08': '0',
      '09': '1',
      '0a': '2',
      '0b': '3',
      '0c': '4',
      '0d': '5',
      '0e': '6',
      '0f': '7',
      '00': '8',
      '01': '9',
      '15': '-',
      '16': '.',
      '67': '_',
      '46': '~',
      '02': ':',
      '17': '/',
      '07': '?',
      '1b': '#',
      '63': '[',
      '65': ']',
      '78': '@',
      '19': '!',
      '1c': '\$',
      '1e': '&',
      '10': '(',
      '11': ')',
      '12': '*',
      '13': '+',
      '14': ',',
      '03': ';',
      '05': '=',
      '1d': '%',
    };

    final result = StringBuffer();
    for (int i = 0; i < encoded.length; i += 2) {
      final hex = encoded.substring(i, i + 2);
      result.write(decodeMap[hex] ?? '');
    }

    return result.toString().replaceAll('/clock', '/clock.json');
  }

  Future<Map<String, String>> _getEmbedUrls(
    String showId,
    String episodeString,
  ) async {
    const episodeEmbedGql = '''
      query (\$showId: String!, \$translationType: VaildTranslationTypeEnumType!, \$episodeString: String!) {
        episode(showId: \$showId translationType: \$translationType episodeString: \$episodeString) {
          episodeString
          sourceUrls
        }
      }
    ''';

    final variables = {
      "showId": showId,
      "translationType": "sub",
      "episodeString": episodeString,
    };

    final response = await http.get(
      Uri.parse('$allanimeApi/api').replace(
        queryParameters: {
          'variables': jsonEncode(variables),
          'query': episodeEmbedGql,
        },
      ),
      headers: {'Referer': allanimeRefr, 'User-Agent': agent},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sourceUrls = data['data']?['episode']?['sourceUrls'] as List? ?? [];

      final providers = <String, String>{};
      for (var source in sourceUrls) {
        final sourceName = source['sourceName'] as String?;
        final sourceUrl = source['sourceUrl'] as String?;

        if (sourceName != null &&
            sourceUrl != null &&
            sourceUrl.startsWith('--')) {
          providers[sourceName] = sourceUrl.substring(2); // Remove '--' prefix
        }
      }

      return providers;
    }

    return {};
  }

  Future<List<Map<String, String>>> _getLinks(String providerId) async {
    var decodedId = _decodeProviderId(providerId);

    decodedId = decodedId.replaceFirst('https://', '/');

    final fullUrl = 'https://$allanimeBase$decodedId';

    final response = await http.get(
      Uri.parse(fullUrl),
      headers: {'Referer': allanimeRefr, 'User-Agent': agent},
    );

    if (response.statusCode == 200) {
      final links = <Map<String, String>>[];
      final body = response.body;

      try {
        final data = jsonDecode(body);

        if (data['links'] != null && data['links'] is List) {
          final linksList = data['links'] as List;

          for (var link in linksList) {
            final url = link['link'] as String?;
            final quality = link['resolutionStr'] as String?;

            String sourceType = 'Unknown';
            if (link['hls'] == true) {
              sourceType = 'hls';
            } else if (link['mp4'] == true) {
              sourceType = 'mp4';
            } else if (link['mkv'] == true) {
              sourceType = 'mkv';
            } else if (link['webm'] == true) {
              sourceType = 'webm';
            }

            String subtitles = '';
            if (link['subtitles'] != null && link['subtitles'] is List) {
              final subtitlesList = link['subtitles'] as List;
              if (subtitlesList.isNotEmpty) {
                final sub = subtitlesList.first;
                subtitles = sub['src'] ?? '';
              }
            }

            Map<String, String> referrerHeaders = {};
            if (link['headers'] != null) {
              referrerHeaders['Referer'] = link['headers']['Referer'];
              referrerHeaders['User-Agent'] = link['headers']['user-agent'];
            }

            if (url != null && quality != null) {
              links.add({
                'quality': quality,
                'url': url,
                'source': sourceType,
                'subtitles': subtitles,
                'referrer': referrerHeaders['Referer'] ?? allanimeRefr,
                'user-agent': referrerHeaders['User-Agent'] ?? agent,
              });
            }
          }
        }
      } catch (e) {
        print('[DEBUG] Failed to parse JSON: $e');
      }

      return links;
    }

    return [];
  }

  Future<List<Map<String, String>>?> getEpisodeUrls(
    String showId,
    String episodeNumber,
  ) async {
    final embedUrls = await _getEmbedUrls(showId, episodeNumber);

    if (embedUrls.isEmpty) {
      return null;
    }

    final providerOrder = ['Luf-Mp4', 'Default', 'Yt-mp4', 'S-mp4'];
    final allLinks = <Map<String, String>>[];

    for (final providerName in providerOrder) {
      var providerId = embedUrls[providerName];

      if (providerId != null) {
        final links = await _getLinks(providerId);

        if (links.isNotEmpty) {
          allLinks.addAll(links);
        }
      }
    }

    print(allLinks);

    return allLinks;
  }
}
