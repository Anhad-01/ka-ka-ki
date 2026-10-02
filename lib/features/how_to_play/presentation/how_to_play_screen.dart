import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _SectionCard(
            title: 'Board',
            content: 'The game is played on a 3×3 board with 9 spaces.',
            icon: Icons.grid_3x3,
          ),
          _SectionCard(
            title: 'Players',
            content: '2 to 6 players can join the game.',
            icon: Icons.people_outline,
          ),
          _SectionCard(
            title: 'Your Turn',
            content: 'You have 30 seconds to make ONE action. If you timeout, your turn is skipped.',
            icon: Icons.timer_outlined,
          ),
          _SectionCard(
            title: 'Actions',
            content: 'On your turn, you can do ONE of the following:\n\n'
                '• PLACE: Tap an empty space to place a new Square (■).\n'
                '• FLIP: Tap your own shape to upgrade it: Square (■) → Pentagon (⬟) → Circle (●). Circles cannot be flipped.\n'
                '• MOVE: Swipe your shape one space orthogonally to an empty adjacent destination.',
            icon: Icons.touch_app_outlined,
          ),
          _SectionCard(
            title: 'Make Sequences',
            content: 'Create a line of three matching shapes (horizontal, vertical, or diagonal) to score 1 point. Shapes must be of the same type and belong to you.',
            icon: Icons.linear_scale,
          ),
          _SectionCard(
            title: 'Full Board',
            content: 'When the board is full (no empty spaces), you can only use the FLIP action.',
            icon: Icons.block,
          ),
          _SectionCard(
            title: 'Game End',
            content: 'The game ends when no player has any legal actions remaining. After the game, you can choose to Play Again or Leave the Room.',
            icon: Icons.emoji_events_outlined,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _SectionCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
