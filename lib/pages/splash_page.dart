import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rba_app/api/playlist_api.dart';
import 'package:rba_app/api/profile_api.dart';
import 'package:rba_app/pages/home_page.dart';
import 'package:rba_app/provider/playlist_provider.dart';
import 'package:rba_app/provider/profile_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Timer(Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ProfileProvider(
                  profileApi: ProfileApi(),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => PlaylistProvider(
                  playlistApi: PlaylistApi(),
                ),
              ),
            ],
            child: HomePage(),
          ),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "images/rba.png",
                width: 150,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(60, 20, 60, 20),
                child: Text(
                  "Mari bersama kami bersungguh-sungguh mengkaji dan mempelajari ilmu-ilmu alat untuk memahami Al-Qur'an dan Sunnah.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0XFF119D8E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
