import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rba_app/models/playlist_model.dart';
import 'package:rba_app/shared/shared_value.dart';

class PlaylistApi {
  Future<PlaylistModel> loadPlaylist() async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails',
      'maxResults': '30',
      'channelId': channelId,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      baseURL,
      '/youtube/v3/playlists',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return PlaylistModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Gagal memuat playlist');
    }
  }
}
