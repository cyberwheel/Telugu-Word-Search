import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class GridCell extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isFound;
  final bool isHinted;
  final bool showError;
  final VoidCallback? onPanStart;
  final VoidCallback? onPanUpdate;
  final VoidCallback? onPanEnd;

  const GridCell({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isFound = false,
    this.isHinted = false,
    this.showError = false,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors.gridCell;
    Color textColor = AppColors.textDark;
    double scale = 1.0;

    if (isFound) {
      backgroundColor = AppColors.foundCell;
      textColor = Colors.white;
    } else if (isHinted) {
      backgroundColor = AppColors.hintFlash;
      textColor = AppColors.textDark;
    } else if (isSelected) {
      backgroundColor = AppColors.selectedCell;
      textColor = Colors.white;
    }

    if (showError) {
      scale = 0.9;
    }

    Widget cell = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(scale),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Ramabhadra',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (showError) {
      cell = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: AppAnimations.gridShake,
        builder: (context, value, child) {
          final offset = sin(value * pi * 4) * 5;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: cell,
      );
    }

    return GestureDetector(
      onPanStart: (_) => onPanStart?.call(),
      onPanUpdate: (_) => onPanUpdate?.call(),
      onPanEnd: (_) => onPanEnd?.call(),
      child: cell,
    );
  }
}
