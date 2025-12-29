import 'package:flutter/material.dart';

class TogyzKumalakLogic {
  late List<int> otaus;
  int whiteKazan = 0;
  int blackKazan = 0;
  bool isWhiteTurn = true;
  int? whiteTuzdyk;
  int? blackTuzdyk;
  Color? winner;
  List<String> _history = [];

  TogyzKumalakLogic() { _initializeBoard(); }

  void _initializeBoard() {
    otaus = List.generate(18, (_) => 9);
    whiteKazan = 0; blackKazan = 0; isWhiteTurn = true;
    whiteTuzdyk = null; blackTuzdyk = null; winner = null;
    _history.clear();
     // Save initial state? Optional.
     // _saveStateToHistory();
  }

  void _saveStateToHistory() {
    String boardState = otaus.join(',');
    String state = "$boardState;${isWhiteTurn ? 'w' : 'b'};$whiteKazan;$blackKazan;${whiteTuzdyk ?? -1};${blackTuzdyk ?? -1}";
    _history.add(state);
    if (_history.length > 50) _history.removeAt(0);
  }

  bool undoMove() {
    if (_history.isEmpty) return false;
    String lastState = _history.removeLast();
    List<String> parts = lastState.split(';');
    List<String> otauStrings = parts[0].split(',');
    otaus = otauStrings.map(int.parse).toList();

    if(parts.length > 1){ // Safety check
        List<String> otherVars = parts[1].split(',');
         if(otherVars.length >= 5){
             isWhiteTurn = otherVars[0] == 'w';
             whiteKazan = int.parse(otherVars[1]);
             blackKazan = int.parse(otherVars[2]);
             whiteTuzdyk = int.parse(otherVars[3]) == -1 ? null : int.parse(otherVars[3]);
             blackTuzdyk = int.parse(otherVars[4]) == -1 ? null : int.parse(otherVars[4]);
         }
     }

    winner = null;
    print("Togyz Undo successful.");
    return true;
  }

  // --- NEW METHOD: Checks if current player has any valid move ---
  bool canMakeAnyMove() {
      if (winner != null) return false; // Game already over

      int startIndex = isWhiteTurn ? 0 : 9;
      int endIndex = isWhiteTurn ? 8 : 17;

      for (int i = startIndex; i <= endIndex; i++) {
          // Cannot move from opponent's Tuzdyk if it's there
          if (isWhiteTurn && i == blackTuzdyk) continue;
          if (!isWhiteTurn && i == whiteTuzdyk) continue;
          // Can move if pit has stones
          if (otaus[i] > 0) {
              return true; // Found at least one valid move source
          }
      }
      return false; // No moves found (Atsyrau condition)
  }
  // --- END NEW METHOD ---


  bool makeMove(int otauIndex) {
    if (winner != null) return false;
    // Basic validation
    if ((isWhiteTurn && otauIndex >= 9) || (!isWhiteTurn && otauIndex < 9)) return false;
    if (otaus[otauIndex] == 0) return false;
     // Cannot move FROM opponent's Tuzdyk
     if (isWhiteTurn && otauIndex == blackTuzdyk) return false;
     if (!isWhiteTurn && otauIndex == whiteTuzdyk) return false;


    _saveStateToHistory();

    int kumalaksToMove = otaus[otauIndex];
    int lastOtauIndex = otauIndex;
    int stonesLeft = 1; // Stone left in the starting pit if count > 1

    if (kumalaksToMove == 1) {
      otaus[otauIndex] = 0; // Take the single stone
      lastOtauIndex = (otauIndex + 1) % 18;
      stonesLeft = 0; // No stone left if started with 1
      _sowStone(lastOtauIndex); // Sow the single stone
    } else {
      otaus[otauIndex] = 1; // Leave one stone
      // Sow the rest
      for (int i = 0; i < kumalaksToMove - 1; i++) {
        lastOtauIndex = (lastOtauIndex + 1) % 18;
        _sowStone(lastOtauIndex);
      }
    }

    // --- Post-sowing Logic ---
    int lastOtauCount = otaus[lastOtauIndex];
    bool isOpponentSide = (isWhiteTurn && lastOtauIndex >= 9) || (!isWhiteTurn && lastOtauIndex < 9);
    bool isOwnTuzdyk = (isWhiteTurn && lastOtauIndex == whiteTuzdyk) || (!isWhiteTurn && lastOtauIndex == blackTuzdyk);
    bool isOpponentTuzdyk = (isWhiteTurn && lastOtauIndex == blackTuzdyk) || (!isWhiteTurn && lastOtauIndex == whiteTuzdyk);

    // Capture (if last pit is opponent's, even count, and not opponent's tuzdyk)
    if (isOpponentSide && !isOpponentTuzdyk && lastOtauCount > 0 && lastOtauCount % 2 == 0) {
      print("Capture at index $lastOtauIndex, count $lastOtauCount");
      if (isWhiteTurn) whiteKazan += lastOtauCount;
      else blackKazan += lastOtauCount;
      otaus[lastOtauIndex] = 0;
    }
    // Tuzdyk Creation (if last pit is opponent's, count is 3, not opponent's tuzdyk, not 9th pit, not symmetrical, and player doesn't have one)
    else if (isOpponentSide && !isOpponentTuzdyk && lastOtauCount == 3) {
      bool canCreate = false;
      int symmetricalIndex = 17 - lastOtauIndex;
      if (isWhiteTurn && whiteTuzdyk == null && lastOtauIndex != 17 && lastOtauIndex != blackTuzdyk && symmetricalIndex != blackTuzdyk) {
         canCreate = true;
         whiteTuzdyk = lastOtauIndex;
         whiteKazan += 3;
         print("White creates Tuzdyk at index $lastOtauIndex");
      } else if (!isWhiteTurn && blackTuzdyk == null && lastOtauIndex != 8 && lastOtauIndex != whiteTuzdyk && symmetricalIndex != whiteTuzdyk) {
         canCreate = true;
         blackTuzdyk = lastOtauIndex;
         blackKazan += 3;
          print("Black creates Tuzdyk at index $lastOtauIndex");
      }
      if(canCreate) otaus[lastOtauIndex] = 0; // Clear pit after creating Tuzdyk
    }

    isWhiteTurn = !isWhiteTurn; // Change turn
    checkEndGameConditions(); // Check for win/Atsyrau for the *next* player
    return true;
  }

  // Helper function to sow one stone, handling Tuzdyks
  void _sowStone(int index) {
     if (index == whiteTuzdyk) { whiteKazan++; }
     else if (index == blackTuzdyk) { blackKazan++; }
     else { otaus[index]++; }
  }


  // --- RENAMED METHOD (public) ---
  void checkEndGameConditions() {
    if (winner != null) return; // Already ended

    // 1. Check Kazan count
    if (whiteKazan >= 82) { winner = Colors.white; return; }
    if (blackKazan >= 82) { winner = Colors.black; return; }

    // 2. Check Atsyrau (no moves for the *current* player whose turn it now is)
    if (!canMakeAnyMove()) {
      print("Atsyrau detected for ${isWhiteTurn ? 'White' : 'Black'}!");
      // Opponent gets all remaining stones on their side
      if (isWhiteTurn) { // White has no moves, Black gets Black's stones
        for(int i = 9; i < 18; i++) { blackKazan += otaus[i]; otaus[i] = 0; }
      } else { // Black has no moves, White gets White's stones
        for(int i = 0; i < 9; i++) { whiteKazan += otaus[i]; otaus[i] = 0; }
      }
      print("Atsyrau transfer complete. W: $whiteKazan, B: $blackKazan");

      // Determine winner based on final count
      if (whiteKazan > blackKazan) winner = Colors.white;
      else if (blackKazan > whiteKazan) winner = Colors.black;
      else winner = Colors.grey; // Draw
    }
  }
  // --- END RENAMED METHOD ---

  TogyzKumalakLogic clone() {
    final newGame = TogyzKumalakLogic();
    newGame.otaus = List.from(otaus);
    newGame.whiteKazan = whiteKazan;
    newGame.blackKazan = blackKazan;
    newGame.isWhiteTurn = isWhiteTurn;
    newGame.whiteTuzdyk = whiteTuzdyk;
    newGame.blackTuzdyk = blackTuzdyk;
    newGame.winner = winner;
    // History is NOT cloned for AI
    return newGame;
  }
}