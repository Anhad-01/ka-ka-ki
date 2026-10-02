/// Game-wide constants for ka-kā-ki.
class GameConstants {
  GameConstants._();

  /// Board dimensions.
  static const int boardSize = 3;
  static const int totalCells = boardSize * boardSize;

  /// Player limits.
  static const int minPlayers = 2;
  static const int maxPlayers = 6;

  /// Turn duration in seconds.
  static const int turnDurationSeconds = 30;

  /// Maximum player name length.
  static const int maxNameLength = 20;

  /// Room code length.
  static const int roomCodeLength = 5;

  /// Characters used for room codes (excluding ambiguous: O/0, I/1, S/5).
  static const String roomCodeChars = 'ABCDEFGHJKLMNPQRTUVWXY2346789';
}
