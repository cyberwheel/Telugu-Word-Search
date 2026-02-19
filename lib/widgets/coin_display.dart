import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class CoinDisplay extends ConsumerWidget {
  const CoinDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(userProvider).coins;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: TextStyle(
              fontFamily: 'Ramabhadra',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
