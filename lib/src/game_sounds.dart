import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// The games' sound effects (assets/sounds, made for Hnahsin).
enum GameSound {
  correct,
  wrong,
  tap,
  flip,
  match,
  complete,
  levelUp;

  String get asset => 'sounds/${this == levelUp ? 'levelup' : name}.wav';
}

/// Plays [GameSound]s, unless the learner turned sound off in Profile. They
/// mix with whatever else is playing and stay quiet when the phone is on
/// silent, so they never stop the learner's music.
abstract final class GameSounds {
  /// Profile's Sound setting.
  static bool enabled = true;

  static final _players = <GameSound, AudioPlayer>{};
  static bool _configured = false;

  /// Tests have no audio plugin.
  static final bool _available =
      kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST');

  static void play(GameSound sound) {
    if (!enabled || !_available) return;
    unawaited(_play(sound));
  }

  static Future<void> _play(GameSound sound) async {
    try {
      if (!_configured) {
        _configured = true;
        await AudioPlayer.global.setAudioContext(AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
          respectSilence: true,
        ).build());
      }
      final player =
          _players[sound] ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      await player.stop();
      await player.play(AssetSource(sound.asset), mode: PlayerMode.lowLatency);
    } catch (error) {
      // A missing sound must never break a game.
      debugPrint('Sound ${sound.name} could not play: $error');
    }
  }
}
