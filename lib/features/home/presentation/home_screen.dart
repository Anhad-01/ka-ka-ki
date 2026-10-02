import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -50,
            right: -50,
            child: _DecorativeShape(
              color: AppTheme.circleColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              size: 200,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _DecorativeShape(
              color: AppTheme.squareColor.withValues(alpha: 0.2),
              shape: BoxShape.rectangle,
              size: 150,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ka-kā-ki',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Shape • Flip • Win!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.createRoom),
                  child: const Text('CREATE ROOM'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.joinRoom),
                  child: const Text('JOIN ROOM'),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.howToPlay),
                  icon: const Icon(Icons.help_outline),
                  label: const Text('HOW TO PLAY'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeShape extends StatelessWidget {
  final Color color;
  final BoxShape shape;
  final double size;

  const _DecorativeShape({
    required this.color,
    required this.shape,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 12,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(20) : null,
        ),
      ),
    );
  }
}
