import 'dart:math';

import '../constants/game_constants.dart';

/// Utility class that generates random room codes for game sessions.
class RoomCodeGenerator {
  RoomCodeGenerator._();

  static final Random _defaultRandom = Random();

  /// Generates a random room code of length [GameConstants.roomCodeLength]
  /// using characters from [GameConstants.roomCodeChars].
  ///
  /// Optionally accepts a custom [Random] instance (e.g. for testing).
  static String generate([Random? random]) {
    final rng = random ?? _defaultRandom;
    final chars = GameConstants.roomCodeChars;
    final buffer = StringBuffer();
    for (var i = 0; i < GameConstants.roomCodeLength; i++) {
      buffer.write(chars[rng.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
