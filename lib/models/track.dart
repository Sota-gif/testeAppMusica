class Track {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String streamUrl;
  final String? localPath;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.streamUrl,
    this.localPath,
  });
}