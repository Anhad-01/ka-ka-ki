/// A position on the 3×3 game board.
///
/// Row 0 is the top row, column 0 is the left column.
/// Valid coordinates are 0–2 for both row and col.
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  /// Whether this position is within the 3×3 board bounds.
  bool get isValid => row >= 0 && row < 3 && col >= 0 && col < 3;

  /// Convert to a flat index (0–8) for the board array.
  int get index => row * 3 + col;

  /// Create a Position from a flat index (0–8).
  factory Position.fromIndex(int index) {
    assert(index >= 0 && index < 9, 'Index must be 0–8');
    return Position(index ~/ 3, index % 3);
  }

  /// Return the position after moving in the given direction.
  Position move(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(row - 1, col);
      case Direction.down:
        return Position(row + 1, col);
      case Direction.left:
        return Position(row, col - 1);
      case Direction.right:
        return Position(row, col + 1);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode << 1);

  @override
  String toString() => 'Position($row, $col)';

  /// Serialise for Firebase.
  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  /// Deserialise from Firebase.
  factory Position.fromJson(Map<String, dynamic> json) =>
      Position(json['row'] as int, json['col'] as int);
}

/// The four orthogonal directions a piece can move.
enum Direction {
  up,
  down,
  left,
  right;

  /// Serialise to string.
  String toJson() => name.toUpperCase();

  /// Deserialise from string.
  static Direction fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'UP':
        return Direction.up;
      case 'DOWN':
        return Direction.down;
      case 'LEFT':
        return Direction.left;
      case 'RIGHT':
        return Direction.right;
      default:
        throw ArgumentError('Unknown Direction: $value');
    }
  }
}
