import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/levels_data.dart';
import '../utils/constants.dart';

class LevelService {
  static const String _cacheKey = 'cached_levels';
  static const String _versionKey = 'cached_version';

  Future<LevelsData> loadLevels() async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      try {
        final remoteData = await _fetchFromRemote();
        if (remoteData != null) {
          await _cacheLevels(remoteData);
          return remoteData;
        }
      } catch (e) {
        debugPrint('Remote fetch failed: $e');
      }
    }

    // Fallback to cache
    final cached = await _loadFromCache();
    if (cached != null) return cached;

    // Fallback to assets
    return await _loadFromAssets();
  }

  Future<LevelsData?> _fetchFromRemote() async {
    final response = await http.get(
      Uri.parse(AppStrings.levelsUrl),
      headers: {'Cache-Control': 'no-cache'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LevelsData.fromJson(json);
    }
    return null;
  }

  Future<void> _cacheLevels(LevelsData data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_versionKey) ?? 0;

    if (data.version > currentVersion) {
      await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
      await prefs.setInt(_versionKey, data.version);
      debugPrint('Updated to version ${data.version}');
    }
  }

  Future<LevelsData?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      return LevelsData.fromJson(json);
    }
    return null;
  }

  Future<LevelsData> _loadFromAssets() async {
    final jsonString = await rootBundle.loadString('assets/levels.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LevelsData.fromJson(json);
  }

  Future<int> getCachedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_versionKey) ?? 0;
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
