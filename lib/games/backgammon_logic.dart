import 'dart:math';
import 'package:flutter/material.dart';

// Represents the state of a single point on the board or bar/home
class PointState {
  int count;
  Color? color;
  PointState({this.count = 0, this.color});

  // Helper for cloning the state of a point
  PointState clone() => PointState(count: count, color: color);
}

// Contains the rules and state for the Backgammon game
class BackgammonLogic {
  late List<PointState> points; // Board points (0-23), bars (24, 25), homes (26, 27)
  bool isWhiteTurn = true; // Tracks whose turn it is
  List<int> dice = []; // Current dice roll values
  List<int> usedDice = []; // Dice values used within the current turn
  Random random = Random(); // For rolling dice
  int? selectedPointIndex; // The point index the player has selected (null if none)
  Color? winner; // Stores the winner (null if game ongoing)
  List<String> _history = []; // Stores previous game states for undo

  // Constant indices for special locations
  static const int whiteBarIndex = 24;
  static const int blackBarIndex = 25;
  static const int whiteHomeIndex = 26;
  static const int blackHomeIndex = 27;

  // Constructor: Initializes the board on creation
  BackgammonLogic() {
    _initializeBoard();
  }

  // Sets up the initial board position
  void _initializeBoard() {
    points = List.generate(28, (_) => PointState()); // 24 points + 2 bars + 2 homes

    // White's setup
    points[0] = PointState(count: 2, color: Colors.white);
    points[11] = PointState(count: 5, color: Colors.white);
    points[16] = PointState(count: 3, color: Colors.white);
    points[18] = PointState(count: 5, color: Colors.white);

    // Black's setup (Indices represent white's perspective, black moves opposite)
    points[5] = PointState(count: 5, color: Colors.black);
    points[7] = PointState(count: 3, color: Colors.black);
    points[12] = PointState(count: 5, color: Colors.black);
    points[23] = PointState(count: 2, color: Colors.black);

    isWhiteTurn = true; // White starts
    dice.clear();
    usedDice.clear();
    selectedPointIndex = null;
    winner = null;
    _history.clear(); // Clear history on new game
  }

  // Saves the current game state to the history list
  void _saveStateToHistory() {
    // Convert board state to a string representation
    String boardState = points.map((p) {
      if (p.count == 0) return '0';
      String colorChar = (p.color == Colors.white) ? 'w' : 'b';
      return '$colorChar${p.count}';
    }).join(',');
    // Combine board, turn, dice, and used dice into one state string
    String state = "$boardState;${isWhiteTurn ? 'w' : 'b'};${dice.join(',')};${usedDice.join(',')}";
    _history.add(state);
    // Limit history size to prevent excessive memory usage
    if (_history.length > 50) _history.removeAt(0);
  }

  // Reverts the game to the previous state from history
  bool undoMove() {
    if (_history.isEmpty) {
       print("Undo failed: No history available.");
       return false; // Cannot undo if history is empty
    }

    // Retrieve and remove the last saved state
    String lastState = _history.removeLast();
    List<String> parts = lastState.split(';');

    // Restore board state from the string representation
    List<String> pointStrings = parts[0].split(',');
    if(pointStrings.length != points.length) {
        print("Undo failed: History data corrupt (board length mismatch).");
        _history.add(lastState); // Put it back if corrupt
        return false;
    }
    try {
      for(int i = 0; i < points.length; i++) {
          String s = pointStrings[i];
          if (s == '0') {
              points[i] = PointState();
          } else {
              Color color = (s[0] == 'w') ? Colors.white : Colors.black;
              int count = int.parse(s.substring(1));
              points[i] = PointState(count: count, color: color);
          }
      }

      // Restore turn, dice, and used dice
      isWhiteTurn = parts[1] == 'w';
      dice = parts[2].isEmpty ? [] : parts[2].split(',').map(int.parse).toList();
      usedDice = parts[3].isEmpty ? [] : parts[3].split(',').map(int.parse).toList();
      selectedPointIndex = null; // Always deselect after undo
      winner = null; // Game cannot be over after an undo

      print("Undo successful. Restored state: Turn=${isWhiteTurn ? 'White':'Black'}, Dice=$dice, Used=$usedDice");
      return true;
    } catch (e) {
      print("Undo failed: Error parsing history data: $e");
      _history.add(lastState); // Put it back if corrupt
      return false;
    }
  }


  // Creates a deep copy of the current game state (used by AI)
  BackgammonLogic clone() {
    final newGame = BackgammonLogic();
    // Deep copy points list using the PointState clone method
    newGame.points = points.map((p) => p.clone()).toList();
    newGame.isWhiteTurn = isWhiteTurn;
    newGame.dice = List.from(dice);
    newGame.usedDice = List.from(usedDice);
    newGame.selectedPointIndex = selectedPointIndex;
    newGame.winner = winner;
    return newGame;
  }

  // Rolls the dice for the current player
  void rollDice() {
    // Can only roll if no dice are currently active
    if (dice.isNotEmpty) return;
    _saveStateToHistory(); // Save state *before* rolling

    dice.clear();
    usedDice.clear();
    selectedPointIndex = null;
    int die1 = random.nextInt(6) + 1;
    int die2 = random.nextInt(6) + 1;
    dice.add(die1);
    dice.add(die2);
    // Handle doubles
    if (die1 == die2) {
      dice.add(die1);
      dice.add(die1);
    }
    print("Rolled: $dice for ${isWhiteTurn ? 'White' : 'Black'}");

    // Check if the current player has any valid moves with the new roll
    if (!canMakeAnyMoveWithDice(dice)) {
      print("No possible moves for ${isWhiteTurn ? 'White' : 'Black'} with dice $dice. Passing turn.");
      isWhiteTurn = !isWhiteTurn; // Pass the turn immediately
      dice.clear(); // Clear dice as the turn is skipped
      usedDice.clear();
      // History was saved before the roll, no need to undo here
    }
  }

  // Attempts to make a move from 'fromIndex' to 'toIndex'
  bool tryMakeMove(int fromIndex, int toIndex) {
    // Basic validation: cannot move to the same spot
     if (fromIndex == toIndex) {
         print("Move $fromIndex -> $toIndex failed: Cannot move to the same spot.");
         return false;
     }
     // If a piece is already selected, the 'fromIndex' must match it
     if (selectedPointIndex != null && fromIndex != selectedPointIndex) {
          print("Move $fromIndex -> $toIndex failed: selectedPointIndex ($selectedPointIndex) mismatch.");
         return false;
     }

    _saveStateToHistory(); // Save state *before* attempting the move

    int distance;
    int homeIndex = isWhiteTurn ? whiteHomeIndex : blackHomeIndex;

    // Calculate move distance, handling bar and bearing off
    if (toIndex == homeIndex) { // Bearing off
      if (isWhiteTurn) distance = 24 - fromIndex; else distance = fromIndex + 1;
    } else if (toIndex >= 0 && toIndex < 24) { // Regular move
      if (isWhiteTurn) distance = (fromIndex == whiteBarIndex) ? (toIndex + 1) : (toIndex - fromIndex);
      else distance = (fromIndex == blackBarIndex) ? (24 - toIndex) : (fromIndex - toIndex);
    } else {
        print("Move $fromIndex -> $toIndex failed: Invalid toIndex.");
        _history.removeLast(); // Revert save state
        return false; // Invalid target index
    }

    // Distance must be positive for valid moves (unless moving to same spot, already checked)
    if (distance < 1) {
         print("Move $fromIndex -> $toIndex failed: Invalid distance calculated ($distance).");
        _history.removeLast(); // Revert save state
        return false;
    }


    // Find an unused die that allows this move (exact or larger for bear off)
    int? dieValue = findUnusedDieValue(distance, fromIndex, toIndex == homeIndex);
    if (dieValue == null) {
        print("Move $fromIndex -> $toIndex failed: No suitable die for distance $distance found in ${getRemainingDice()}");
        _history.removeLast(); // Revert save state
        return false;
    }

    // Check if the move is valid according to game rules
    if (isValidMove(fromIndex, toIndex, dieValue)) {
      _executeMove(fromIndex, toIndex, dieValue); // Perform the move
      return true; // Move successful
    } else {
        print("Move $fromIndex -> $toIndex failed: isValidMove returned false for die $dieValue");
        _history.removeLast(); // Revert save state, move was invalid
    }
    return false; // Move failed validation
  }

 // Finds an unused die value that matches the required distance, handling bear off rules
 int? findUnusedDieValue(int distance, int fromIndex, bool isBearingOff) {
     List<int> availableDice = getRemainingDice(); // Get dice not yet used this turn

     // Check for an exact match first
     if (availableDice.contains(distance)) {
         return distance;
     }

     // If bearing off, check if a larger die can be used
     if (isBearingOff) {
        Color movingColor = isWhiteTurn ? Colors.white : Colors.black;
        bool fartherCheckersExist = false; // Checkers on points farther from home
        if(isWhiteTurn){
             // Check points 19 to fromIndex-1 (points closer to home/edge)
             for (int i = fromIndex + 1; i <= 23; i++) {
                 if (points[i].color == movingColor && points[i].count > 0) { fartherCheckersExist = true; break; }
             }
        } else { // Black player
             // Check points 0 to fromIndex-1
             for (int i = fromIndex - 1; i >= 0; i--) {
                 if (points[i].color == movingColor && points[i].count > 0) { fartherCheckersExist = true; break; }
             }
        }

        // If no checkers are farther out, find the smallest available die that's LARGER than the exact distance needed
        if (!fartherCheckersExist) {
            int? bestLargerDie;
            int requiredRoll = isWhiteTurn ? (24 - fromIndex) : (fromIndex + 1); // Exact roll needed

            for(int die in availableDice){
                // We need a die that's *greater* than the required roll
                if(die > requiredRoll){
                    if(bestLargerDie == null || die < bestLargerDie){
                        bestLargerDie = die; // Find the smallest die that works
                    }
                }
            }
             // Return the smallest larger die if found
             if(bestLargerDie != null) return bestLargerDie;
        }
     }

     return null; // No suitable die found
  }


  // Checks if a specific move from 'fromIndex' to 'toIndex' using 'dieValue' is legal
  bool isValidMove(int fromIndex, int toIndex, int dieValue) {
    Color movingColor = isWhiteTurn ? Colors.white : Colors.black;
    int barIndex = isWhiteTurn ? whiteBarIndex : blackBarIndex;
    int homeIndex = isWhiteTurn ? whiteHomeIndex : blackHomeIndex;

    // Rule: If checkers are on the bar, must move from the bar
    if (points[barIndex].count > 0 && fromIndex != barIndex) return false;

    // Rule: Validate moves FROM the bar
    if (fromIndex == barIndex) {
       int targetPointDist = isWhiteTurn ? dieValue - 1 : 24 - dieValue; // Calculate landing point index from die
       if (toIndex != targetPointDist) return false; // Must land exactly on the point corresponding to the die
       // Destination must be within opponent's home board
       if (isWhiteTurn && !(toIndex >= 0 && toIndex <= 5)) return false; // White enters Black's home (0-5)
       if (!isWhiteTurn && !(toIndex >= 18 && toIndex <= 23)) return false; // Black enters White's home (18-23)
    }

    // Rule: Validate bearing off moves (TO homeIndex)
    bool isBearingOffMove = (toIndex == homeIndex);
    if (isBearingOffMove) {
        if (!canBearOff(movingColor)) return false; // Check if all checkers are home first
        int requiredRoll = isWhiteTurn ? (24 - fromIndex) : (fromIndex + 1); // Exact die value needed

        // Rule 1: Exact roll bears off
        if (requiredRoll == dieValue) return true;

        // Rule 2: Larger roll allowed only if no checkers are on higher points (farther from home)
        if (dieValue > requiredRoll) {
            bool fartherCheckersExist = false;
            if (isWhiteTurn) { for (int i = fromIndex + 1; i <= 23; i++) { if (points[i].color == movingColor && points[i].count > 0) { fartherCheckersExist = true; break; }}}
            else { for (int i = fromIndex - 1; i >= 0; i--) { if (points[i].color == movingColor && points[i].count > 0) { fartherCheckersExist = true; break; }}}
            return !fartherCheckersExist; // Allow larger die only if no checkers behind
        }
        return false; // Die value too small or invalid larger die use
    }

    // Rule: Validate regular moves (target must be on board 0-23)
    if (toIndex < 0 || toIndex >= 24) return false;

    // Rule: Check correct direction for non-bar moves
    if (fromIndex != barIndex) {
      if (isWhiteTurn && toIndex <= fromIndex) return false; // White moves increasing index
      if (!isWhiteTurn && toIndex >= fromIndex) return false; // Black moves decreasing index
    }

    // Rule: Check destination point for opponent's checkers (blot or block)
    PointState destination = points[toIndex];
    if (destination.color != null && destination.color != movingColor && destination.count > 1) {
      return false; // Blocked by 2 or more opponent checkers
    }

    // Rule: Check if the actual distance moved matches the die used (important!)
    // This check is implicitly handled by how findUnusedDieValue and the calling logic work together.
    // If findUnusedDieValue returns a die, it means a valid distance calculation was possible.
    // However, adding an explicit check might be safer if logic changes.
    /*
    int calculatedDistance;
     if (isWhiteTurn) calculatedDistance = (fromIndex == whiteBarIndex) ? (toIndex + 1) : (toIndex - fromIndex);
     else calculatedDistance = (fromIndex == blackBarIndex) ? (24 - toIndex) : (fromIndex - toIndex);
     // This check is complex with bear off logic (die > requiredRoll allowed)
     // if (!isBearingOffMove && calculatedDistance != dieValue) return false;
    */


    return true; // If all checks pass
  }

  // Executes the validated move, updating the board state
  void _executeMove(int fromIndex, int toIndex, int dieValue) {
    Color movingColor = isWhiteTurn ? Colors.white : Colors.black;
    int homeIndex = isWhiteTurn ? whiteHomeIndex : blackHomeIndex;

    // Decrement count at the starting point
    points[fromIndex].count--;
    if (points[fromIndex].count == 0) points[fromIndex].color = null; // Clear color if point is empty

    // Handle regular move or hit
    if (toIndex != homeIndex) {
      PointState destination = points[toIndex];
      // Check if hitting an opponent's blot
      if (destination.color != null && destination.color != movingColor && destination.count == 1) {
        print("Hit opponent checker at point $toIndex");
        int opponentBarIndex = isWhiteTurn ? blackBarIndex : whiteBarIndex;
        points[opponentBarIndex].count++;
        points[opponentBarIndex].color = destination.color; // Set bar color
        destination.count = 0; // Clear destination before moving own checker
        destination.color = null;
      }
      // Increment count and set color at the destination point
      points[toIndex].count++;
      points[toIndex].color = movingColor;
    }
    // Handle bearing off
    else {
      print("Bearing off checker for ${isWhiteTurn ? 'White' : 'Black'}");
      points[homeIndex].count++;
      points[homeIndex].color = movingColor; // Track color in home just in case
    }

    usedDice.add(dieValue); // Mark this specific die value as used for this turn

    // --- REVISED TURN CHANGE LOGIC ---
    // Check remaining dice and if any moves are possible with them
    List<int> remainingDice = getRemainingDice();
    bool canMoveFurther = false;
    if (remainingDice.isNotEmpty) {
      canMoveFurther = canMakeAnyMoveWithDice(remainingDice);
    }

    // Change turn if no dice remain OR no moves possible with remaining dice
    if (remainingDice.isEmpty || !canMoveFurther) {
      print("Turn changing. Remaining Dice: $remainingDice, Can Move Further: $canMoveFurther");
      isWhiteTurn = !isWhiteTurn; // Switch turn
      selectedPointIndex = null; // Deselect any checker
      dice.clear();              // Clear the original roll
      usedDice.clear();          // Clear used dice list for the next turn
    } else {
       print("Turn continues. Remaining Dice: $remainingDice");
       selectedPointIndex = null; // Deselect after part of the move completes
    }
    // --- END REVISED LOGIC ---

    _checkWinner(); // Check if the game has ended after the move
  }

  // Helper function to get the list of dice values not yet used this turn
  List<int> getRemainingDice() {
      List<int> available = [];
      Map<int, int> diceCounts = {}; // Counts occurrences in the original roll
      Map<int, int> usedCounts = {}; // Counts occurrences in the used list

      for (int die in dice) { diceCounts[die] = (diceCounts[die] ?? 0) + 1; }
      for (int used in usedDice) { usedCounts[used] = (usedCounts[used] ?? 0) + 1; }

      // Add dice to available list based on count difference
      diceCounts.forEach((value, count) {
          int remainingCount = count - (usedCounts[value] ?? 0);
          remainingCount = max(0, remainingCount); // Ensure count doesn't go negative
          for (int i = 0; i < remainingCount; i++) {
              available.add(value);
          }
      });
      return available;
  }

  // Checks if the player of the specified color can start bearing off
  bool canBearOff(Color color) {
    int barIndex = (color == Colors.white) ? whiteBarIndex : blackBarIndex;
    if (points[barIndex].count > 0) return false; // Cannot bear off if checkers on bar

    // Define home board ranges
    int startHome = (color == Colors.white) ? 18 : 0; // White's home: 18-23
    int endHome = (color == Colors.white) ? 23 : 5;   // Black's home: 0-5

    // Check all points *outside* the home board
    for (int i = 0; i < 24; i++) {
      // Skip points within the player's home board
      if (color == Colors.white && i >= startHome && i <= endHome) continue;
      if (color == Colors.black && i >= startHome && i <= endHome) continue;

      // If a checker of the player's color is found outside home, cannot bear off
      if (points[i].color == color && points[i].count > 0) {
        return false;
      }
    }
    return true; // All checkers are in the home board
  }

  // Checks if the current player can make any valid move with the provided dice
  bool canMakeAnyMoveWithDice(List<int> currentDice) {
    if (currentDice.isEmpty) return false;
    Color playerColor = isWhiteTurn ? Colors.white : Colors.black;
    int barIndex = isWhiteTurn ? whiteBarIndex : blackBarIndex;
    int homeIndex = isWhiteTurn ? whiteHomeIndex : blackHomeIndex;

    // Check moves from bar first
    if (points[barIndex].count > 0) {
      for (int die in currentDice) {
        int targetIndex = isWhiteTurn ? (die - 1) : (24 - die);
        // Check if target index is on board before calling isValidMove
        if (targetIndex >= 0 && targetIndex < 24) {
             if (isValidMove(barIndex, targetIndex, die)) return true; // Found a valid move from the bar
        }
      }
      return false; // No valid moves from bar
    }

    bool canBearOffNow = canBearOff(playerColor); // Use the public method name

    // Check all checkers on the board (points 0-23)
    for (int i = 0; i < 24; i++) {
      if (points[i].color == playerColor && points[i].count > 0) {
        for (int die in currentDice) {
          // Check regular move
          int targetIndex = isWhiteTurn ? (i + die) : (i - die);
          if (targetIndex >= 0 && targetIndex < 24) { // Target is on board
            if (isValidMove(i, targetIndex, die)) return true; // Found valid regular move
          }
          // Check bear off move
          if (canBearOffNow) {
             // Calculate potential target index to see if it's off board
             int potentialTarget = isWhiteTurn ? (i + die) : (i - die);
             bool goesOffBoard = isWhiteTurn ? (potentialTarget >= 24) : (potentialTarget < 0);
             // Check if bearing off from point 'i' with 'die' is valid
             if(goesOffBoard || targetIndex == homeIndex) { // Check both off board and explicit home move
                 if (isValidMove(i, homeIndex, die)) return true; // Found valid bear off move
             }
          }
        }
      }
    }
    return false; // No moves found for any checker with any die
  }


  // Checks if a player has won by bearing off all checkers
  void _checkWinner(){
    if (points[whiteHomeIndex].count == 15) winner = Colors.white;
    else if (points[blackHomeIndex].count == 15) winner = Colors.black;
  }

} // End of Backgam