import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/home";
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _musicRepository = MusicRepository();
  fp.Either<SubsonicError, bool> _isFetchingData = const fp.Right(true);

  _MyHomePageState() {
    _refreshPlaylists();
  }

  Future<void> _refreshPlaylists() async {
    _musicRepository.fetchPlaylists().then((value) {
      value.match((error) {
        _isFetchingData = fp.Left(error);
        setState(() {});
      }, (_) {
        _isFetchingData = const fp.Right(false);
        setState(() {});
      });
    });
  }

  Widget _buildPlaylists(List<Playlist> playlists) {
    var children = List<Widget>.empty(growable: true);
    for (int index = 0; index < playlists.length; index++) {
      children.add(
        Card(
          child: ListTile(
            leading: const FlutterLogo(size: 72.0),
            title: Text(playlists[index].name),
            subtitle: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(playlists[index].songCount.toString()),
                    const Icon(Icons.my_library_music_outlined),
                    Text(playlists[index].formattedDuration),
                    const Icon(Icons.timer_outlined),
                  ],
                ),
              ],
            ),
            // trailing: const Icon(Icons.star_outline),
            // isThreeLine: true,
          ),
        ),
      );
    }

    return RefreshIndicator(
        onRefresh: _refreshPlaylists,
        child: Padding(
        padding: const EdgeInsets.all(16),
        // FIXME: this adds weird blank spaces at the top and bottom that crops the content
        child: ListView(
          shrinkWrap: true,
          children: children,
        )));
  }

  Widget _buildSubsonicError(SubsonicError error) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey,
      child: Text(error.message),
    );
  }

  Widget _buildLoadingAnimation() {
    return const SingleChildScrollView(
        child: Center(
            child: Column(children: <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Fetching playlist...'),
              ),
            ])));
  }

  Widget _buildLoadingDataError(Object? error) {
    return SingleChildScrollView(
        child: Center(
            child: Column(children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: $error'),
              ),
            ])));
  }

  void _onFilterPlaylistsChanged(PlaylistsSort? value, StateSetter myState) {
    myState(() {
      _musicRepository.sortBy(value ?? PlaylistsSort.alphabetical);
    });
    setState(() {});
  }

  void _showModelFilterPlaylist(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter myState) {
                return SizedBox(
                  height: 200,
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Alphabetical'),
                        leading: Radio<PlaylistsSort>(
                          value: PlaylistsSort.alphabetical,
                          groupValue: _musicRepository.sort,
                          onChanged: (PlaylistsSort? value) =>
                              _onFilterPlaylistsChanged(value, myState),
                        ),
                      ),
                      ListTile(
                        title: const Text('Reversed alphabetical'),
                        leading: Radio<PlaylistsSort>(
                          value: PlaylistsSort.reverseAlphabetical,
                          groupValue: _musicRepository.sort,
                          onChanged: (PlaylistsSort? value) =>
                              _onFilterPlaylistsChanged(value, myState),
                        ),
                      ),
                      ListTile(
                        title: const Text('Ascending duration'),
                        leading: Radio<PlaylistsSort>(
                          value: PlaylistsSort.duration,
                          groupValue: _musicRepository.sort,
                          onChanged: (PlaylistsSort? value) =>
                              _onFilterPlaylistsChanged(value, myState),
                        ),
                      ),
                      ListTile(
                        title: const Text('Descending duration'),
                        leading: Radio<PlaylistsSort>(
                          value: PlaylistsSort.descendingDuration,
                          groupValue: _musicRepository.sort,
                          onChanged: (PlaylistsSort? value) =>
                              _onFilterPlaylistsChanged(value, myState),
                        ),
                      ),
                      ListTile(
                        title: const Text('Ascending songs count'),
                        leading: Radio<PlaylistsSort>(
                          value: PlaylistsSort.songsCount,
                          groupValue: _musicRepository.sort,
                          onChanged: (PlaylistsSort? value) =>
                              _onFilterPlaylistsChanged(value, myState),
                        ),
                      ),
                      ListTile(
                        title: const Text('Descending songs count'),
                        leading: Radio<PlaylistsSort>(
                          value: PlaylistsSort.descendingSongsCount,
                          groupValue: _musicRepository.sort,
                          onChanged: (PlaylistsSort? value) =>
                              _onFilterPlaylistsChanged(value, myState),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: _isFetchingData.match(_buildSubsonicError, (state) {
            if (state) {
              return _buildLoadingAnimation();
            } else {
              return _buildPlaylists(_musicRepository.playlists);
            }
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModelFilterPlaylist(context),
        tooltip: "Filter",
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
