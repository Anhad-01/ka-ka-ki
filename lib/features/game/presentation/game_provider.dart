import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/models.dart';
import '../domain/services/services.dart';
import '../../room/data/firebase_room_service.dart';
import '../../room/domain/models/room_state.dart';

/// Provides game state and handles game actions.
///
/// Listens to Firebase for real-time updates and applies game rules
/// using the pure domain services.
class GameProvider extends ChangeNotifier {
  final String roomCode;
  final String playerId;
  final String playerName;
  final FirebaseRoomService _roomService;

  GameState? _gameState;
  RoomState? _roomState;
  bool _isLoading = false;
  String? _error;
  Timer? _turnTimer;
  int _countdown = 30;

  StreamSubscription? _roomSubscription;
  StreamSubscription? _gameSubscription;
  StreamSubscription? _offsetSubscription;
  int _serverOffset = 0;
  bool _advancing = false;

  GameProvider({
    required this.roomCode,
    required this.playerId,
    required this.playerName,
    FirebaseRoomService? roomService,
  }) : _roomService = roomService ?? FirebaseRoomService() {
    _startListening();
  }

  // ── Getters ──────────────────────────────────────────────────

  GameState? get gameState => _gameState;
  RoomState? get roomState => _roomState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get countdown => _countdown;

  bool get isMyTurn =>
      _gameState != null &&
      _gameState!.status == GameStatus.playing &&
      _gameState!.currentPlayerId == playerId;

  bool get isGameOver =>
      _gameState?.status == GameStatus.finished;

  String? get currentPlayerName {
    if (_gameState == null || _roomState == null) return null;
    final currentId = _gameState!.currentPlayerId;
    return _roomState!.players[currentId]?.name;
  }

  List<MapEntry<String, int>> get sortedScores {
    if (_gameState == null) return [];
    final entries = _gameState!.scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String? get winnerName {
    if (!isGameOver || _gameState == null || _roomState == null) return null;
    final sorted = sortedScores;
    if (sorted.isEmpty) return null;
    final winnerId = sorted.first.key;
    return _roomState!.players[winnerId]?.name ?? 'Unknown';
  }

  int get winnerScore {
    if (!isGameOver || _gameState == null) return 0;
    final sorted = sortedScores;
    if (sorted.isEmpty) return 0;
    return sorted.first.value;
  }

  List<String> get winnerIds {
    if (!isGameOver || _gameState == null) return [];
    final sorted = sortedScores;
    if (sorted.isEmpty) return [];
    final topScore = sorted.first.value;
    return sorted.where((e) => e.value == topScore).map((e) => e.key).toList();
  }

  // ── Firebase Listening ───────────────────────────────────────

  void _startListening() {
    _offsetSubscription = FirebaseDatabase.instanceFor(
      app: FirebaseDatabase.instance.app,
      databaseURL:
          'https://ka-ka-ki-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref('.info/serverTimeOffset').onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is num) _serverOffset = v.toInt();
    });
    _roomSubscription = _roomService.watchRoom(roomCode).listen(
      (roomState) {
        if (roomState == null) {
          _error = 'Room no longer exists';
          notifyListeners();
          return;
        }

        _roomState = roomState;

        // Listen to game state once the game is playing or finished.
        if (_gameSubscription == null &&
            (roomState.status == RoomStatus.playing ||
                roomState.status == RoomStatus.finished)) {
          _parseGameState();
        }

        notifyListeners();
      },
      onError: (error) {
        _error = 'Connection error: $error';
        notifyListeners();
      },
    );
  }

  void _parseGameState() {
    // The game data is embedded in the room data from Firebase.
    // We get it via a separate listener on the game path.
    final db = FirebaseDatabase.instanceFor(
      app: FirebaseDatabase.instance.app,
      databaseURL: 'https://ka-ka-ki-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
    final gameRef = db.ref('rooms/$roomCode/game');
    _gameSubscription = gameRef.onValue.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return;

      try {
        final data = _toStringMap(event.snapshot.value);
        _gameState = GameState.fromJson(data);
      } catch (e) {
        debugPrint('Failed to parse game state: $e');
        return;
      }

      // Update countdown timer.
      _updateCountdown();

      notifyListeners();
    });
  }

  void _updateCountdown() {
    _turnTimer?.cancel();

    if (_gameState == null || _gameState!.status != GameStatus.playing) return;

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().millisecondsSinceEpoch +
          _serverOffset -
          _gameState!.turnStartedAt;
      final remaining = 30 - (elapsed ~/ 1000);
      _countdown = remaining.clamp(0, 30);

      // Any client may advance an expired turn (guarded by turnStartedAt
      // in the transaction). Non-current players wait a short grace period
      // so the current player's client normally does it.
      final grace = isMyTurn ? 0 : 3;
      if (remaining <= -grace && _countdown <= 0) {
        _handleTurnTimeout();
      }

      notifyListeners();
    });
  }

  Future<void> _handleTurnTimeout() async {
    if (_gameState == null || _advancing) return;
    _advancing = true;

    try {
      await _roomService.advanceTurn(
        roomCode: roomCode,
        expectedTurnStartedAt: _gameState!.turnStartedAt,
      );
    } catch (e) {
      debugPrint('Turn advance failed: $e');
    } finally {
      _advancing = false;
    }
  }

  // ── Game Actions ─────────────────────────────────────────────

  /// Perform a game action (place, flip, or move).
  Future<bool> performAction(GameAction action) async {
    if (_gameState == null || !isMyTurn) return false;

    // Local validation first.
    if (!MoveValidator.isValidAction(_gameState!.board, action)) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _roomService.performAction(
        roomCode: roomCode,
        playerId: playerId,
        actionData: action.toJson(),
        applyAction: (gameData) => _applyActionToGameData(gameData, action),
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Action failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Apply a game action to the raw Firebase game data.
  ///
  /// This runs inside a Firebase transaction, so it must be pure
  /// computation on the provided data.
  Map<String, dynamic> _applyActionToGameData(
    Map<String, dynamic> gameData,
    GameAction action,
  ) {
    // Parse board from game data.
    final board = Board.fromJson(gameData['board']);

    // Validate the action.
    if (!MoveValidator.isValidAction(board, action)) {
      throw Exception('Invalid action');
    }

    // Apply action to get new board.
    Board newBoard;
    switch (action) {
      case PlaceAction(:final position):
        newBoard = board.withPiece(position, PieceShape.square);
      case FlipAction(:final position):
        newBoard = board.withFlip(position);
      case MoveAction(:final position, :final direction):
        newBoard = board.withMove(position, position.move(direction));
    }

    // Calculate new points.
    final newPoints = ScoreCalculator.calculateNewPoints(
      board,
      newBoard,
    );

    // Update scores.
    final scores = _toStringMap(gameData['scores']);
    final currentIndex = gameData['currentPlayerIndex'] as int;
    final turnOrder = _toStringMap(gameData['turnOrder']);
    final currentPlayerId = turnOrder[currentIndex.toString()] as String;
    scores[currentPlayerId] = ((scores[currentPlayerId] as num?)?.toInt() ?? 0) + newPoints;

    // Update board.
    gameData['board'] = newBoard.toJson();
    gameData['scores'] = scores;

    // Check if game is over.
    final legalActions = MoveValidator.getLegalActions(newBoard);
    if (legalActions.isEmpty) {
      gameData['status'] = 'FINISHED';
    } else {
      // Advance turn.
      final nextIndex = (currentIndex + 1) % turnOrder.length;
      gameData['currentPlayerIndex'] = nextIndex;
      gameData['turnStartedAt'] = ServerValue.timestamp;
    }

    return gameData;
  }

  /// Firebase may return Maps with sequential int keys as Lists.
  static Map<String, dynamic> _toStringMap(dynamic raw) {
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    if (raw is List) {
      return {
        for (var i = 0; i < raw.length; i++)
          if (raw[i] != null) i.toString(): raw[i],
      };
    }
    return {};
  }

  /// Leave the current room.
  Future<void> leaveRoom() async {
    try {
      await _roomService.leaveRoom(
        roomCode: roomCode,
        playerId: playerId,
      );
    } catch (e) {
      debugPrint('Leave room failed: $e');
    }
  }

  /// Start a new game in the same room (Play Again).
  Future<void> playAgain() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomService.playAgain(
        roomCode: roomCode,
        gameId: const Uuid().v4(),
      );
    } catch (e) {
      _error = 'Failed to start new game: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Cleanup ──────────────────────────────────────────────────

  @override
  void dispose() {
    _turnTimer?.cancel();
    _roomSubscription?.cancel();
    _gameSubscription?.cancel();
    _offsetSubscription?.cancel();
    super.dispose();
  }
}
