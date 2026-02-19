import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../utils/constants.dart';

class WordListItem extends StatelessWidget {
  final Word word;
  final VoidCallback? onHint;

  const WordListItem({
    super.key,
    required this.word,
    this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: word.found ? AppColors.success.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: word.found ? AppColors.success : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontFamily: 'Ramabhadra',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: word.found ? AppColors.success : AppColors.textDark,
                    height: 1.5,
                    decoration: word.found ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.success,
                    decorationThickness: 2,
                  ),
                  child: Text(word.text),
                ),
                const SizedBox(height: 4),
                Text(
                  word.hint,
                  style: TextStyle(
                    fontFamily: 'Ramabhadra',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (word.hinted && !word.found)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.hintFlash,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.orange,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
