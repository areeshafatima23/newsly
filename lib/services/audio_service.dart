
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class AudioService {
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  Function(TtsState)? onStateChanged;

  void init() {
    _flutterTts = FlutterTts();
    _flutterTts.setStartHandler(() => onStateChanged?.call(TtsState.playing));
    _flutterTts.setCompletionHandler(() => onStateChanged?.call(TtsState.stopped));
    _flutterTts.setErrorHandler((_) => onStateChanged?.call(TtsState.stopped));
  }

  Future<void> speak(String title, String text) async {
    if (_ttsState == TtsState.playing) await stop();
    if (await _flutterTts.speak('$title. $text') == 1) {
      onStateChanged?.call(TtsState.playing);
    }
  }

  Future<void> stop() async {
    if (await _flutterTts.stop() == 1) {
      onStateChanged?.call(TtsState.stopped);
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
