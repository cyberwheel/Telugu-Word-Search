import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final double size;
  final bool showEmpty;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 20,
    this.showEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isFilled = index < stars;
        if (!isFilled && !showEmpty) return const SizedBox.shrink();
        
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: isFilled ? Colors.amber : Colors.grey.shade400,
          size: size,
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final int stars;
  final String label;

  const StarRatingDisplay({
    super.key,
    required this.stars,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StarRating(stars: stars, size: 40),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Ramabhadra',
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}
