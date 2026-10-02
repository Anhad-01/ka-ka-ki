import '../models/models.dart';

class MoveValidator {
  static String? validatePlace(Board board, Position pos) {
    if (!pos.isValid) return 'Invalid position.';
    if (!board.isEmpty(pos)) return 'Cell is not empty.';
    return null;
  }

  static String? validateFlip(Board board, Position pos) {
    if (!pos.isValid) return 'Invalid position.';
    final piece = board.at(pos);
    if (piece == null) return 'Cell is empty.';
    if (!piece.canFlip) return 'Piece cannot be flipped.';
    return null;
  }

  static String? validateMove(Board board, Position from, Direction dir) {
    if (board.isFull) return 'Board is full. Movement is disabled.';
    if (!from.isValid) return 'Invalid starting position.';
    
    final piece = board.at(from);
    if (piece == null) return 'No piece at starting position.';
    
    final to = from.move(dir);
    if (!to.isValid) return 'Invalid destination position.';
    if (!board.isEmpty(to)) return 'Destination cell is not empty.';
    
    return null;
  }

  static bool isValidAction(Board board, GameAction action) {
    if (action is PlaceAction) {
      return validatePlace(board, action.position) == null;
    } else if (action is FlipAction) {
      return validateFlip(board, action.position) == null;
    } else if (action is MoveAction) {
      return validateMove(board, action.position, action.direction) == null;
    }
    return false;
  }

  static List<GameAction> getLegalActions(Board board) {
    final actions = <GameAction>[];
    final isBoardFull = board.isFull;
    
    for (int i = 0; i < 9; i++) {
      final pos = Position.fromIndex(i);
      
      // Place
      if (validatePlace(board, pos) == null) {
        actions.add(PlaceAction(pos));
      }
      
      // Flip
      if (validateFlip(board, pos) == null) {
        actions.add(FlipAction(pos));
      }
      
      // Move
      if (!isBoardFull) {
        for (final dir in Direction.values) {
          if (validateMove(board, pos, dir) == null) {
            actions.add(MoveAction(pos, dir));
          }
        }
      }
    }
    
    return actions;
  }
}
