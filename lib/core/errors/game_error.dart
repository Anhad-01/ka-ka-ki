/// Base error class for all game-related errors.
class GameError implements Exception {
  final String message;
  const GameError(this.message);

  @override
  String toString() => 'GameError: $message';
}

/// Thrown when an invalid player action is performed.
class InvalidActionError extends GameError {
  const InvalidActionError(super.message);
}

/// Thrown when an error occurs related to room state or lifecycle.
class RoomError extends GameError {
  const RoomError(super.message);
}

/// Thrown when a network or connection error occurs.
class ConnectionError extends GameError {
  const ConnectionError(super.message);
}
