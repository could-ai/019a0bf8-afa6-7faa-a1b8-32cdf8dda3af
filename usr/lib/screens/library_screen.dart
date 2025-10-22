import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.playlist_play),
            title: Text('Playlists'),
          ),
          ListTile(
            leading: Icon(Icons.mic),
            title: Text('Artists'),
          ),
          ListTile(
            leading: Icon(Icons.album),
            title: Text('Albums'),
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text('Songs'),
          ),
        ],
      ),
    );
  }
}
