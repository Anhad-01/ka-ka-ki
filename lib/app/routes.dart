import 'package:flutter/material.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/room/presentation/create_room_screen.dart';
import '../features/room/presentation/join_room_screen.dart';
import '../features/room/presentation/waiting_room_screen.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/how_to_play/presentation/how_to_play_screen.dart';

/// Named routes for the app.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String createRoom = '/create-room';
  static const String joinRoom = '/join-room';
  static const String waitingRoom = '/waiting-room';
  static const String game = '/game';
  static const String howToPlay = '/how-to-play';

  /// Generate routes for [MaterialApp.onGenerateRoute].
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen(), settings);

      case createRoom:
        return _buildRoute(const CreateRoomScreen(), settings);

      case joinRoom:
        return _buildRoute(const JoinRoomScreen(), settings);

      case waitingRoom:
        final args = settings.arguments as WaitingRoomArgs;
        return _buildRoute(WaitingRoomScreen(args: args), settings);

      case game:
        final args = settings.arguments as GameScreenArgs;
        return _buildRoute(GameScreen(args: args), settings);

      case howToPlay:
        return _buildRoute(const HowToPlayScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// Arguments passed when navigating to the waiting room.
class WaitingRoomArgs {
  final String roomCode;
  final String playerId;
  final String playerName;

  const WaitingRoomArgs({
    required this.roomCode,
    required this.playerId,
    required this.playerName,
  });
}

/// Arguments passed when navigating to the game screen.
class GameScreenArgs {
  final String roomCode;
  final String playerId;
  final String playerName;

  const GameScreenArgs({
    required this.roomCode,
    required this.playerId,
    required this.playerName,
  });
}
