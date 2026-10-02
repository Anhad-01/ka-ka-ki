import '../models/models.dart';
import 'move_validator.dart';

class GameEndDetector {
  static bool hasAnyLegalAction(Board board) {
    return MoveValidator.getLegalActions(board).isNotEmpty;
  }

  static bool isGameOver(Board board) {
    return !hasAnyLegalAction(board);
  }
}
