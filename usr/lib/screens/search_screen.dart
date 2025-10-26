import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:couldai_user_app/models/song_model.dart';
import 'package:couldai_user_app/services/api_service.dart';
import 'package:couldai_user_app/screens/player_screen.dart';
import 'package:couldai_user_app/services/audio_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Song> _searchResults = [];
  bool _isLoading = false;

  void _search() async {
    if (_searchController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await _apiService.searchSongs(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle error
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<AudioPlayerHandler>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for songs, artists, albums...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final song = _searchResults[index];
                    return ListTile(
                      leading: Image.network(song.thumbnail),
                      title: Text(song.title),
                      subtitle: Text(song.channel),
                      onTap: () {
                        audioHandler.setPlaylist(_searchResults, index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
