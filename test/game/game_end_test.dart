import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/features/game/domain/models/piece_shape.dart';
import 'package:ka_ka_ki/features/game/domain/models/position.dart';
import 'package:ka_ka_ki/features/game/domain/models/board.dart';
import 'package:ka_ka_ki/features/game/domain/services/game_end_detector.dart';

void main() {
  group('GameEndDetector', () {
    test('Empty board is not game over (can place)', () {
      final board = Board.empty();
      expect(GameEndDetector.isGameOver(board), isFalse);
    });

    test('Board with all circles and full board IS game over (no legal actions)', () {
      Board board = Board.empty();
      for (int i = 0; i < 9; i++) {
        board = board.withPiece(Position.fromIndex(i), PieceShape.circle);
      }
      expect(GameEndDetector.isGameOver(board), isTrue);
      expect(GameEndDetector.hasAnyLegalAction(board), isFalse);
    });

    test('Board with some squares on full board is NOT over (can flip)', () {
      Board board = Board.empty();
      for (int i = 0; i < 8; i++) {
        board = board.withPiece(Position.fromIndex(i), PieceShape.circle);
      }
      board = board.withPiece(const Position(2, 2), PieceShape.square);
      
      expect(GameEndDetector.isGameOver(board), isFalse);
      expect(GameEndDetector.hasAnyLegalAction(board), isTrue);
    });

    test('Partially filled board is NOT over', () {
      final board = Board.empty()
          .withPiece(const Position(0, 0), PieceShape.circle)
          .withPiece(const Position(1, 1), PieceShape.circle);
          
      expect(GameEndDetector.isGameOver(board), isFalse);
    });
  });
}
