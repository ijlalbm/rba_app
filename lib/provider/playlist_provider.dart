import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rba_app/api/playlist_api.dart';
import 'package:rba_app/models/playlist_model.dart';

enum ResultState { Loading, NoData, HasData, Error }

class PlaylistProvider extends ChangeNotifier {
  final PlaylistApi playlistApi;

  PlaylistProvider({required this.playlistApi}) {
    _fetchPlaylist();
  }

  late PlaylistModel _playlist;
  late String _message = '';
  late ResultState _state;

  String get message => _message;

  PlaylistModel get result => _playlist;

  ResultState get state => _state;

  Future<dynamic> _fetchPlaylist() async {
    try {
      _state = ResultState.Loading;
      notifyListeners();
      final playlist = await playlistApi.loadPlaylist();
      if (playlist.items!.isEmpty) {
        _state = ResultState.NoData;
        notifyListeners();
        return _message = 'Data Kosong';
      } else {
        _state = ResultState.HasData;
        notifyListeners();
        return _playlist = playlist;
      }
    } on SocketException {
      _state = ResultState.Error;
      notifyListeners();
      return _message =
          "Gagal memuat playlist,\n periksa kembali koneksi anda.";
    } catch (e) {
      _state = ResultState.Error;
      notifyListeners();
      return _message = '$e';
    }
  }
}
