import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> playTrack({required String pathOrUrl, bool isLocal = false}) async {
    try {
      await _player.stop();
      if (isLocal) {
        await _player.setFilePath(pathOrUrl);
      } else {
        await _player.setUrl(pathOrUrl);
      }
      _player.play();
    } catch (e) {
      print("Erro ao tocar áudio: $e");
    }
  }

  void pause() => _player.pause();
  void resume() => _player.play();
  void dispose() => _player.dispose();
}