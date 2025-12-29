import 'dart:math';
import 'package:flutter/material.dart'; // Needed for Color
import 'backgammon_logic.dart';

// Class to store move details
class BackgammonMove {
  final int from;
  final int to;
  final int die;
  BackgammonMove(this.from, this.to, this.die);

  @override
  String toString() => '($from->$to using $die)'; // For better logging
}

class BackgammonAI {
  Random random = Random();

  // Finds a sequence of valid moves for the given dice roll
  List<BackgammonMove> findMoveSequence(BackgammonLogic game) {
    List<BackgammonMove> sequence = [];
    // Work on a temporary copy of the game to simulate moves
    BackgammonLogic tempGame = game.clone(); // Use the clone
    // Start with the dice available in the *cloned* game state
    List<int> availableDice = tempGame.getRemainingDice();

    print("AI Seq: Starting search. Initial Dice: ${tempGame.dice}, Initial Used: ${tempGame.usedDice}, Available: $availableDice");

    // Loop while there are dice and possible moves
    while (availableDice.isNotEmpty) {
      // Check moves on the *cloned* game state with its *current* available dice
      if (!tempGame.canMakeAnyMoveWithDice(availableDice)) {
        print("AI Seq: No more moves possible on CLONE with $availableDice. Stopping search.");
        break; // Stop if no moves left on the clone
      }

      // Find the best move for the *cloned* game state with its *current* available dice
      BackgammonMove? nextMove = _findSingleBestMove(tempGame, availableDice);

      if (nextMove != null) {
        print("AI Seq: Found move ${nextMove}. Simulating on CLONE...");
        // Simulate the move on the CLONE
        bool simulated = tempGame.tryMakeMove(nextMove.from, nextMove.to); // This updates tempGame.usedDice

        if(simulated){
            sequence.add(nextMove); // Add the successful move to the sequence
            // Recalculate available dice based on the clone's *updated* usedDice
            availableDice = tempGame.getRemainingDice();
            print("AI Seq: Move simulated. Sequence: $sequence. CLONE Remaining Dice: $availableDice");
        } else {
             print("AI Seq ERROR: Found move ${nextMove} failed simulation on CLONE! Stopping search.");
             // If simulation fails, remove the die that was attempted? Or just stop? Stop is safer.
             break;
        }
      } else {
        print("AI Seq: _findSingleBestMove returned null for CLONE. Stopping search.");
        break; // Stop if AI can't find a move
      }
    } // End while

    print("AI Seq: Search finished. Final sequence: $sequence");
    return sequence;
  }

  // Helper: Finds the *first* valid move (simple strategy)
  BackgammonMove? _findSingleBestMove(BackgammonLogic game, List<int> availableDice) {
     if (availableDice.isEmpty) return null;

     Color playerColor = Colors.black; // AI is Black
     int barIndex = BackgammonLogic.blackBarIndex;
     int homeIndex = BackgammonLogic.blackHomeIndex;

     // 1. Must move from the bar if checkers are present
     if (game.points[barIndex].count > 0) {
       List<int> shuffledDice = List.from(availableDice)..shuffle(random);
       for (int die in shuffledDice) {
         int targetIndex = 24 - die;
         // Check validity using the *current* game state (which is the clone)
         if (game.isValidMove(barIndex, targetIndex, die)) {
           return BackgammonMove(barIndex, targetIndex, die);
         }
       }
       return null; // No bar moves found with available dice
     }

     bool canBearOffNow = game.canBearOff(playerColor);

     // 2. Check regular/Bear off moves (shuffled points)
     List<int> playerPointsIndices = [];
     for (int i = 0; i < 24; i++) { if (game.points[i].color == playerColor && game.points[i].count > 0) { playerPointsIndices.add(i); } }
     playerPointsIndices.shuffle(random); // Shuffle order of checking points
     // Try larger dice first within the shuffled point order
     List<int> sortedDice = List.from(availableDice)..sort((a,b) => b.compareTo(a));

     for (int i in playerPointsIndices) {
        for (int die in sortedDice) { // Iterate through available dice for this point
           // a) Try regular move first
           int targetIndex = i - die;
           if (targetIndex >= 0) {
               // Check validity using the *current* game state
              if (game.isValidMove(i, targetIndex, die)) {
                 return BackgammonMove(i, targetIndex, die);
              }
           }
           // b) Try bearing off if possible
           if (canBearOffNow) {
                // Check validity using the *current* game state
               if (game.isValidMove(i, homeIndex, die)) {
                 return BackgammonMove(i, homeIndex, die);
               }
           }
        }
     }
     return null; // No moves found at all
  }
}