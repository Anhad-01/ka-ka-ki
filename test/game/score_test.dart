import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/features/game/domain/models/piece_shape.dart';
import 'package:ka_ka_ki/features/game/domain/models/position.dart';
import 'package:ka_ka_ki/features/game/domain/models/board.dart';
import 'package:ka_ka_ki/features/game/domain/services/score_calculator.dart';

void main() {
  group('ScoreCalculator', () {
    test('New sequence = +1 point', () {
      final before = Board.empty()
          .withPiece(const Position(0, 0), PieceShape.square)
          .withPiece(const Position(0, 1), PieceShape.square);
      final after = before.withPiece(const Position(0, 2), PieceShape.square);
      
      expect(ScoreCalculator.calculateNewPoints(before, after), 1);
    });

    test('Multiple new sequences from one action = multiple points', () {
      final before = Board.empty()
          .withPiece(const Position(0, 0), PieceShape.pentagon)
          .withPiece(const Position(0, 1), PieceShape.pentagon)
          .withPiece(const Position(1, 2), PieceShape.pentagon)
          .withPiece(const Position(2, 2), PieceShape.pentagon);
      
      // Placing at (0, 2) completes Row 0 and Col 2
      final after = before.withPiece(const Position(0, 2), PieceShape.pentagon);
      
      expect(ScoreCalculator.calculateNewPoints(before, after), 2);
    });

    test('Existing sequence not re-scored (same sequence before and after = 0 new)', () {
      final board = Board.empty()
          .withPiece(const Position(1, 0), PieceShape.circle)
          .withPiece(const Position(1, 1), PieceShape.circle)
          .withPiece(const Position(1, 2), PieceShape.circle);
          
      // Make a move that doesn't affect the sequence
      final after = board.withPiece(const Position(0, 0), PieceShape.square);
      
      expect(ScoreCalculator.calculateNewPoints(board, after), 0);
    });

    test('Destroying a sequence does not subtract (score stays same or increases)', () {
      final before = Board.empty()
          .withPiece(const Position(0, 0), PieceShape.square)
          .withPiece(const Position(0, 1), PieceShape.square)
          .withPiece(const Position(0, 2), PieceShape.square);
          
      // Move a piece from the sequence away, breaking it
      final after = before.withMove(const Position(0, 2), const Position(1, 2));
      
      expect(ScoreCalculator.calculateNewPoints(before, after), 0); // No new points, no negative points
    });

    test('No new sequences = 0 points', () {
      final before = Board.empty();
      final after = before.withPiece(const Position(1, 1), PieceShape.square);
      
      expect(ScoreCalculator.calculateNewPoints(before, after), 0);
    });
  });
}
