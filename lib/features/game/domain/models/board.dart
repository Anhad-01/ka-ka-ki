import 'piece_shape.dart';
import 'position.dart';

/// Represents the 3×3 game board.
///
/// Each cell is either `null` (empty) or contains a [PieceShape].
/// The board is stored as a flat list of 9 elements, indexed row-major:
///   [0,1,2]  ← row 0
///   [3,4,5]  ← row 1
///   [6,7,8]  ← row 2
class Board {
  /// The 9 cells of the board. `null` means empty.
  final List<PieceShape?> _cells;

  /// Create a board from a list of 9 cells.
  Board(List<PieceShape?> cells)
      : assert(cells.length == 9, 'Board must have exactly 9 cells'),
        _cells = List<PieceShape?>.unmodifiable(cells);

  /// Create an empty board.
  factory Board.empty() => Board(List<PieceShape?>.filled(9, null));

  /// Get the piece at the given position, or `null` if empty.
  PieceShape? at(Position pos) {
    assert(pos.isValid, 'Position out of bounds: $pos');
    return _cells[pos.index];
  }

  /// Get the piece at the given flat index, or `null` if empty.
  PieceShape? atIndex(int index) {
    assert(index >= 0 && index < 9, 'Index must be 0–8');
    return _cells[index];
  }

  /// Whether the cell at [pos] is empty.
  bool isEmpty(Position pos) => at(pos) == null;

  /// Whether all 9 cells are occupied.
  bool get isFull => _cells.every((cell) => cell != null);

  /// The number of occupied cells.
  int get occupiedCount => _cells.where((cell) => cell != null).length;

  /// Create a new board with the cell at [pos] set to [shape].
  Board withPiece(Position pos, PieceShape? shape) {
    final newCells = List<PieceShape?>.from(_cells);
    newCells[pos.index] = shape;
    return Board(newCells);
  }

  /// Create a new board with the piece moved from [from] to [to].
  /// The [from] cell becomes empty, the [to] cell gets the piece.
  Board withMove(Position from, Position to) {
    final piece = at(from);
    assert(piece != null, 'Cannot move from an empty cell');
    assert(isEmpty(to), 'Cannot move to an occupied cell');
    final newCells = List<PieceShape?>.from(_cells);
    newCells[from.index] = null;
    newCells[to.index] = piece;
    return Board(newCells);
  }

  /// Create a new board with the piece at [pos] flipped to its next shape.
  Board withFlip(Position pos) {
    final piece = at(pos);
    assert(piece != null, 'Cannot flip an empty cell');
    final flipped = piece!.flipped;
    assert(flipped != null, 'Cannot flip a circle');
    return withPiece(pos, flipped);
  }

  /// Return a copy of the cells as a mutable list.
  List<PieceShape?> get cells => List<PieceShape?>.from(_cells);

  /// Serialise for Firebase. Stores each cell as a string.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    for (var i = 0; i < 9; i++) {
      map[i.toString()] = _cells[i]?.toJson() ?? 'EMPTY';
    }
    return map;
  }

  /// Deserialise from Firebase.
  factory Board.fromJson(dynamic json) {
    if (json is List) {
      final cells = List<PieceShape?>.generate(9, (i) {
        if (i < json.length) {
          final value = json[i]?.toString();
          if (value == null || value == 'EMPTY') return null;
          return PieceShape.fromJson(value);
        }
        return null;
      });
      return Board(cells);
    }
    if (json is Map) {
      final cells = List<PieceShape?>.generate(9, (i) {
        final rawVal = json[i.toString()] ?? json[i];
        final value = rawVal?.toString();
        if (value == null || value == 'EMPTY') return null;
        return PieceShape.fromJson(value);
      });
      return Board(cells);
    }
    return Board.empty();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Board) return false;
    for (var i = 0; i < 9; i++) {
      if (_cells[i] != other._cells[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_cells);

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final piece = _cells[r * 3 + c];
        buffer.write(piece == null ? '.' : piece.label[0]);
        if (c < 2) buffer.write(' ');
      }
      if (r < 2) buffer.writeln();
    }
    return buffer.toString();
  }
}
