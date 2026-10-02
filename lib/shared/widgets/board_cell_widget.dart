import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../features/game/domain/models/piece_shape.dart';
import '../../features/game/domain/models/position.dart';
import 'shape_painter.dart';

class BoardCellWidget extends StatefulWidget {
  final PieceShape? shape;
  final VoidCallback onTap;
  final ValueChanged<Direction> onSwipe;
  final bool enabled;

  const BoardCellWidget({
    super.key,
    required this.shape,
    required this.onTap,
    required this.onSwipe,
    this.enabled = true,
  });

  @override
  State<BoardCellWidget> createState() => _BoardCellWidgetState();
}

class _BoardCellWidgetState extends State<BoardCellWidget> {
  bool _isPressed = false;
  Offset? _panStartPosition;
  Offset? _panCurrentPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      } : null,
      onTapCancel: () {
        setState(() => _isPressed = false);
        _panStartPosition = null;
        _panCurrentPosition = null;
      },
      onPanStart: (details) {
        setState(() => _isPressed = true);
        _panStartPosition = details.localPosition;
        _panCurrentPosition = details.localPosition;
      },
      onPanUpdate: (details) {
        _panCurrentPosition = details.localPosition;
      },
      onPanEnd: (details) {
        setState(() => _isPressed = false);
        if (_panStartPosition != null && _panCurrentPosition != null) {
          final dx = _panCurrentPosition!.dx - _panStartPosition!.dx;
          final dy = _panCurrentPosition!.dy - _panStartPosition!.dy;
          
          if (dx.abs() >= 20 || dy.abs() >= 20) {
            if (dx.abs() > dy.abs()) {
              widget.onSwipe(dx > 0 ? Direction.right : Direction.left);
            } else {
              widget.onSwipe(dy > 0 ? Direction.down : Direction.up);
            }
          } else {
            // Treat as tap if movement is less than threshold
            widget.onTap();
          }
        }
        _panStartPosition = null;
        _panCurrentPosition = null;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: _isPressed 
              ? AppTheme.cellColor.withValues(alpha: 0.8) 
              : AppTheme.cellColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.cellBorderColor,
            width: 2,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.cellBorderColor.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShapeWidget(shape: widget.shape),
        ),
      ),
    );
  }
}
