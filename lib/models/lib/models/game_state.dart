import 'level_model.dart';

enum GameStatus { initial, playing, won }

class GameState {
  final Level level;
  final GameStatus status;
  final List<GridPosition> selectedPath;
  final String currentWord;
  final bool isValidWord;
  final bool showError;
  final GridPosition? hintPosition;

  const GameState({
    required this.level,
    this.status = GameStatus.initial,
    this.selectedPath = const [],
    this.currentWord = '',
    this.isValidWord = false,
    this.showError = false,
    this.hintPosition,
  });

  GameState copyWith({
    Level? level,
    GameStatus? status,
    List<GridPosition>? selectedPath,
    String? currentWord,
    bool? isValidWord,
    bool? showError,
    GridPosition? hintPosition,
    bool clearHint = false,
  }) {
    return GameState(
      level: level ?? this.level,
      status: status ?? this.status,
      selectedPath: selectedPath ?? this.selectedPath,
      currentWord: currentWord ?? this.currentWord,
      isValidWord: isValidWord ?? this.isValidWord,
      showError: showError ?? this.showError,
      hintPosition: clearHint ? null : (hintPosition ?? this.hintPosition),
    );
  }

  bool isPositionSelected(int row, int col) {
    return selectedPath.any((p) => p.row == row && p.col == col);
  }

  bool isPositionFound(int row, int col) {
    // Check if this position is part of any found word
    for (final word in level.words.where((w) => w.found)) {
      final positions = _findWordPositions(word.text);
      if (positions.any((p) => p.row == row && p.col == col)) {
        return true;
      }
    }
    return false;
  }

  List<GridPosition> _findWordPositions(String word) {
    // This would be implemented to track actual positions of found words
    // For now, return empty list
    return [];
  }
}

class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition($row, $col)';
}

class FoundWord {
  final String text;
  final List<GridPosition> positions;

  const FoundWord(this.text, this.positions);
}
