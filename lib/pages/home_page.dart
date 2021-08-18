import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rba_app/provider/profile_provider.dart';
import 'package:rba_app/widget/build_playlist.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BuildProfile(),
          Expanded(
            child: BuildPlaylist(),
          ),
        ],
      ),
    );
  }
}

class BuildProfile extends StatelessWidget {
  const BuildProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder: (context, state, _) {
      if (state.state == ResultState.Loading) {
        return Center(
          child: Container(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator()),
        );
      } else if (state.state == ResultState.HasData) {
        return Container(
          margin: EdgeInsets.fromLTRB(20, 25, 20, 0),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35.0,
                    backgroundImage: NetworkImage(
                        state.result.items[0].snippet.thumbnails.medium.url),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          state.result.items[0].snippet.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${state.result.items[0].statistics.subscriberCount} subscribers',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
              ),
            ],
          ),
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
}
