import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rba_app/models/profile_model.dart';
import 'package:rba_app/shared/shared_value.dart';

class ProfileApi {
  Future<ProfileModel> profileChannel() async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': channelId,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      baseURL,
      '/youtube/v3/channels',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Gagal memuat profil');
    }
  }
}
