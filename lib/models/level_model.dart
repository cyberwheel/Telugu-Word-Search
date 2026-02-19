import 'word_model.dart';

class Level {
  final int id;
  final String category;
  final int gridSize;
  final List<Word> words;
  final List<List<String>> gridData;

  Level({
    required this.id,
    required this.category,
    required this.gridSize,
    required this.words,
    required this.gridData,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      category: json['category'] as String,
      gridSize: json['grid_size'] as int,
      words: (json['words'] as List<dynamic>)
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      gridData: (json['grid_data'] as List<dynamic>)
          .map((row) => (row as List<dynamic>).map((cell) => cell as String).toList())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'grid_size': gridSize,
      'words': words.map((w) => w.toJson()).toList(),
      'grid_data': gridData,
    };
  }

  Level copyWith({
    int? id,
    String? category,
    int? gridSize,
    List<Word>? words,
    List<List<String>>? gridData,
  }) {
    return Level(
      id: id ?? this.id,
      category: category ?? this.category,
      gridSize: gridSize ?? this.gridSize,
      words: words ?? this.words,
      gridData: gridData ?? this.gridData,
    );
  }

  bool get isCompleted => words.every((w) => w.found);
  int get starsEarned {
    final hintedCount = words.where((w) => w.hinted).length;
    if (hintedCount == 0) return 3;
    if (hintedCount <= 2) return 2;
    return 1;
  }
}
