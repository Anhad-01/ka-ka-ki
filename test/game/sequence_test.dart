import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/features/game/domain/models/piece_shape.dart';
import 'package:ka_ka_ki/features/game/domain/models/position.dart';
import 'package:ka_ka_ki/features/game/domain/models/board.dart';
import 'package:ka_ka_ki/features/game/domain/services/sequence_detector.dart';

void main() {
  group('Sequence', () {
    Board buildBoardWithLine(List<Position> positions, PieceShape shape) {
      Board board = Board.empty();
      for (final pos in positions) {
        board = board.withPiece(pos, shape);
      }
      return board;
    }

    test('Row 0, Row 1, Row 2 with all shapes', () {
      final rows = [
        [const Position(0, 0), const Position(0, 1), const Position(0, 2)],
        [const Position(1, 0), const Position(1, 1), const Position(1, 2)],
        [const Position(2, 0), const Position(2, 1), const Position(2, 2)],
      ];

      for (final row in rows) {
        for (final shape in PieceShape.values) {
          final board = buildBoardWithLine(row, shape);
          final sequences = SequenceDetector.detectSequences(board);
          expect(sequences.length, 1);
          expect(sequences.first.shape, shape);
          expect(sequences.first.positions, row);
        }
      }
    });

    test('Col 0, Col 1, Col 2 with all shapes', () {
      final cols = [
        [const Position(0, 0), const Position(1, 0), const Position(2, 0)],
        [const Position(0, 1), const Position(1, 1), const Position(2, 1)],
        [const Position(0, 2), const Position(1, 2), const Position(2, 2)],
      ];

      for (final col in cols) {
        for (final shape in PieceShape.values) {
          final board = buildBoardWithLine(col, shape);
          final sequences = SequenceDetector.detectSequences(board);
          expect(sequences.length, 1);
          expect(sequences.first.shape, shape);
          expect(sequences.first.positions, col);
        }
      }
    });

    test('Diagonal top-left to bottom-right with all shapes', () {
      final diag = [const Position(0, 0), const Position(1, 1), const Position(2, 2)];
      for (final shape in PieceShape.values) {
        final board = buildBoardWithLine(diag, shape);
        final sequences = SequenceDetector.detectSequences(board);
        expect(sequences.length, 1);
        expect(sequences.first.shape, shape);
      }
    });

    test('Diagonal top-right to bottom-left with all shapes', () {
      final diag = [const Position(0, 2), const Position(1, 1), const Position(2, 0)];
      for (final shape in PieceShape.values) {
        final board = buildBoardWithLine(diag, shape);
        final sequences = SequenceDetector.detectSequences(board);
        expect(sequences.length, 1);
        expect(sequences.first.shape, shape);
      }
    });

    test('Mixed shapes do not form sequence', () {
      final board = Board.empty()
          .withPiece(const Position(0, 0), PieceShape.square)
          .withPiece(const Position(0, 1), PieceShape.pentagon)
          .withPiece(const Position(0, 2), PieceShape.square);
      
      final sequences = SequenceDetector.detectSequences(board);
      expect(sequences.isEmpty, isTrue);
    });

    test('Empty cells do not form sequence', () {
      final board = Board.empty();
      final sequences = SequenceDetector.detectSequences(board);
      expect(sequences.isEmpty, isTrue);
    });

    test('Multiple sequences from one board', () {
      final board = Board.empty()
          // Row 0
          .withPiece(const Position(0, 0), PieceShape.circle)
          .withPiece(const Position(0, 1), PieceShape.circle)
          .withPiece(const Position(0, 2), PieceShape.circle)
          // Col 0
          .withPiece(const Position(1, 0), PieceShape.circle)
          .withPiece(const Position(2, 0), PieceShape.circle);
      
      final sequences = SequenceDetector.detectSequences(board);
      expect(sequences.length, 2);
    });

    test('No sequences on empty board', () {
      expect(SequenceDetector.detectSequences(Board.empty()).isEmpty, isTrue);
    });
  });
}
