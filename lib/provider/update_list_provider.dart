import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rba_app/api/update_list_api.dart';
import 'package:rba_app/models/update_list_model.dart';

enum ResultStateItemUpdate { Loading, NoData, HasData, Error }

class UpdateListProvider extends ChangeNotifier {
  final UpdateListApi updateListApi;
  String playlistId;
  String? nextPageToken;

  UpdateListProvider(
      {required this.updateListApi,
      required this.playlistId,
      required this.nextPageToken}) {
    _fetchPlaylist();
  }

  late UpdateListModel _playlistItem;
  late String _message = '';
  late ResultStateItemUpdate _stateUpdate;

  String get message => _message;

  UpdateListModel get result => _playlistItem;

  ResultStateItemUpdate get state => _stateUpdate;

  Future<dynamic> _fetchPlaylist() async {
    try {
      _stateUpdate = ResultStateItemUpdate.Loading;
      notifyListeners();
      final playlistItem = await updateListApi.loadPlaylistItems(
          playlistId, nextPageToken ?? "");
      if (playlistItem.items!.isEmpty) {
        _stateUpdate = ResultStateItemUpdate.NoData;
        notifyListeners();
        return _message = 'Data kosong.';
      } else {
        _stateUpdate = ResultStateItemUpdate.HasData;
        notifyListeners();
        return _playlistItem = playlistItem;
      }
    } on SocketException {
      _stateUpdate = ResultStateItemUpdate.Error;
      notifyListeners();
      return _message = "Gagal memuat video, \nperiksa kembali koneksi anda";
    } catch (e) {
      _stateUpdate = ResultStateItemUpdate.Error;
      notifyListeners();
      return _message = '$e';
    }
  }
}
