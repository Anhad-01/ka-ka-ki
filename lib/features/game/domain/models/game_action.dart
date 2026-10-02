import 'position.dart';

/// Represents a single game action a player can take on their turn.
///
/// Exactly one action is allowed per turn. The three variants are:
/// - [PlaceAction]: Place a new Square on an empty cell.
/// - [FlipAction]: Flip an existing piece to its next shape.
/// - [MoveAction]: Move an existing piece one cell orthogonally.
sealed class GameAction {
  const GameAction();

  /// Serialise for Firebase.
  Map<String, dynamic> toJson();

  /// Deserialise from Firebase.
  factory GameAction.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'PLACE':
        return PlaceAction(Position.fromJson(json['position'] as Map<String, dynamic>));
      case 'FLIP':
        return FlipAction(Position.fromJson(json['position'] as Map<String, dynamic>));
      case 'MOVE':
        return MoveAction(
          Position.fromJson(json['position'] as Map<String, dynamic>),
          Direction.fromJson(json['direction'] as String),
        );
      default:
        throw ArgumentError('Unknown GameAction type: ${json['type']}');
    }
  }
}

/// Place a new Square on an empty cell.
class PlaceAction extends GameAction {
  final Position position;

  const PlaceAction(this.position);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'PLACE',
        'position': position.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceAction && position == other.position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() => 'PlaceAction($position)';
}

/// Flip an existing piece to its next shape.
class FlipAction extends GameAction {
  final Position position;

  const FlipAction(this.position);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'FLIP',
        'position': position.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlipAction && position == other.position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() => 'FlipAction($position)';
}

/// Move an existing piece one cell in an orthogonal direction.
class MoveAction extends GameAction {
  final Position position;
  final Direction direction;

  const MoveAction(this.position, this.direction);

  /// The destination cell after this move.
  Position get destination => position.move(direction);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'MOVE',
        'position': position.toJson(),
        'direction': direction.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoveAction &&
          position == other.position &&
          direction == other.direction;

  @override
  int get hashCode => position.hashCode ^ direction.hashCode;

  @override
  String toString() => 'MoveAction($position, $direction)';
}
