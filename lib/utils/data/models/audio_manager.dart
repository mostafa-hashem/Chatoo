import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioPlayer? _currentPlayer;

  Future<void> play(AudioPlayer player, String url) async {
    if (_currentPlayer != null && _currentPlayer != player) {
      await _currentPlayer!.stop();
    }
    _currentPlayer = player;
    await player.play(UrlSource(url));
  }

  void stop(AudioPlayer player) {
    if (player == _currentPlayer) {
      player.stop();
      _currentPlayer = null;
    }
  }
}
