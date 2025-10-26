import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:couldai_user_app/models/song_model.dart';

class ApiService {
  static const String _baseUrl = "https://musenzy-api.onrender.com";

  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/search?q=$query"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Song.fromJson(item)).toList();
      } else {
        throw Exception("Failed to search songs");
      }
    } catch (e) {
      print("Error searching songs: $e");
      return [];
    }
  }

  Future<String> getSongUrl(String videoId) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/play?id=$videoId"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      } else {
        throw Exception("Failed to get song URL");
      }
    } catch (e) {
      print("Error getting song url: $e");
      return "";
    }
  }
}
