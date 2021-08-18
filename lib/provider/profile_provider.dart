import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rba_app/api/profile_api.dart';
import 'package:rba_app/models/profile_model.dart';

enum ResultState { Loading, NoData, HasData, Error }

class ProfileProvider extends ChangeNotifier {
  final ProfileApi profileApi;

  ProfileProvider({required this.profileApi}) {
    _fetchProfile();
  }

  late ProfileModel _profile;
  late String _message = '';
  late ResultState _state;

  String get message => _message;

  ProfileModel get result => _profile;

  ResultState get state => _state;

  Future<dynamic> _fetchProfile() async {
    try {
      _state = ResultState.Loading;
      notifyListeners();
      final profile = await profileApi.profileChannel();
      if (profile.items.isEmpty) {
        _state = ResultState.NoData;
        notifyListeners();
        return _message = 'Data Kosong';
      } else {
        _state = ResultState.HasData;
        notifyListeners();
        return _profile = profile;
      }
    } on SocketException {
      _state = ResultState.Error;
      notifyListeners();
      return _message = "Gagal memuat profil, \nperiksa kembali koneksi anda.";
    } catch (e) {
      _state = ResultState.Error;
      notifyListeners();
      return _message = '$e';
    }
  }
}
