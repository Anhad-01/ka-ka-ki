import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/features/game/domain/models/piece_shape.dart';
import 'package:ka_ka_ki/features/game/domain/models/position.dart';
import 'package:ka_ka_ki/features/game/domain/models/board.dart';
import 'package:ka_ka_ki/features/game/domain/services/move_validator.dart';

void main() {
  group('Board', () {
    test('Empty board creation (all cells null)', () {
      final board = Board.empty();
      for (int i = 0; i < 9; i++) {
        expect(board.atIndex(i), isNull);
      }
      expect(board.isFull, isFalse);
      expect(board.occupiedCount, 0);
    });

    test('Place piece on empty cell', () {
      final board = Board.empty();
      final pos = const Position(1, 1);
      final newBoard = board.withPiece(pos, PieceShape.square);
      
      expect(newBoard.at(pos), PieceShape.square);
      expect(newBoard.occupiedCount, 1);
      // Original unchanged
      expect(board.at(pos), isNull);
    });

    test('Cannot place on occupied cell (via MoveValidator.validatePlace)', () {
      final pos = const Position(0, 0);
      final board = Board.empty().withPiece(pos, PieceShape.square);
      
      final error = MoveValidator.validatePlace(board, pos);
      expect(error, 'Cell is not empty.');
    });

    test('Valid orthogonal movement (up/down/left/right)', () {
      final pos = const Position(1, 1);
      final board = Board.empty().withPiece(pos, PieceShape.pentagon);
      
      final upPos = pos.move(Direction.up);
      final boardUp = board.withMove(pos, upPos);
      expect(boardUp.at(upPos), PieceShape.pentagon);
      expect(boardUp.at(pos), isNull);
      
      final downPos = pos.move(Direction.down);
      final boardDown = board.withMove(pos, downPos);
      expect(boardDown.at(downPos), PieceShape.pentagon);
      
      final leftPos = pos.move(Direction.left);
      final boardLeft = board.withMove(pos, leftPos);
      expect(boardLeft.at(leftPos), PieceShape.pentagon);
      
      final rightPos = pos.move(Direction.right);
      final boardRight = board.withMove(pos, rightPos);
      expect(boardRight.at(rightPos), PieceShape.pentagon);
    });

    test('Cannot move outside board bounds', () {
      final pos = const Position(0, 0); // Top-left
      final upPos = pos.move(Direction.up);
      expect(upPos.isValid, isFalse);
      expect(() => Board.empty().withPiece(pos, PieceShape.square).withMove(pos, upPos), throwsA(isA<AssertionError>()));
    });

    test('Cannot move into occupied cell', () {
      final pos1 = const Position(1, 1);
      final pos2 = const Position(1, 2);
      final board = Board.empty()
          .withPiece(pos1, PieceShape.square)
          .withPiece(pos2, PieceShape.circle);
          
      expect(() => board.withMove(pos1, pos2), throwsA(isA<AssertionError>()));
    });

    test('Diagonal movement rejected (Direction enum only has 4 values so this is inherently blocked)', () {
      // By definition of Direction enum, you can't construct a diagonal direction.
      expect(Direction.values.length, 4);
      expect(Direction.values, containsAll([Direction.up, Direction.down, Direction.left, Direction.right]));
    });

    test('Shape unchanged after move', () {
      final pos = const Position(0, 1);
      final board = Board.empty().withPiece(pos, PieceShape.circle);
      final newPos = pos.move(Direction.down);
      final newBoard = board.withMove(pos, newPos);
      expect(newBoard.at(newPos), PieceShape.circle);
    });

    test('Board.isFull correctly detects full board', () {
      Board board = Board.empty();
      expect(board.isFull, isFalse);
      for (int i = 0; i < 9; i++) {
        board = board.withPiece(Position.fromIndex(i), PieceShape.square);
      }
      expect(board.isFull, isTrue);
    });

    test('Board equality and toString', () {
      final board1 = Board.empty().withPiece(const Position(0, 0), PieceShape.square);
      final board2 = Board.empty().withPiece(const Position(0, 0), PieceShape.square);
      final board3 = Board.empty().withPiece(const Position(0, 0), PieceShape.circle);
      
      expect(board1, equals(board2));
      expect(board1, isNot(equals(board3)));
      
      expect(board1.toString().contains('S'), isTrue); // 'Square' label[0]
      expect(board3.toString().contains('C'), isTrue); // 'Circle' label[0]
    });
  });
}
