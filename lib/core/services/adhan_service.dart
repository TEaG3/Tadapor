import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// خدمة تشغيل صوت الأذان
/// ضع ملف الأذان في: assets/audio/adhan.mp3
/// وللإشعارات على أندرويد ضع نسخة أيضاً في:
/// android/app/src/main/res/raw/adhan.mp3
class AdhanService {
  static final AdhanService instance = AdhanService._();
  AdhanService._();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// أسماء ملفات الأذان المتاحة (بدون امتداد)
  static const List<String> availableAdhans = [
    'adhan',           // الافتراضي
    'adhan_makkah',    // أذان مكة
    'adhan_madinah',   // أذان المدينة
    'adhan_egypt',     // أذان مصر
  ];

  String _selectedAdhan = 'adhan';

  String get selectedAdhan => _selectedAdhan;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      ));

      _player.playerStateStream.listen((state) {
        _isPlaying = state.playing;
      });

      _initialized = true;
    } catch (e) {
      debugPrint('AdhanService init error: $e');
    }
  }

  void setAdhan(String name) {
    if (availableAdhans.contains(name)) {
      _selectedAdhan = name;
    }
  }

  /// تشغيل الأذان من assets
  Future<void> play({String? adhanName}) async {
    try {
      await init();
      final name = adhanName ?? _selectedAdhan;
      final path = 'assets/audio/$name.mp3';

      await _player.stop();
      await _player.setAsset(path);
      await _player.setVolume(1.0);
      await _player.play();
    } catch (e) {
      debugPrint('فشل تشغيل الأذان ($e). تأكد من وجود الملف في assets/audio/');
      // محاولة الملف الافتراضي
      try {
        await _player.setAsset('assets/audio/adhan.mp3');
        await _player.play();
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> pause() async {
    await _player.pause();
  }

  void dispose() {
    _player.dispose();
  }
}
