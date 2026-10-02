/// The three possible shapes a piece can take on the board.
///
/// Pieces evolve in one direction only: SQUARE → PENTAGON → CIRCLE.
/// Circles cannot be flipped further.
enum PieceShape {
  square,
  pentagon,
  circle;

  /// Returns the next shape after flipping, or `null` if the piece
  /// cannot be flipped (i.e., it is already a Circle).
  PieceShape? get flipped {
    switch (this) {
      case PieceShape.square:
        return PieceShape.pentagon;
      case PieceShape.pentagon:
        return PieceShape.circle;
      case PieceShape.circle:
        return null;
    }
  }

  /// Whether this piece can be flipped to the next shape.
  bool get canFlip => this != PieceShape.circle;

  /// Display label for the shape.
  String get label {
    switch (this) {
      case PieceShape.square:
        return 'Square';
      case PieceShape.pentagon:
        return 'Pentagon';
      case PieceShape.circle:
        return 'Circle';
    }
  }

  /// Serialise to a string for Firebase storage.
  String toJson() => name.toUpperCase();

  /// Deserialise from a Firebase string.
  static PieceShape fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'SQUARE':
        return PieceShape.square;
      case 'PENTAGON':
        return PieceShape.pentagon;
      case 'CIRCLE':
        return PieceShape.circle;
      default:
        throw ArgumentError('Unknown PieceShape: $value');
    }
  }
}
