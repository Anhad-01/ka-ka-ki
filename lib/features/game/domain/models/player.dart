/// Represents a player in the game.
class Player {
  /// Unique session ID (UUID) for this player.
  final String id;

  /// Display name chosen by the player.
  final String name;

  /// Whether the player is currently connected to the room.
  final bool connected;

  /// Timestamp when the player joined the room.
  final int joinedAt;

  const Player({
    required this.id,
    required this.name,
    this.connected = true,
    required this.joinedAt,
  });

  /// Create a copy with updated fields.
  Player copyWith({
    String? id,
    String? name,
    bool? connected,
    int? joinedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      connected: connected ?? this.connected,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  /// Serialise for Firebase.
  Map<String, dynamic> toJson() => {
        'name': name,
        'connected': connected,
        'joinedAt': joinedAt,
      };

  /// Deserialise from Firebase.
  factory Player.fromJson(String id, Map<String, dynamic> json) => Player(
        id: id,
        name: json['name']?.toString() ?? 'Player',
        connected: json['connected'] as bool? ?? false,
        joinedAt: _parseInt(json['joinedAt']),
      );

  /// Safely parse a timestamp that may be an int or a Firebase ServerValue map.
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Player && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player(id: $id, name: $name, connected: $connected)';
}
