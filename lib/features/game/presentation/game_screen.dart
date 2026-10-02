import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../domain/models/models.dart';
import '../../../shared/widgets/board_cell_widget.dart';
import '../../room/domain/models/room_state.dart';
import 'game_provider.dart';

class GameScreen extends StatefulWidget {
  final GameScreenArgs args;

  const GameScreen({super.key, required this.args});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider _provider;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _provider = GameProvider(
      roomCode: widget.args.roomCode,
      playerId: widget.args.playerId,
      playerName: widget.args.playerName,
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _handleCellTap(Position pos) {
    if (!_provider.isMyTurn) return;

    final board = _provider.gameState?.board;
    if (board == null) return;

    if (board.isEmpty(pos)) {
      // Place a square on empty cell.
      _provider.performAction(PlaceAction(pos));
    } else {
      // Flip the piece.
      _provider.performAction(FlipAction(pos));
    }
  }

  void _handleCellSwipe(Position pos, Direction direction) {
    if (!_provider.isMyTurn) return;
    _provider.performAction(MoveAction(pos, direction));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        // Play Again: room was reset, go to the waiting room.
        if (!_navigating && _provider.roomState?.status == RoomStatus.waiting) {
          _navigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.waitingRoom,
                arguments: WaitingRoomArgs(
                  roomCode: widget.args.roomCode,
                  playerId: widget.args.playerId,
                  playerName: widget.args.playerName,
                ),
              );
            }
          });
        }

        // If room was destroyed, go home.
        if (!_navigating && _provider.error == 'Host ended the room') {
          _navigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Host ended the room')),
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            }
          });
        } else if (!_navigating &&
            _provider.error != null &&
            _provider.gameState == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_provider.error!)),
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            }
          });
        }

        return Scaffold(
          body: SafeArea(
            child: _provider.gameState == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      _buildGameContent(),
                      if (_provider.isGameOver) _buildGameOverOverlay(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGameContent() {
    final gameState = _provider.gameState!;

    return Column(
      children: [
        const SizedBox(height: 12),
        // Room code
        Text(
          'Room: ${widget.args.roomCode}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        // Timer and turn indicator
        _buildTimerAndTurn(gameState),
        const SizedBox(height: 24),
        // Game board
        Expanded(
          child: Center(
            child: _buildBoard(gameState),
          ),
        ),
        const SizedBox(height: 16),
        // Scores
        _buildScoresPanel(gameState),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimerAndTurn(GameState gameState) {
    final isMyTurn = _provider.isMyTurn;
    final turnPlayerName = _provider.currentPlayerName ?? 'Unknown';
    final turnText = isMyTurn ? "Your turn!" : "$turnPlayerName's turn";
    final countdown = _provider.countdown;
    final isWarning = countdown < 10;

    return Column(
      children: [
        Text(
          turnText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: isMyTurn ? FontWeight.w800 : FontWeight.w500,
                color: isMyTurn ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 52,
                color: isWarning ? AppTheme.errorColor : AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
          child: Text('$countdown'),
        ),
      ],
    );
  }

  Widget _buildBoard(GameState gameState) {
    final isMyTurn = _provider.isMyTurn;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.boardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final pos = Position.fromIndex(index);
            final shape = gameState.board.at(pos);

            return BoardCellWidget(
              shape: shape,
              enabled: isMyTurn && gameState.status == GameStatus.playing,
              onTap: () => _handleCellTap(pos),
              onSwipe: (direction) => _handleCellSwipe(pos, direction),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoresPanel(GameState gameState) {
    final entries = gameState.scores.entries.toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final pid = entry.key;
          final score = entry.value;
          final isCurrent = pid == gameState.currentPlayerId;
          final color =
              AppTheme.playerColors[index % AppTheme.playerColors.length];
          final playerData = _provider.roomState?.players[pid];
          final name = pid == widget.args.playerId
              ? 'You'
              : (playerData?.name ?? 'Player ${index + 1}');

          return Container(
            width: 110,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent
                  ? color.withValues(alpha: 0.12)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? color
                    : AppTheme.cellBorderColor.withValues(alpha: 0.4),
                width: isCurrent ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isCurrent ? color : AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final sortedScores = _provider.sortedScores;
    final winnerIds = _provider.winnerIds;

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Game Over!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              ...sortedScores.map((entry) {
                final pid = entry.key;
                final score = entry.value;
                final isWinner = winnerIds.contains(pid);
                final playerData = _provider.roomState?.players[pid];
                final name = pid == widget.args.playerId
                    ? 'You'
                    : (playerData?.name ?? 'Player');

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isWinner)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text('👑', style: TextStyle(fontSize: 20)),
                            ),
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: isWinner
                                      ? FontWeight.w800
                                      : FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        '$score',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => _provider.playAgain(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('PLAY AGAIN'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _provider.leaveRoom();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('LEAVE ROOM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
