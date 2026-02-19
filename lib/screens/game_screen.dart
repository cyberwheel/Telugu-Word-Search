import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_model.dart';
import '../providers/game_provider.dart';
import '../providers/grid_provider.dart';
import '../providers/user_provider.dart';
import '../services/ad_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import '../widgets/grid_cell.dart';
import '../widgets/word_list_item.dart';
import 'win_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    AdService().preloadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(currentLevelProvider(widget.levelId));

    if (level == null) {
      return const Scaffold(
        body: Center(child: Text('Level not found')),
      );
    }

    return ProviderScope(
      overrides: [
        gridProvider.overrideWith((ref) => GridNotifier(level)),
      ],
      child: const _GameContent(),
    );
  }
}

class _GameContent extends ConsumerWidget {
  const _GameContent();

  void _showWatchAdDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.insufficientCoins,
          style: const TextStyle(fontFamily: 'Ramabhadra', height: 1.5),
        ),
        content: Text(
          'Watch a video to earn ${AppStrings.rewardAmount} coins?',
          style: const TextStyle(fontFamily: 'Ramabhadra', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRewardedAd(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text(
              AppStrings.watchAd,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd(BuildContext context, WidgetRef ref) {
    AdService().showRewardedAd(
      onRewarded: () {
        ref.read(userProvider.notifier).addCoins(100);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You earned 100 coins!')),
        );
      },
      onDismissed: () {},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gridProvider);
    final gridNotifier = ref.read(gridProvider.notifier);

    // Check win condition
    if (gameState.status == GameStatus.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWinScreen(context, ref, gameState.level);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Level ${gameState.level.id}',
                      style: const TextStyle(
                        fontFamily: 'Ramabhadra',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const CoinDisplay(),
                ],
              ),
            ),

            // Category
            Text(
              gameState.level.category,
              style: TextStyle(
                fontFamily: 'Ramabhadra',
                fontSize: 16,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // Grid
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameState.level.gridSize,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: gameState.level.gridSize * gameState.level.gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ gameState.level.gridSize;
                      final col = index % gameState.level.gridSize;
                      final text = gameState.level.gridData[row][col];
                      
                      final isSelected = gameState.isPositionSelected(row, col);
                      final isFound = gridNotifier.isPositionFound(row, col);
                      final isHinted = gameState.hintPosition?.row == row && 
                                      gameState.hintPosition?.col == col;

                      return GridCell(
                        text: text,
                        isSelected: isSelected,
                        isFound: isFound,
                        isHinted: isHinted,
                        showError: gameState.showError && isSelected,
                        onPanStart: () => gridNotifier.startDragging(row, col),
                        onPanUpdate: () => gridNotifier.updateDragging(row, col),
                        onPanEnd: () => gridNotifier.endDragging(),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hint Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final userNotifier = ref.read(userProvider.notifier);
                      if (userNotifier.deductCoins(50)) {
                        gridNotifier.useHint();
                      } else {
                        _showWatchAdDialog(context, ref);
                      }
                    },
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hint ',
                          style: TextStyle(
                            fontFamily: 'Ramabhadra',
                            height: 1.5,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const Icon(Icons.monetization_on, size: 16),
                        Text(
                          ' ${AppStrings.hintCost}',
                          style: TextStyle(
                            fontFamily: 'Ramabhadra',
                            height: 1.5,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade100,
                      foregroundColor: Colors.amber.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Word List
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: gameState.level.words.length,
                  itemBuilder: (context, index) {
                    return WordListItem(
                      word: gameState.level.words[index],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Banner Ad
            if (AdService().bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: AdService().bannerAd!.size.width.toDouble(),
                height: AdService().bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: AdService().bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  void _showWinScreen(BuildContext context, WidgetRef ref, Level level) {
    final stars = level.starsEarned;
    ref.read(userProvider.notifier).setLevelStars(level.id, stars);
    ref.read(userProvider.notifier).unlockLevel(level.id + 1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinOverlay(
        stars: stars,
        onNextLevel: () async {
          Navigator.pop(context);
          
          // Show interstitial every 3 levels
          if (level.id % 3 == 0) {
            await AdService().showInterstitialAd();
          }

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(levelId: level.id + 1),
              ),
            );
          }
        },
      ),
    );
  }
}
