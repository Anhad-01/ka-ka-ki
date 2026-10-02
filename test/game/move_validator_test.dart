import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/features/game/domain/models/piece_shape.dart';
import 'package:ka_ka_ki/features/game/domain/models/position.dart';
import 'package:ka_ka_ki/features/game/domain/models/board.dart';
import 'package:ka_ka_ki/features/game/domain/models/game_action.dart';
import 'package:ka_ka_ki/features/game/domain/services/move_validator.dart';

void main() {
  group('MoveValidator', () {
    test('validatePlace on empty cell returns null (valid)', () {
      final board = Board.empty();
      expect(MoveValidator.validatePlace(board, const Position(0, 0)), isNull);
    });

    test('validatePlace on occupied cell returns error', () {
      final pos = const Position(1, 1);
      final board = Board.empty().withPiece(pos, PieceShape.square);
      expect(MoveValidator.validatePlace(board, pos), 'Cell is not empty.');
    });

    test('validateFlip on square returns null', () {
      final pos = const Position(0, 0);
      final board = Board.empty().withPiece(pos, PieceShape.square);
      expect(MoveValidator.validateFlip(board, pos), isNull);
    });

    test('validateFlip on circle returns error', () {
      final pos = const Position(0, 0);
      final board = Board.empty().withPiece(pos, PieceShape.circle);
      expect(MoveValidator.validateFlip(board, pos), 'Piece cannot be flipped.');
    });

    test('validateMove valid cases', () {
      final pos = const Position(1, 1);
      final board = Board.empty().withPiece(pos, PieceShape.pentagon);
      expect(MoveValidator.validateMove(board, pos, Direction.up), isNull);
      expect(MoveValidator.validateMove(board, pos, Direction.down), isNull);
      expect(MoveValidator.validateMove(board, pos, Direction.left), isNull);
      expect(MoveValidator.validateMove(board, pos, Direction.right), isNull);
    });

    test('validateMove board full returns error', () {
      Board board = Board.empty();
      for (int i = 0; i < 9; i++) {
        board = board.withPiece(Position.fromIndex(i), PieceShape.square);
      }
      expect(MoveValidator.validateMove(board, const Position(0, 0), Direction.right),
          'Board is full. Movement is disabled.');
    });

    test('validateMove destination occupied returns error', () {
      final pos1 = const Position(0, 0);
      final pos2 = const Position(0, 1);
      final board = Board.empty()
          .withPiece(pos1, PieceShape.square)
          .withPiece(pos2, PieceShape.circle);
          
      expect(MoveValidator.validateMove(board, pos1, Direction.right), 'Destination cell is not empty.');
    });

    test('validateMove out of bounds returns error', () {
      final pos = const Position(0, 0);
      final board = Board.empty().withPiece(pos, PieceShape.square);
      expect(MoveValidator.validateMove(board, pos, Direction.up), 'Invalid destination position.');
      expect(MoveValidator.validateMove(board, pos, Direction.left), 'Invalid destination position.');
    });

    test('isValidAction for each action type', () {
      final pos = const Position(1, 1);
      final board = Board.empty().withPiece(pos, PieceShape.square);

      expect(MoveValidator.isValidAction(board, const PlaceAction(Position(0, 0))), isTrue);
      expect(MoveValidator.isValidAction(board, const PlaceAction(Position(1, 1))), isFalse);

      expect(MoveValidator.isValidAction(board, const FlipAction(Position(1, 1))), isTrue);
      expect(MoveValidator.isValidAction(board, const FlipAction(Position(0, 0))), isFalse);

      expect(MoveValidator.isValidAction(board, const MoveAction(Position(1, 1), Direction.up)), isTrue);
      expect(MoveValidator.isValidAction(board, const MoveAction(Position(1, 1), Direction.right)), isTrue);
    });

    test('getLegalActions on empty board (9 place actions)', () {
      final board = Board.empty();
      final actions = MoveValidator.getLegalActions(board);
      
      expect(actions.length, 9);
      expect(actions.every((a) => a is PlaceAction), isTrue);
    });

    test('getLegalActions on full board (only flips, no moves/places)', () {
      Board board = Board.empty();
      for (int i = 0; i < 9; i++) {
        board = board.withPiece(Position.fromIndex(i), PieceShape.square);
      }
      
      final actions = MoveValidator.getLegalActions(board);
      expect(actions.length, 9);
      expect(actions.every((a) => a is FlipAction), isTrue);
    });

    test('getLegalActions on partially filled board', () {
      final board = Board.empty().withPiece(const Position(1, 1), PieceShape.square);
      final actions = MoveValidator.getLegalActions(board);
      
      final places = actions.whereType<PlaceAction>().length;
      final flips = actions.whereType<FlipAction>().length;
      final moves = actions.whereType<MoveAction>().length;
      
      expect(places, 8); // 8 empty cells
      expect(flips, 1);  // 1 square can flip
      expect(moves, 4);  // 1 piece can move in 4 directions
    });
  });
}
