class Song {
  final String id;
  final String title;
  final String thumbnail;
  final String channel;

  Song({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.channel,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      thumbnail: json['thumbnail'] ?? '',
      channel: json['channel'] ?? 'Unknown Artist',
    );
  }
}
