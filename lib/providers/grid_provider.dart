import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_model.dart';
import '../models/game_state.dart';
import '../models/word_model.dart';
import '../services/sound_service.dart';

final gridProvider = StateNotifierProvider.family<GridNotifier, GameState, Level>((ref, level) {
  return GridNotifier(level);
});

class GridNotifier extends StateNotifier<GameState> {
  final SoundService _soundService = SoundService();
  List<FoundWord> _foundWords = [];

  GridNotifier(Level level) : super(GameState(level: level));

  void startDragging(int row, int col) {
    if (state.status == GameStatus.won) return;
    
    final position = GridPosition(row, col);
    state = state.copyWith(
      selectedPath: [position],
      currentWord: state.level.gridData[row][col],
      isValidWord: false,
      showError: false,
      clearHint: true,
    );
    _soundService.playSelect();
  }

  void updateDragging(int row, int col) {
    if (state.status == GameStatus.won) return;
    if (state.selectedPath.isEmpty) return;

    final newPosition = GridPosition(row, col);
    final lastPosition = state.selectedPath.last;

    // Check if adjacent (including diagonal)
    if (!_isAdjacent(lastPosition, newPosition)) return;

    // Check if already in path
    if (state.selectedPath.contains(newPosition)) {
      // Backtracking - remove everything after this position
      final index = state.selectedPath.indexOf(newPosition);
      final newPath = state.selectedPath.sublist(0, index + 1);
      state = state.copyWith(
        selectedPath: newPath,
        currentWord: _pathToWord(newPath),
      );
      return;
    }

    // Add new position
    final newPath = [...state.selectedPath, newPosition];
    state = state.copyWith(
      selectedPath: newPath,
      currentWord: _pathToWord(newPath),
    );
    _soundService.playSelect();
  }

  void endDragging() {
    if (state.selectedPath.isEmpty) return;

    final word = state.currentWord;
    final targetWord = state.level.words.firstWhere(
      (w) => w.text == word && !w.found,
      orElse: () => Word(text: '', hint: ''),
    );

    if (targetWord.text.isNotEmpty) {
      // Valid word found!
      _foundWords.add(FoundWord(word, List.from(state.selectedPath)));
      
      final updatedWords = state.level.words.map((w) {
        if (w.text == word) return w.copyWith(found: true);
        return w;
      }).toList();

      final updatedLevel = state.level.copyWith(words: updatedWords);
      final isWon = updatedWords.every((w) => w.found);

      _soundService.playSuccess();
      
      state = state.copyWith(
        level: updatedLevel,
        selectedPath: [],
        currentWord: '',
        isValidWord: true,
        status: isWon ? GameStatus.won : GameStatus.playing,
      );
    } else {
      // Invalid word
      _soundService.playError();
      state = state.copyWith(
        selectedPath: [],
        currentWord: '',
        showError: true,
      );
      
      // Clear error after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          state = state.copyWith(showError: false);
        }
      });
    }
  }

  void useHint() {
    final unFoundWords = state.level.words.where((w) => !w.found).toList();
    if (unFoundWords.isEmpty) return;

    final targetWord = unFoundWords.first;
    final positions = _findWordPositions(targetWord.text);
    
    if (positions.isNotEmpty) {
      // Mark word as hinted
      final updatedWords = state.level.words.map((w) {
        if (w.text == targetWord.text) return w.copyWith(hinted: true);
        return w;
      }).toList();

      state = state.copyWith(
        level: state.level.copyWith(words: updatedWords),
        hintPosition: positions.first,
      );

      // Clear hint after flash
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          state = state.copyWith(clearHint: true);
        }
      });
    }
  }

  bool _isAdjacent(GridPosition a, GridPosition b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    return rowDiff <= 1 && colDiff <= 1 && !(rowDiff == 0 && colDiff == 0);
  }

  String _pathToWord(List<GridPosition> path) {
    return path.map((p) => state.level.gridData[p.row][p.col]).join();
  }

  List<GridPosition> _findWordPositions(String word) {
    // Search horizontally, vertically, and diagonally
    final grid = state.level.gridData;
    final size = state.level.gridSize;

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        // Try all 8 directions
        for (final direction in _directions) {
          final positions = <GridPosition>[];
          var currentRow = row;
          var currentCol = col;
          var matched = true;

          for (int i = 0; i < word.length; i++) {
            if (currentRow < 0 || currentRow >= size || 
                currentCol < 0 || currentCol >= size) {
              matched = false;
              break;
            }

            // Handle multi-character cells (like "మ్మ", "న్న")
            final cellText = grid[currentRow][currentCol];
            if (!word.substring(i).startsWith(cellText)) {
              matched = false;
              break;
            }

            positions.add(GridPosition(currentRow, currentCol));
            currentRow += direction[0];
            currentCol += direction[1];
            i += cellText.length - 1; // Adjust for multi-char cells
          }

          if (matched && positions.isNotEmpty) {
            return positions;
          }
        }
      }
    }
    return [];
  }

  static const _directions = [
    [0, 1],   // Right
    [0, -1],  // Left
    [1, 0],   // Down
    [-1, 0],  // Up
    [1, 1],   // Down-Right
    [1, -1],  // Down-Left
    [-1, 1],  // Up-Right
    [-1, -1], // Up-Left
  ];

  List<GridPosition> getFoundPositions() {
    final positions = <GridPosition>[];
    for (final found in _foundWords) {
      positions.addAll(found.positions);
    }
    return positions;
  }

  bool isPositionFound(int row, int col) {
    return getFoundPositions().any((p) => p.row == row && p.col == col);
  }
}
