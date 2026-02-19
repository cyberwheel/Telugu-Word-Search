import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSelect() async {
    await _play(AppSounds.select);
  }

  Future<void> playSuccess() async {
    await _play(AppSounds.success);
  }

  Future<void> playWin() async {
    await _play(AppSounds.win);
  }

  Future<void> playError() async {
    await _play(AppSounds.error);
  }

  Future<void> _play(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Silently fail if sound not available
      debugPrint('Sound play error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
