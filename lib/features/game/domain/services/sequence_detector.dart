import '../models/models.dart';

class SequenceLine {
  final List<Position> positions;
  final PieceShape shape;

  const SequenceLine(this.positions, this.shape);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SequenceLine &&
          _listsEqual(positions, other.positions) &&
          shape == other.shape;

  @override
  int get hashCode => Object.hash(Object.hashAll(positions), shape);

  static bool _listsEqual(List<Position> a, List<Position> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class SequenceDetector {
  static final List<List<Position>> lines = [
    // Rows
    [const Position(0, 0), const Position(0, 1), const Position(0, 2)],
    [const Position(1, 0), const Position(1, 1), const Position(1, 2)],
    [const Position(2, 0), const Position(2, 1), const Position(2, 2)],
    // Columns
    [const Position(0, 0), const Position(1, 0), const Position(2, 0)],
    [const Position(0, 1), const Position(1, 1), const Position(2, 1)],
    [const Position(0, 2), const Position(1, 2), const Position(2, 2)],
    // Diagonals
    [const Position(0, 0), const Position(1, 1), const Position(2, 2)],
    [const Position(0, 2), const Position(1, 1), const Position(2, 0)],
  ];

  static Set<SequenceLine> detectSequences(Board board) {
    final sequences = <SequenceLine>{};
    for (final line in lines) {
      final p1 = board.at(line[0]);
      final p2 = board.at(line[1]);
      final p3 = board.at(line[2]);
      
      if (p1 != null && p1 == p2 && p2 == p3) {
        sequences.add(SequenceLine(line, p1));
      }
    }
    return sequences;
  }
}
