import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rba_app/api/list_video_api.dart';
import 'package:rba_app/models/list_video_model.dart';

enum ResultStateItem { Loading, NoData, HasData, Error }

class ListVideoProvider extends ChangeNotifier {
  final ListVideoApi listVideoApi;
  String playlistId;
  String? nextPageToken;

  ListVideoProvider(
      {required this.listVideoApi,
      required this.playlistId,
      this.nextPageToken}) {
    _fetchPlaylist();
  }

  late ListVideoModel _playlistItem;
  late String _message = '';
  late ResultStateItem _state;

  String get message => _message;

  ListVideoModel get result => _playlistItem;

  ResultStateItem get state => _state;

  Future<dynamic> _fetchPlaylist() async {
    try {
      _state = ResultStateItem.Loading;
      notifyListeners();
      final playlistItem =
          await listVideoApi.loadPlaylistItems(playlistId, nextPageToken ?? "");
      if (playlistItem.items!.isEmpty) {
        _state = ResultStateItem.NoData;
        notifyListeners();
        return _message = 'Data kosong';
      } else {
        _state = ResultStateItem.HasData;
        notifyListeners();
        return _playlistItem = playlistItem;
      }
    } on SocketException {
      _state = ResultStateItem.Error;
      notifyListeners();
      return _message = "Gagal memuat video, \n periksa kembali koneksi anda.";
    } catch (e) {
      _state = ResultStateItem.Error;
      notifyListeners();
      return _message = '$e';
    }
  }
}
