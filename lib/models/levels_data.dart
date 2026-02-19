import 'level_model.dart';

class LevelsData {
  final int version;
  final List<Level> levels;

  LevelsData({
    required this.version,
    required this.levels,
  });

  factory LevelsData.fromJson(Map<String, dynamic> json) {
    return LevelsData(
      version: json['version'] as int,
      levels: (json['levels'] as List<dynamic>)
          .map((l) => Level.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'levels': levels.map((l) => l.toJson()).toList(),
    };
  }

  LevelsData copyWith({
    int? version,
    List<Level>? levels,
  }) {
    return LevelsData(
      version: version ?? this.version,
      levels: levels ?? this.levels,
    );
  }
}
