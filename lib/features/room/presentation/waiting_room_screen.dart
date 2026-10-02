import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../domain/models/room_state.dart';
import '../data/firebase_room_service.dart';

class WaitingRoomScreen extends StatefulWidget {
  final WaitingRoomArgs args;

  const WaitingRoomScreen({super.key, required this.args});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _roomService = FirebaseRoomService();
  bool _hasReceivedInitialState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<RoomState?>(
        stream: _roomService.watchRoom(widget.args.roomCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Stream error (e.g. permission denied, wrong URL) — show message instead of going home.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Connection error:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final roomState = snapshot.data;

          if (roomState != null) {
            _hasReceivedInitialState = true;
          } else if (_hasReceivedInitialState) {
            // Room was active, but now deleted -> go home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
              }
            });
            return const Center(child: Text('Room closed'));
          } else {
            // Still waiting for initial data
            return const Center(child: CircularProgressIndicator());
          }

          if (roomState.status == RoomStatus.playing) {
            // Game started -> go to game screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.game,
                arguments: GameScreenArgs(
                  roomCode: widget.args.roomCode,
                  playerId: widget.args.playerId,
                  playerName: widget.args.playerName,
                ),
              );
            });
            return const Center(child: Text('Game starting...'));
          }

          final isHost = roomState.hostPlayerId == widget.args.playerId;
          final players = roomState.connectedPlayers;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRoomCodeCard(context),
                const SizedBox(height: 32),
                Text(
                  '${players.length} / 6 PLAYERS',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: players.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final isPlayerHost = player.id == roomState.hostPlayerId;
                      final color = AppTheme.playerColors[index % AppTheme.playerColors.length];

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: AppTheme.cellBorderColor.withValues(alpha: 0.5),
                          ),
                        ),
                        tileColor: AppTheme.surfaceColor,
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Text(
                            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: isPlayerHost
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'HOST',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
                if (isHost) ...[
                  ElevatedButton(
                    onPressed: players.length >= 2
                        ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final gameId = DateTime.now().millisecondsSinceEpoch.toString();
                            try {
                              await _roomService.startGame(
                                roomCode: widget.args.roomCode,
                                playerId: widget.args.playerId,
                                gameId: gameId,
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Failed to start game: $e')),
                              );
                            }
                          }
                        : null,
                    child: const Text('START GAME'),
                  ),
                  const SizedBox(height: 16),
                ],
                OutlinedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    try {
                      await _roomService.leaveRoom(
                        roomCode: widget.args.roomCode,
                        playerId: widget.args.playerId,
                      );
                    } catch (_) {}
                    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                  },
                  child: const Text('LEAVE ROOM'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCodeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Room Code',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.args.roomCode,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 8.0,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.args.roomCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room code copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('COPY'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    Share.share('Join my ka-kā-ki game!\nRoom code: ${widget.args.roomCode}');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('SHARE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
