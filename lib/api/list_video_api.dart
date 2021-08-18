import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rba_app/models/list_video_model.dart';
import 'package:rba_app/shared/shared_value.dart';

class ListVideoApi {
  Future<ListVideoModel> loadPlaylistItems(
      String playlistId, String nextPageToken) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails',
      'playlistId': playlistId,
      'maxResults': '20',
      'pageToken': nextPageToken,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      baseURL,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return ListVideoModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Gagal memuat video.');
    }
  }
}
