import '../../../game/domain/models/player.dart';

/// The status of a room.
enum RoomStatus {
  /// Room is open, waiting for players to join.
  waiting,

  /// A game is in progress.
  playing,

  /// The game has ended, players can Play Again or Leave.
  finished;

  String toJson() => name.toUpperCase();

  static RoomStatus fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'WAITING':
        return RoomStatus.waiting;
      case 'PLAYING':
        return RoomStatus.playing;
      case 'FINISHED':
        return RoomStatus.finished;
      default:
        throw ArgumentError('Unknown RoomStatus: $value');
    }
  }
}

/// The state of a room (lobby + game container).
class RoomState {
  /// The short alphanumeric room code (e.g. "A7K92").
  final String roomCode;

  /// Current room status.
  final RoomStatus status;

  /// Player ID of the current host.
  final String hostPlayerId;

  /// All players currently in the room, keyed by player ID.
  final Map<String, Player> players;

  /// Timestamp when the room was created.
  final int createdAt;

  const RoomState({
    required this.roomCode,
    required this.status,
    required this.hostPlayerId,
    required this.players,
    required this.createdAt,
  });

  /// The host player.
  Player? get host => players[hostPlayerId];

  /// List of connected players.
  List<Player> get connectedPlayers =>
      players.values.where((p) => p.connected).toList();

  /// Number of players currently in the room.
  int get playerCount => players.length;

  /// Whether the room has space for more players.
  bool get isFull => playerCount >= 6;

  /// Whether the room has enough players to start a game.
  bool get canStart => connectedPlayers.length >= 2;

  /// Create a copy with updated fields.
  RoomState copyWith({
    String? roomCode,
    RoomStatus? status,
    String? hostPlayerId,
    Map<String, Player>? players,
    int? createdAt,
  }) {
    return RoomState(
      roomCode: roomCode ?? this.roomCode,
      status: status ?? this.status,
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serialise for Firebase.
  Map<String, dynamic> toJson() => {
        'status': status.toJson(),
        'hostPlayerId': hostPlayerId,
        'players': players.map((id, player) => MapEntry(id, player.toJson())),
        'createdAt': createdAt,
      };

  /// Deserialise from Firebase.
  factory RoomState.fromJson(String roomCode, Map<String, dynamic> json) {
    final players = <String, Player>{};
    final rawPlayers = json['players'];
    if (rawPlayers is Map) {
      rawPlayers.forEach((id, data) {
        if (data is Map) {
          final playerMap = Map<String, dynamic>.from(data);
          players[id.toString()] = Player.fromJson(id.toString(), playerMap);
        }
      });
    }

    return RoomState(
      roomCode: roomCode,
      status: RoomStatus.fromJson(json['status']?.toString() ?? 'WAITING'),
      hostPlayerId: json['hostPlayerId']?.toString() ?? '',
      players: players,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  /// Safely parse a value that may be an int or a Firebase ServerValue map.
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0; // ServerValue.timestamp placeholder not yet resolved
  }

  @override
  String toString() =>
      'RoomState(code: $roomCode, status: $status, players: ${players.length})';
}
