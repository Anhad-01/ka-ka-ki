import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/features/game/domain/models/piece_shape.dart';
import 'package:ka_ka_ki/features/game/domain/models/position.dart';
import 'package:ka_ka_ki/features/game/domain/models/board.dart';
import 'package:ka_ka_ki/features/game/domain/services/move_validator.dart';

void main() {
  group('Flip', () {
    test('Square → Pentagon (PieceShape.flipped)', () {
      expect(PieceShape.square.flipped, PieceShape.pentagon);
    });

    test('Pentagon → Circle', () {
      expect(PieceShape.pentagon.flipped, PieceShape.circle);
    });

    test('Circle cannot flip (flipped returns null)', () {
      expect(PieceShape.circle.flipped, isNull);
    });

    test('Circle canFlip is false', () {
      expect(PieceShape.square.canFlip, isTrue);
      expect(PieceShape.pentagon.canFlip, isTrue);
      expect(PieceShape.circle.canFlip, isFalse);
    });

    test('MoveValidator.validateFlip on empty cell returns error', () {
      final board = Board.empty();
      final error = MoveValidator.validateFlip(board, const Position(1, 1));
      expect(error, 'Cell is empty.');
    });

    test('MoveValidator.validateFlip on circle returns error', () {
      final board = Board.empty().withPiece(const Position(0, 0), PieceShape.circle);
      final error = MoveValidator.validateFlip(board, const Position(0, 0));
      expect(error, 'Piece cannot be flipped.');
    });

    test('Board.withFlip works correctly', () {
      final pos = const Position(2, 2);
      var board = Board.empty().withPiece(pos, PieceShape.square);
      
      board = board.withFlip(pos);
      expect(board.at(pos), PieceShape.pentagon);
      
      board = board.withFlip(pos);
      expect(board.at(pos), PieceShape.circle);
      
      expect(() => board.withFlip(pos), throwsA(isA<AssertionError>()));
    });
  });
}
