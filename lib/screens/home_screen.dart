import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import '../widgets/star_rating.dart';
import 'game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(gameProvider);
    final userState = ref.watch(userProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.appTitle,
                        style: const TextStyle(
                          fontFamily: 'Ramabhadra',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const CoinDisplay(),
                  ],
                ),
              ],
            ),
          ),
          
          // Level Grid
          Expanded(
            child: levelsAsync.when(
              data: (levelsData) {
                final levels = levelsData.levels;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isUnlocked = userState.isLevelUnlocked(level.id);
                    final isCurrent = level.id == userState.unlockedLevel;
                    final stars = userState.getStarsForLevel(level.id);

                    return _LevelCard(
                      level: level,
                      isUnlocked: isUnlocked,
                      isCurrent: isCurrent,
                      stars: stars,
                      onTap: isUnlocked
                          ? () => _openLevel(context, level.id)
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading levels',
                      style: TextStyle(
                        fontFamily: 'Ramabhadra',
                        color: AppColors.textLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.refresh(gameProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
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
    );
  }

  void _openLevel(BuildContext context, int levelId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(levelId: levelId),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final dynamic level;
  final bool isUnlocked;
  final bool isCurrent;
  final int stars;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: AppColors.primary, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isUnlocked) ...[
            Text(
              '${level.id}',
              style: TextStyle(
                fontFamily: 'Ramabhadra',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isCurrent ? AppColors.primary : AppColors.textDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            StarRating(stars: stars, size: 16),
          ] else ...[
            Icon(
              Icons.lock,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              '${level.id}',
              style: TextStyle(
                fontFamily: 'Ramabhadra',
                fontSize: 20,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );

    if (isCurrent) {
      card = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.05),
        duration: AppAnimations.levelPulse,
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: card,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
