import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserState {
  final int coins;
  final int unlockedLevel;
  final Map<int, int> levelStars; // levelId -> stars

  const UserState({
    this.coins = 200,
    this.unlockedLevel = 1,
    this.levelStars = const {},
  });

  UserState copyWith({
    int? coins,
    int? unlockedLevel,
    Map<int, int>? levelStars,
  }) {
    return UserState(
      coins: coins ?? this.coins,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      levelStars: levelStars ?? this.levelStars,
    );
  }

  int getStarsForLevel(int levelId) => levelStars[levelId] ?? 0;
  bool isLevelUnlocked(int levelId) => levelId <= unlockedLevel;
}

class UserNotifier extends StateNotifier<UserState> {
  static const String _coinsKey = 'user_coins';
  static const String _unlockedKey = 'user_unlocked';
  static const String _starsKey = 'user_stars';

  UserNotifier() : super(const UserState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(_coinsKey) ?? 200;
    final unlocked = prefs.getInt(_unlockedKey) ?? 1;
    
    final starsJson = prefs.getString(_starsKey);
    final Map<int, int> stars = {};
    if (starsJson != null) {
      final decoded = Map<String, dynamic>.from(
        // ignore: avoid_dynamic_calls
        Uri.splitQueryString(starsJson),
      );
      stars.addAll(decoded.map((k, v) => MapEntry(int.parse(k), int.parse(v))));
    }

    state = UserState(
      coins: coins,
      unlockedLevel: unlocked,
      levelStars: stars,
    );
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, state.coins);
    await prefs.setInt(_unlockedKey, state.unlockedLevel);
    await prefs.setString(_starsKey, 
      state.levelStars.entries.map((e) => '${e.key}=${e.value}').join('&'));
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
    _saveState();
  }

  bool deductCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      _saveState();
      return true;
    }
    return false;
  }

  void unlockLevel(int levelId) {
    if (levelId > state.unlockedLevel) {
      state = state.copyWith(unlockedLevel: levelId);
      _saveState();
    }
  }

  void setLevelStars(int levelId, int stars) {
    final currentStars = state.getStarsForLevel(levelId);
    if (stars > currentStars) {
      final newStars = Map<int, int>.from(state.levelStars);
      newStars[levelId] = stars;
      state = state.copyWith(levelStars: newStars);
      _saveState();
    }
  }
}
