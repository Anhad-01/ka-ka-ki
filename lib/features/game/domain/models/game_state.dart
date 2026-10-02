import 'board.dart';

/// The status of a game within a room.
enum GameStatus {
  /// Game is being played.
  playing,

  /// Game has ended — showing final scores.
  finished;

  String toJson() => name.toUpperCase();

  static GameStatus fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'PLAYING':
        return GameStatus.playing;
      case 'FINISHED':
        return GameStatus.finished;
      default:
        throw ArgumentError('Unknown GameStatus: $value');
    }
  }
}

/// The complete state of an active game.
///
/// This is an immutable snapshot — all mutations produce new instances.
class GameState {
  /// The current board.
  final Board board;

  /// Ordered list of player IDs defining turn order.
  final List<String> turnOrder;

  /// Index into [turnOrder] of the player whose turn it is.
  final int currentPlayerIndex;

  /// Map of player ID → score.
  final Map<String, int> scores;

  /// Current game status.
  final GameStatus status;

  /// Server timestamp when the current turn started.
  final int turnStartedAt;

  /// Unique identifier for this game session (allows Play Again).
  final String gameId;

  const GameState({
    required this.board,
    required this.turnOrder,
    required this.currentPlayerIndex,
    required this.scores,
    required this.status,
    required this.turnStartedAt,
    required this.gameId,
  });

  /// The player ID of whoever's turn it is.
  String get currentPlayerId => turnOrder[currentPlayerIndex];

  /// Create a copy with updated fields.
  GameState copyWith({
    Board? board,
    List<String>? turnOrder,
    int? currentPlayerIndex,
    Map<String, int>? scores,
    GameStatus? status,
    int? turnStartedAt,
    String? gameId,
  }) {
    return GameState(
      board: board ?? this.board,
      turnOrder: turnOrder ?? this.turnOrder,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      scores: scores ?? this.scores,
      status: status ?? this.status,
      turnStartedAt: turnStartedAt ?? this.turnStartedAt,
      gameId: gameId ?? this.gameId,
    );
  }

  /// Serialise for Firebase.
  Map<String, dynamic> toJson() => {
        'board': board.toJson(),
        'currentPlayerIndex': currentPlayerIndex,
        'turnOrder': {
          for (var i = 0; i < turnOrder.length; i++) i.toString(): turnOrder[i],
        },
        'scores': scores,
        'status': status.toJson(),
        'turnStartedAt': turnStartedAt,
        'gameId': gameId,
      };

  /// Deserialise from Firebase.
  factory GameState.fromJson(Map<String, dynamic> json) {
    final turnOrder = <String>[];
    final rawTurnOrder = json['turnOrder'];
    if (rawTurnOrder is List) {
      turnOrder.addAll(rawTurnOrder.whereType<Object>().map((e) => e.toString()));
    } else if (rawTurnOrder is Map) {
      for (var i = 0; i < rawTurnOrder.length; i++) {
        final val = rawTurnOrder[i.toString()] ?? rawTurnOrder[i];
        if (val != null) turnOrder.add(val.toString());
      }
    }

    final scores = <String, int>{};
    final rawScores = json['scores'];
    if (rawScores is Map) {
      rawScores.forEach((k, v) {
        if (v is num) {
          scores[k.toString()] = v.toInt();
        }
      });
    }

    return GameState(
      board: Board.fromJson(json['board']),
      turnOrder: turnOrder,
      currentPlayerIndex: _parseInt(json['currentPlayerIndex']),
      scores: scores,
      status: GameStatus.fromJson(json['status']?.toString() ?? 'PLAYING'),
      turnStartedAt: _parseInt(json['turnStartedAt']),
      gameId: json['gameId']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  @override
  String toString() =>
      'GameState(turn: $currentPlayerId, status: $status, scores: $scores)';
}
