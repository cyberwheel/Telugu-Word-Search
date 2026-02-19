import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/levels_data.dart';
import '../models/level_model.dart';
import '../services/level_service.dart';

final gameProvider = StateNotifierProvider<GameNotifier, AsyncValue<LevelsData>>((ref) {
  return GameNotifier();
});

final currentLevelProvider = Provider.family<Level?, int>((ref, levelId) {
  final levelsData = ref.watch(gameProvider).value;
  if (levelsData == null) return null;
  
  try {
    return levelsData.levels.firstWhere((l) => l.id == levelId);
  } catch (e) {
    return null;
  }
});

class GameNotifier extends StateNotifier<AsyncValue<LevelsData>> {
  final LevelService _levelService = LevelService();

  GameNotifier() : super(const AsyncValue.loading()) {
    loadLevels();
  }

  Future<void> loadLevels() async {
    state = const AsyncValue.loading();
    try {
      final data = await _levelService.loadLevels();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshLevels() async {
    await loadLevels();
  }

  List<Level> get levels => state.value?.levels ?? [];
  int get version => state.value?.version ?? 0;
  int get totalLevels => state.value?.levels.length ?? 0;
}
