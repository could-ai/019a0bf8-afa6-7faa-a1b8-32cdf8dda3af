import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:couldai_user_app/models/song_model.dart';
import 'package:couldai_user_app/services/api_service.dart';

class AudioPlayerHandler extends ChangeNotifier {
  final _player = AudioPlayer();
  final _apiService = ApiService();
  List<Song> _playlist = [];
  int _currentIndex = -1;

  Song? get currentSong => _currentIndex >= 0 ? _playlist[_currentIndex] : null;
  AudioPlayer get player => _player;

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  Future<void> setPlaylist(List<Song> songs, int initialIndex) async {
    _playlist = songs;
    _currentIndex = initialIndex;
    await _loadAndPlay(_currentIndex);
    notifyListeners();
  }

  Future<void> _loadAndPlay(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    try {
      final url = await _apiService.getSongUrl(_playlist[index].id);
      if (url.isNotEmpty) {
        await _player.setUrl(url);
        play();
      } else {
        // Handle error, maybe skip to next
        skipToNext();
      }
    } catch (e) {
      print("Error loading song: $e");
      // Handle error
    }
    notifyListeners();
  }

  void play() => _player.play();
  void pause() => _player.pause();
  void seek(Duration position) => _player.seek(position);

  Future<void> skipToNext() async {
    if (_currentIndex + 1 < _playlist.length) {
      await _loadAndPlay(_currentIndex + 1);
    }
  }

  Future<void> skipToPrevious() async {
    if (_currentIndex - 1 >= 0) {
      await _loadAndPlay(_currentIndex - 1);
    }
  }

  Stream<PositionData> get positionDataStream {
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
