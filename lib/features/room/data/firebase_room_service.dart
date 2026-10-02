import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import '../domain/models/room_state.dart';
import '../../../core/utils/room_code_generator.dart';

/// Service for managing rooms in Firebase Realtime Database.
class FirebaseRoomService {
  final FirebaseDatabase _db;

  /// The database URL for our Firebase RTDB instance (Singapore region).
  static const _databaseUrl =
      'https://ka-ka-ki-default-rtdb.asia-southeast1.firebasedatabase.app';

  FirebaseRoomService({FirebaseDatabase? database})
      : _db = database ??
            FirebaseDatabase.instanceFor(
              app: FirebaseDatabase.instance.app,
              databaseURL: _databaseUrl,
            );

  DatabaseReference get _roomsRef => _db.ref('rooms');

  /// Create a new room and return the room code.
  Future<String> createRoom({
    required String playerId,
    required String playerName,
  }) async {
    // Generate a unique room code.
    String roomCode;
    bool exists = true;

    do {
      roomCode = RoomCodeGenerator.generate();
      final snapshot = await _roomsRef.child(roomCode).get();
      exists = snapshot.exists;
    } while (exists);

    final now = ServerValue.timestamp;
    final roomData = {
      'status': 'WAITING',
      'hostPlayerId': playerId,
      'createdAt': now,
      'players': {
        playerId: {
          'name': playerName,
          'connected': true,
          'joinedAt': now,
        },
      },
    };

    await _roomsRef.child(roomCode).set(roomData);

    // Set up disconnect handler for this player.
    _setupPresence(roomCode, playerId);

    return roomCode;
  }

  /// Join an existing room.
  ///
  /// Throws if the room doesn't exist, is full, or has already started.
  Future<void> joinRoom({
    required String roomCode,
    required String playerId,
    required String playerName,
  }) async {
    final roomRef = _roomsRef.child(roomCode);

    final result = await roomRef.runTransaction((data) {
      if (data == null) {
        return Transaction.abort();
      }

      final roomMap = Map<String, dynamic>.from(data as Map);
      final status = roomMap['status'] as String?;

      if (status != 'WAITING') {
        return Transaction.abort();
      }

      final players = roomMap['players'] as Map? ?? {};
      if (players.length >= 6) {
        return Transaction.abort();
      }

      // Add the new player.
      players[playerId] = {
        'name': playerName,
        'connected': true,
        'joinedAt': ServerValue.timestamp,
      };
      roomMap['players'] = players;

      return Transaction.success(roomMap);
    });

    if (!result.committed) {
      // Determine the specific error.
      final snapshot = await roomRef.get();
      if (!snapshot.exists) {
        throw Exception('Room not found');
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final status = data['status'] as String?;
      if (status != 'WAITING') {
        throw Exception('Game already started');
      }
      final players = data['players'] as Map? ?? {};
      if (players.length >= 6) {
        throw Exception('Room is full');
      }
      throw Exception('Failed to join room');
    }

    _setupPresence(roomCode, playerId);
  }

  /// Watch a room for changes.
  Stream<RoomState?> watchRoom(String roomCode) {
    return _roomsRef.child(roomCode).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }
      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return RoomState.fromJson(roomCode, data);
      } catch (e) {
        // Log parse error for debugging.
        // Return null only if room really doesn't exist.
        return null;
      }
    });
  }

  /// Start the game (host only).
  Future<void> startGame({
    required String roomCode,
    required String playerId,
    required String gameId,
  }) async {
    final roomRef = _roomsRef.child(roomCode);

    await roomRef.runTransaction((data) {
      if (data == null) return Transaction.abort();

      final roomMap = Map<String, dynamic>.from(data as Map);

      // Verify this player is the host.
      if (roomMap['hostPlayerId'] != playerId) {
        return Transaction.abort();
      }

      // Verify room is in WAITING status.
      if (roomMap['status'] != 'WAITING') {
        return Transaction.abort();
      }

      // Verify at least 2 players.
      final players = Map<String, dynamic>.from(roomMap['players'] as Map);
      final connectedPlayers = players.entries
          .where((e) => (e.value as Map)['connected'] == true)
          .toList();

      if (connectedPlayers.length < 2) {
        return Transaction.abort();
      }

      // Create random turn order from connected players.
      final playerIds = connectedPlayers.map((e) => e.key).toList()..shuffle();

      // Build empty board.
      final board = <String, String>{};
      for (var i = 0; i < 9; i++) {
        board[i.toString()] = 'EMPTY';
      }

      // Build scores.
      final scores = <String, int>{};
      for (final id in playerIds) {
        scores[id] = 0;
      }

      // Build turn order.
      final turnOrder = <String, String>{};
      for (var i = 0; i < playerIds.length; i++) {
        turnOrder[i.toString()] = playerIds[i];
      }

      // Update room status.
      roomMap['status'] = 'PLAYING';
      roomMap['game'] = {
        'board': board,
        'currentPlayerIndex': 0,
        'turnOrder': turnOrder,
        'scores': scores,
        'status': 'PLAYING',
        'turnStartedAt': ServerValue.timestamp,
        'gameId': gameId,
      };

      return Transaction.success(roomMap);
    });
  }

  /// Leave a room.
  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async {
    final roomRef = _roomsRef.child(roomCode);

    await roomRef.runTransaction((data) {
      if (data == null) return Transaction.abort();

      final roomMap = Map<String, dynamic>.from(data as Map);
      final players = Map<String, dynamic>.from(roomMap['players'] as Map? ?? {});

      // Remove the player.
      players.remove(playerId);

      // If no players remain, delete the room.
      if (players.isEmpty) {
        return Transaction.success(null);
      }

      roomMap['players'] = players;

      // If the leaving player was the host, assign a new host.
      if (roomMap['hostPlayerId'] == playerId) {
        final remainingIds = players.keys.toList()..shuffle();
        roomMap['hostPlayerId'] = remainingIds.first;
      }

      // If game is playing and we need to handle turn order.
      if (roomMap['game'] != null) {
        final game = Map<String, dynamic>.from(roomMap['game'] as Map);
        final turnOrder = Map<String, dynamic>.from(game['turnOrder'] as Map? ?? {});
        final scores = Map<String, dynamic>.from(game['scores'] as Map? ?? {});

        // Remove from scores.
        scores.remove(playerId);
        game['scores'] = scores;

        // Rebuild turn order without this player.
        final orderedIds = <String>[];
        for (var i = 0; i < turnOrder.length; i++) {
          final id = turnOrder[i.toString()] as String?;
          if (id != null && id != playerId) {
            orderedIds.add(id);
          }
        }

        final newTurnOrder = <String, String>{};
        for (var i = 0; i < orderedIds.length; i++) {
          newTurnOrder[i.toString()] = orderedIds[i];
        }
        game['turnOrder'] = newTurnOrder;

        // Adjust current player index if needed.
        var currentIndex = game['currentPlayerIndex'] as int? ?? 0;
        if (currentIndex >= orderedIds.length) {
          currentIndex = 0;
        }
        game['currentPlayerIndex'] = currentIndex;

        // If fewer than 2 players left, end the game.
        if (orderedIds.length < 2) {
          game['status'] = 'FINISHED';
          roomMap['status'] = 'FINISHED';
        }

        // Reset turn timer for the new current player.
        game['turnStartedAt'] = ServerValue.timestamp;
        roomMap['game'] = game;
      }

      return Transaction.success(roomMap);
    });

    // Cancel disconnect handler.
    _roomsRef.child('$roomCode/players/$playerId/connected').onDisconnect().cancel();
  }

  /// Set up Firebase presence for a player.
  void _setupPresence(String roomCode, String playerId) {
    final connectedRef = _roomsRef.child('$roomCode/players/$playerId/connected');
    connectedRef.onDisconnect().set(false);
  }

  /// Perform a game action (place, flip, or move).
  Future<bool> performAction({
    required String roomCode,
    required String playerId,
    required Map<String, dynamic> actionData,
    required Map<String, dynamic> Function(Map<String, dynamic> gameData) applyAction,
  }) async {
    final roomRef = _roomsRef.child(roomCode);

    final result = await roomRef.child('game').runTransaction((data) {
      if (data == null) return Transaction.abort();

      final gameMap = Map<String, dynamic>.from(data as Map);

      // Verify it's this player's turn.
      final turnOrder = Map<String, dynamic>.from(gameMap['turnOrder'] as Map);
      final currentIndex = gameMap['currentPlayerIndex'] as int;
      final currentPlayerId = turnOrder[currentIndex.toString()] as String?;

      if (currentPlayerId != playerId) {
        return Transaction.abort();
      }

      // Verify game is still playing.
      if (gameMap['status'] != 'PLAYING') {
        return Transaction.abort();
      }

      // Apply the action (validates and modifies the game state).
      try {
        final updatedGame = applyAction(gameMap);
        return Transaction.success(updatedGame);
      } catch (e) {
        return Transaction.abort();
      }
    });

    return result.committed;
  }

  /// Reset the game for Play Again.
  Future<void> playAgain({
    required String roomCode,
    required String gameId,
  }) async {
    final roomRef = _roomsRef.child(roomCode);

    await roomRef.runTransaction((data) {
      if (data == null) return Transaction.abort();

      final roomMap = Map<String, dynamic>.from(data as Map);

      // Get connected players.
      final players = Map<String, dynamic>.from(roomMap['players'] as Map? ?? {});
      final connectedPlayers = players.entries
          .where((e) {
            final playerData = e.value as Map;
            return playerData['connected'] == true;
          })
          .toList();

      if (connectedPlayers.length < 2) {
        return Transaction.abort();
      }

      // Create new random turn order.
      final playerIds = connectedPlayers.map((e) => e.key).toList()..shuffle();

      // Build empty board.
      final board = <String, String>{};
      for (var i = 0; i < 9; i++) {
        board[i.toString()] = 'EMPTY';
      }

      // Build scores.
      final scores = <String, int>{};
      for (final id in playerIds) {
        scores[id] = 0;
      }

      // Build turn order.
      final turnOrder = <String, String>{};
      for (var i = 0; i < playerIds.length; i++) {
        turnOrder[i.toString()] = playerIds[i];
      }

      // Reset game.
      roomMap['status'] = 'PLAYING';
      roomMap['game'] = {
        'board': board,
        'currentPlayerIndex': 0,
        'turnOrder': turnOrder,
        'scores': scores,
        'status': 'PLAYING',
        'turnStartedAt': ServerValue.timestamp,
        'gameId': gameId,
      };

      return Transaction.success(roomMap);
    });
  }

  /// Advance the turn (used for timeout).
  Future<void> advanceTurn({
    required String roomCode,
    required int expectedTurnStartedAt,
  }) async {
    final gameRef = _roomsRef.child('$roomCode/game');

    await gameRef.runTransaction((data) {
      if (data == null) return Transaction.abort();

      final gameMap = Map<String, dynamic>.from(data as Map);

      // Verify the turn hasn't already changed.
      final turnStartedAt = gameMap['turnStartedAt'] as int?;
      if (turnStartedAt != expectedTurnStartedAt) {
        return Transaction.abort();
      }

      // Advance to next player.
      final turnOrder = Map<String, dynamic>.from(gameMap['turnOrder'] as Map);
      var currentIndex = gameMap['currentPlayerIndex'] as int;
      currentIndex = (currentIndex + 1) % turnOrder.length;

      gameMap['currentPlayerIndex'] = currentIndex;
      gameMap['turnStartedAt'] = ServerValue.timestamp;

      return Transaction.success(gameMap);
    });
  }
}
