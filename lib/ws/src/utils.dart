/// Default letters to fill in the empty spaces
const String WSLetters = 'abcdefghijklmnoprstuvwy';

/// All the orientations available to build the puzzle
enum WSOrientation {
  horizontal,
  horizontalBack,
  vertical,
  verticalUp,
  diagonal,
  diagonalUp,
  diagonalBack,
  diagonalUpBack,
}

class WSSettings {
  int height;
  int width;
  final List<WSOrientation> orientations;
  final dynamic fillBlanks;
  final bool allowExtraBlanks;
  final int maxAttempts;
  final int maxGridGrowth;
  final bool preferOverlap;

  WSSettings({
    required this.width,
    required this.height,
    this.orientations = WSOrientation.values,
    this.fillBlanks,
    this.allowExtraBlanks = true,
    this.maxAttempts = 3,
    this.maxGridGrowth = 10,
    this.preferOverlap = true,
  });
}

/// Word location interface
class WSLocation implements WSPosition {
  final int x;
  final int y;
  final WSOrientation orientation;
  final int overlap;
  String word;

  WSLocation({
    required this.x,
    required this.y,
    required this.orientation,
    required this.overlap,
    required this.word,
  });
}

class WSPosition {
  final int x;
  final int y;

  WSPosition({
    this.x = 0,
    this.y = 0,
  });
}

class WSNewPuzzle {
  List<List<String>>? puzzle;
  List<String> wordsNotPlaced;
  List<String> warnings;
  List<String> errors;

  WSNewPuzzle({
    this.puzzle,
    List<String>? wordsNotPlaced,
    List<String>? warnings,
    List<String>? errors,
  })  : wordsNotPlaced = wordsNotPlaced ?? [],
        warnings = warnings ?? [],
        errors = errors ?? [];

  @override
  String toString() {
    String puzzleString = '';
    for (var i = 0, height = puzzle!.length; i < height; i++) {
      final List<String> row = puzzle![i];
      for (var j = 0, width = row.length; j < width; j++) {
        puzzleString += (row[j] == '' ? ' ' : row[j]) + ' ';
      }
      puzzleString += '\n';
    }
    return puzzleString;
  }
}

/// The solved puzzle interface
class WSSolved {
  List<WSLocation> found;
  List<String> notFound;

  WSSolved({
    List<WSLocation>? found,
    List<String>? notFound,
  })  : found = found ?? [],
        notFound = notFound ?? [];
}

typedef WSOrientationFn = WSPosition Function(int x, int y, int i);
typedef WSCheckOrientationFn = bool Function(int x, int y, int h, int w, int l);
