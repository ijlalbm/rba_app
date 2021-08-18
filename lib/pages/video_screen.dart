import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rba_app/api/update_list_api.dart';
import 'package:rba_app/models/update_list_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final String id;
  final Snippet snippet;
  final String playlistId;
  final UpdateListModel updateList;

  VideoScreen(
      {required this.id,
      required this.snippet,
      required this.playlistId,
      required this.updateList});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late YoutubePlayerController _controller;
  late List<Item>? videoUpdate = [];
  // agar page token bisa di ambil yang paling terbaru
  late List<String> nextPageTokenList = [];

  @override
  void initState() {
    super.initState();
    // ambil data di page awal setiap masuk halaman ini
    _loadData(widget.playlistId, "");

    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: YoutubePlayerFlags(
          controlsVisibleAtStart: true,
          mute: false,
          autoPlay: true,
          hideThumbnail: false,
          enableCaption: false),
    );
  }

  bool isLoading = false;

  Future _loadData(String playlistId, String nextPageToken) async {
    // perform fetching data delay
    UpdateListModel? playlistItem;
    List<Item> moreVideos = [];

    print("load more");
    playlistItem =
        await UpdateListApi().loadPlaylistItems(playlistId, nextPageToken);
    setState(() {
      // tambahan data di page berikutnya
      playlistItem!.items!.forEach((element) {
        moreVideos.add(element);
      });
      videoUpdate = videoUpdate!..addAll(moreVideos);
      nextPageTokenList..addAll([playlistItem.nextPageToken ?? ""]);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // lebar thumbnails di playlist
    double imageWidth = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(body: buildLandscape(context, imageWidth));
  }

  SingleChildScrollView buildLandscape(
      BuildContext context, double imageWidth) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
          padding: isPortrait
              ? EdgeInsets.fromLTRB(20, 20, 0, 0)
              : EdgeInsets.fromLTRB(20, 0, 0, 20),
          height: isPortrait
              ? MediaQuery.of(context).size.height * (10 / 100)
              : MediaQuery.of(context).size.height * (25 / 100),
          color: Color(0XFF119D8E),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  isPortrait
                      ? Navigator.pop(context)
                      : SystemChrome.setPreferredOrientations(
                          DeviceOrientation.values);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: isPortrait
              ? MediaQuery.of(context).size.height * (25 / 100)
              : MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height * (15 / 100),
          child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(isExpanded: true),
                  RemainingDuration(),
                  PlaybackSpeedButton(),
                  FullScreenButton()
                ],
              ),
              builder: (context, player) {
                return Column(
                  children: <Widget>[
                    // some widgets
                    player,
                    //some other widgets
                  ],
                );
              }),
        ),
        Container(
          padding: isPortrait
              ? EdgeInsets.all(20)
              : EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Text(
            widget.snippet.title ?? "",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Divider(
            thickness: 1,
          ),
        ),
        Container(
          height: 40,
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: Text(
            "Video dalam playlist",
            style: TextStyle(fontSize: 14),
          ),
        ),
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Divider(
            thickness: 1,
          ),
        ),
        NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // cek apakah loading & panjang video == total video & tinggi layar
              if (!isLoading &&
                  videoUpdate?.length !=
                      widget.updateList.pageInfo?.totalResults &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _loadData(widget.snippet.playlistId!, nextPageTokenList.last);
                // start loading data
                setState(() {
                  isLoading = true;
                });
              }
              return false;
            },
            child: (isPortrait)
                ? Container(
                    height: 400,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: videoUpdate!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoScreen(
                                  id: videoUpdate![index]
                                      .snippet!
                                      .resourceId!
                                      .videoId!,
                                  snippet: videoUpdate![index].snippet!,
                                  playlistId:
                                      videoUpdate![index].snippet!.playlistId!,
                                  updateList: widget.updateList,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(20, 0, 10, 20),
                                  height: 100,
                                  width: imageWidth,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(videoUpdate![index]
                                              .snippet!
                                              .thumbnails!
                                              .medium!
                                              .url ??
                                          ""),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    videoUpdate![index].snippet!.title ?? "",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                : Container(
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: videoUpdate!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoScreen(
                                  id: videoUpdate![index]
                                      .snippet!
                                      .resourceId!
                                      .videoId!,
                                  snippet: videoUpdate![index].snippet!,
                                  playlistId:
                                      videoUpdate![index].snippet!.playlistId!,
                                  updateList: widget.updateList,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(20, 0, 10, 20),
                                  height: 100,
                                  width: imageWidth,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(videoUpdate![index]
                                              .snippet!
                                              .thumbnails!
                                              .medium!
                                              .url ??
                                          ""),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    videoUpdate![index].snippet!.title ?? "",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  )),
        Container(
          height: isLoading ? 50.0 : 0,
          color: Colors.transparent,
          child: Center(
            child: new CircularProgressIndicator(),
          ),
        ),
      ]),
    );
  }
}
