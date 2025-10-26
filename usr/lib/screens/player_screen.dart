import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:couldai_user_app/services/audio_handler.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  void _showVolumeControl(BuildContext context) {
    final audioHandler = context.read<AudioPlayerHandler>();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StreamBuilder<double>(
          stream: audioHandler.player.volumeStream,
          builder: (context, snapshot) {
            final volume = snapshot.data ?? 1.0;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Volume", style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: audioHandler.player.setVolume,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = context.watch<AudioPlayerHandler>();
    final song = audioHandler.currentSong;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Now Playing"),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
          ),
        ),
        child: song == null
            ? const Center(child: Text("No song selected"))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      song.thumbnail,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.channel,
                    style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<PositionData>(
                    stream: audioHandler.positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      final duration = positionData?.duration ?? Duration.zero;
                      final position = positionData?.position ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              audioHandler.seek(Duration(seconds: value.round()));
                            },
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position)),
                                Text(_formatDuration(duration)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 40),
                        onPressed: audioHandler.skipToPrevious,
                      ),
                      const SizedBox(width: 20),
                      StreamBuilder<PlayerState>(
                        stream: audioHandler.player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return const CircularProgressIndicator();
                          } else if (playing != true) {
                            return IconButton(
                              icon: const Icon(Icons.play_arrow, size: 60),
                              onPressed: audioHandler.play,
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(Icons.pause, size: 60),
                              onPressed: audioHandler.pause,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 40),
                        onPressed: audioHandler.skipToNext,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () { /* TODO: Implement Like */ },
                      ),
                       IconButton(
                        icon: const Icon(Icons.playlist_add),
                        onPressed: () { /* TODO: Implement Add to Playlist */ },
                      ),
                       IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _showVolumeControl(context),
                      ),
                       IconButton(
                        icon: const Icon(Icons.timer_outlined),
                        onPressed: () { /* TODO: Implement Sleep Timer */ },
                      ),
                    ],
                  ),
                   const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
