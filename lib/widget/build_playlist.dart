import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rba_app/api/list_video_api.dart';
import 'package:rba_app/api/update_list_api.dart';
import 'package:rba_app/pages/video_screen.dart';
import 'package:rba_app/provider/list_video_provider.dart';
import 'package:rba_app/provider/playlist_provider.dart';
import 'package:rba_app/provider/update_list_provider.dart';

class BuildPlaylist extends StatefulWidget {
  const BuildPlaylist({
    Key? key,
  }) : super(key: key);

  @override
  _BuildPlaylistState createState() => _BuildPlaylistState();
}

class _BuildPlaylistState extends State<BuildPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, state, _) {
      if (state.state == ResultState.Loading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state.state == ResultState.HasData) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: state.result.items!.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  decoration: BoxDecoration(
                    color: Color(0XFF119D8E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    state.result.items![index].snippet!.title!,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  height: 263,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: buildPlaylistItem(state, index),
                ),
              ],
            );
          },
        );
      } else if (state.state == ResultState.NoData) {
        return Center(
          child: Text(state.message),
        );
      } else if (state.state == ResultState.Error) {
        return Center(
            child: Text(
          state.message,
          textAlign: TextAlign.center,
        ));
      } else {
        return Center(
          child: Text(''),
        );
      }
    });
  }

  ChangeNotifierProvider<ListVideoProvider> buildPlaylistItem(
      PlaylistProvider states, int index) {
    String? nextPageToken;
    return ChangeNotifierProvider.value(
      value: ListVideoProvider(
        listVideoApi: ListVideoApi(),
        playlistId: states.result.items![index].id!,
      ),
      child: Consumer<ListVideoProvider>(builder: (context, state, _) {
        if (state.state == ResultStateItem.Loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state.state == ResultStateItem.HasData) {
          int pageCount = (state.result.pageInfo!.totalResults! / 20).ceil();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: pageCount,
            itemBuilder: (context, index) {
              return ChangeNotifierProvider.value(
                value: UpdateListProvider(
                    updateListApi: UpdateListApi(),
                    playlistId: state.result.items![index].snippet!.playlistId!,
                    nextPageToken: nextPageToken ?? ""),
                child: Consumer<UpdateListProvider>(
                    builder: (context, stateUpdate, _) {
                  if (stateUpdate.state == ResultStateItemUpdate.Loading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (stateUpdate.state ==
                      ResultStateItemUpdate.HasData) {
                    // diulang agar jika ada perubahan tidak merefresh semua playlist
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: stateUpdate.result.items!.length,
                      itemBuilder: (context, index) {
                        nextPageToken = stateUpdate.result.nextPageToken ?? "";
                        var videoUpdate =
                            stateUpdate.result.items![index].snippet;
                        var listVideo = stateUpdate.result;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoScreen(
                                id: videoUpdate!.resourceId!.videoId!,
                                snippet: videoUpdate,
                                playlistId: videoUpdate.playlistId!,
                                updateList: listVideo,
                              ),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 171,
                                width: 280,
                                margin: EdgeInsets.fromLTRB(0, 0, 20, 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(videoUpdate
                                              ?.thumbnails?.medium?.url ??
                                          ""),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 20,
                                          offset: Offset(6, 5),
                                          spreadRadius: 2),
                                    ]),
                              ),
                              Container(
                                width: 250,
                                child: Text(
                                  videoUpdate?.title ?? "",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      // ),
                    );
                  } else if (stateUpdate.state ==
                      ResultStateItemUpdate.NoData) {
                    return Center(
                      child: Text(state.message),
                    );
                  } else if (stateUpdate.state == ResultStateItemUpdate.Error) {
                    return Center(
                        child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    return Center(
                      child: Text(''),
                    );
                  }
                }),
              );
            },
          );
        } else if (state.state == ResultStateItem.NoData) {
          return Center(
            child: Text(state.message),
          );
        } else if (state.state == ResultStateItem.Error) {
          return Center(
              child: Text(
            state.message,
            textAlign: TextAlign.center,
          ));
        } else {
          return Center(
            child: Text(''),
          );
        }
      }),
    );
  }
}
