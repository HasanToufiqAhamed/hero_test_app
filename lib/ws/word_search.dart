import 'dart:math';

import 'src/orientations.dart';
import 'src/check_orientations.dart';
import 'src/skip_orientations.dart';
import 'src/utils.dart';
export 'src/utils.dart';

/// The Word Search puzzle class
///
class WordSearch {
  final orientations = wsOrientations;
  final _checkOrientations = wsCheckOrientations;
  final _skipOrientations = wsSkipOrientations;
  List<String> _wordsNotPlaced = [];
  List<List<String>>? _fillPuzzle(
    List<String> words,
    WSSettings options,
  ) {
    final List<List<String>> puzzle = [];
    for (var i = 0; i < options.height; i++) {
      puzzle.add([]);
      for (var j = 0; j < options.width; j++) {
        puzzle[i].add('');
      }
    }
    // add each word into the puzzle one at a time
    for (var i = 0; i < words.length; i++) {
      if (!_placeWordInPuzzle(puzzle, options, words[i])) {
        // if a word didn't fit in the puzzle, give up
        _wordsNotPlaced.add(words[i]);
        return null;
      }
    }
    // return the puzzle
    return puzzle;
  }
  bool _placeWordInPuzzle(
    List<List<String>> puzzle,
    WSSettings options,
    String word,
  ) {
    final List<WSLocation> locations =
        _findBestLocations(puzzle, options, word);

    if (locations.isEmpty) {
      return false;
    }

    final WSLocation sel = locations[Random().nextInt(locations.length)];
    _placeWord(
      puzzle,
      word,
      sel.x,
      sel.y,
      orientations[sel.orientation]!,
    );
    return true;
  }

  List<WSLocation> _findBestLocations(
    List<List<String>> puzzle,
    WSSettings options,
    String word,
  ) {
    List<WSLocation> locations = [];
    int height = options.height;
    int width = options.width;
    int wordLength = word.length;
    int maxOverlap = 0;

    for (var i = 0; i < options.orientations.length; i++) {
      final WSOrientation orientation = options.orientations[i];
      final WSOrientationFn? next = orientations[orientation];
      final WSCheckOrientationFn? check = _checkOrientations[orientation];
      final WSOrientationFn? skip = _skipOrientations[orientation];
      int x = 0;
      int y = 0;
      // loop through every position on the board
      while (y < height) {
        // see if this orientation is even possible at this location
        if (check!(x, y, height, width, wordLength)) {
          // determine if the word fits at the current position
          final int overlap = _calcOverlap(word, puzzle, x, y, next!);
          // if the overlap was bigger than previous overlaps that we've seen
          if (overlap >= maxOverlap ||
              (!options.preferOverlap && overlap > -1)) {
            maxOverlap = overlap;
            locations.add(
              WSLocation(
                x: x,
                y: y,
                orientation: orientation,
                overlap: overlap,
                word: word,
              ),
            );
          }
          x += 1;
          if (x >= width) {
            x = 0;
            y += 1;
          }
        } else {
          WSPosition nextPossible = skip!(x, y, wordLength);
          x = nextPossible.x;
          y = nextPossible.y;
        }
      }
    }
    return options.preferOverlap
        ? _pruneLocations(locations, maxOverlap)
        : locations;
  }
  int _calcOverlap(
    String word,
    List<List<String>> puzzle,
    int x,
    int y,
    WSOrientationFn fnGetSquare,
  ) {
    int overlap = 0;
    for (var i = 0; i < word.length; i++) {
      final WSPosition next = fnGetSquare(x, y, i);
      String? square;
      try {
        square = puzzle[next.y][next.x];
      } catch (_e) {
        square = null;
      }
      if (square == word[i]) {
        overlap++;
      }
      else if (square != '') {
        return -1;
      }
    }
    return overlap;
  }

  List<WSLocation> _pruneLocations(
    /// The set of locations to prune
    List<WSLocation> locations,

    /// The required level of overlap
    int overlap,
  ) {
    List<WSLocation> pruned = [];
    for (var i = 0; i < locations.length; i++) {
      if (locations[i].overlap >= overlap) {
        pruned.add(locations[i]);
      }
    }
    return pruned;
  }

  /// Places a word in the puzzle given a starting position and orientation.
  void _placeWord(
    /// The current state of the puzzle
    List<List<String>> puzzle,

    ///  The word to fit into the puzzle
    String word,

    /// The x position to check
    int x,

    /// The y position to check
    int y,

    /// Function that returns the next square
    WSOrientationFn fnGetSquare,
  ) {
    for (var i = 0; i < word.length; i++) {
      final WSPosition next = fnGetSquare(x, y, i);
      try {
        puzzle[next.y][next.x] = word[i];
      } catch (e) {
        print(e);
        print(e.toString());
      }
    }
  }

  /// Fills in any empty spaces in the puzzle with random letters.
  int _fillBlanks(
    List<List<String>> puzzle,

    /// Function to add extra letters to fill blanks
    Function extraLetterGenerator,
  ) {
    int extraLettersCount = 0;
    for (var i = 0, height = puzzle.length; i < height; i++) {
      List<String> row = puzzle[i];
      for (var j = 0, width = row.length; j < width; j++) {
        if (puzzle[i][j] == '') {
          puzzle[i][j] = extraLetterGenerator();
          extraLettersCount += 1;
        }
      }
    }
    return extraLettersCount;
  }

  WSNewPuzzle newPuzzle(
    /// The words to be placed in the puzzle
    List<String> words,

    /// The puzzle setting object
    WSSettings settings,
  ) {
    // New instance of the output data
    WSNewPuzzle output = WSNewPuzzle();
    if (words.isEmpty) {
      output.errors.add('Zero words provided');
      return output;
    }
    List<List<String>> ?puzzle;
    int attempts = 0;
    int gridGrowths = 0;

    // copy and sort the words by length, inserting words into the puzzle
    // from longest to shortest works out the best
    final List<String> wordList = []
      ..addAll(words)
      ..sort((String a, String b) {
        return b.length - a.length;
      });
    // max word length
    final maxWordLength = wordList.first.length;
    // create new options instance of the settings
    final WSSettings options = WSSettings(
      width: settings.width != null ? settings.width : maxWordLength,
      height: settings.height != null ? settings.height : maxWordLength,
      orientations: settings.orientations,
      fillBlanks: settings.fillBlanks ?? true,
      maxAttempts: settings.maxAttempts,
      maxGridGrowth: settings.maxGridGrowth,
      preferOverlap: settings.preferOverlap,
      allowExtraBlanks: settings.allowExtraBlanks,
    );
    while (puzzle == null) {
      while (puzzle == null && attempts++ < options.maxAttempts) {
        _wordsNotPlaced = [];
        puzzle = _fillPuzzle(wordList, options);
      }
      if (puzzle == null) {
        // Increase the size of the grid
        gridGrowths += 1;
        // No more grid growths allowed
        if (gridGrowths > options.maxGridGrowth) {
          output.errors.add(
            'No valid ${options.width}x${options.height} grid found and not allowed to grow more',
          );
          return output;
        }
        print('Trying a bigger grid after ${attempts - 1}');
        options.height += 1;
        options.width += 1;
        attempts = 0;
      }
    }
    // fill in empty spaces with random letters
    if (options.fillBlanks != null) {
      List<String> lettersToAdd = [];
      int fillingBlanksCount = 0;
      int extraLettersCount = 0;
      double gridFillPercent = 0;
      Function extraLetterGenerator;
      // Custom fill blanks function
      if (options.fillBlanks is Function) {
        extraLetterGenerator = options.fillBlanks;
      } else if (options.fillBlanks is String) {
        // Use the simple array pop mechanism for the input string
        lettersToAdd.addAll(options.fillBlanks.toLowerCase().split(''));
        extraLetterGenerator = () {
          if (lettersToAdd.isNotEmpty) {
            return lettersToAdd.removeLast();
          }
          fillingBlanksCount += 1;
          return '';
        };
      } else {
        // Use the default random letters
        extraLetterGenerator = () {
          return WSLetters[Random().nextInt(WSLetters.length)];
        };
      }
      // Fill all the blanks in the puzzle
      extraLettersCount = _fillBlanks(puzzle, extraLetterGenerator);
      // Warn the user that some letters were not used
      if (lettersToAdd.isNotEmpty) {
        output.warnings
            .add('Some extra letters provided were not used: ${lettersToAdd}');
      }
      // Extra letters not filled in the grid if allow blanks is false
      if (fillingBlanksCount > 0 && !options.allowExtraBlanks) {
        output.errors.add(
            '$fillingBlanksCount extra letters were missing to fill the grid');
        return output;
      }
      gridFillPercent =
          100 * (1 - extraLettersCount / (options.width * options.height));
      print('Blanks filled with ${extraLettersCount} random letters');
      print('Final grid is filled at ${gridFillPercent.toStringAsFixed(0)}%');
    }
    output.puzzle = puzzle;
    output.wordsNotPlaced = _wordsNotPlaced;
    return output;
  }


  WSSolved solvePuzzle(
    List<List<String>> puzzle,

    List<String> words,
  ) {
    WSSettings options = WSSettings(
      height: puzzle.length,
      width: puzzle[0].length,
    );
    WSSolved output = WSSolved();

    for (var i = 0, len = words.length; i < len; i++) {
      final String word = words[i];
      List<WSLocation> locations = _findBestLocations(puzzle, options, word);
      if (locations.isNotEmpty && locations[0].overlap == word.length) {
        locations[0].word = word;
        output.found.add(locations[0]);
      } else {
        output.notFound.add(word);
      }
    }

    return output;
  }
}
