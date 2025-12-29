import 'dart:math';
import 'package:flutter/material.dart';

// --- Модели данных ---
enum PieceType { man, king }

class GamePiece {
  final Color color;
  PieceType type;
  GamePiece({required this.color, this.type = PieceType.man});

  // Helper for cloning
  GamePiece clone() => GamePiece(color: color, type: type);
}

// Класс для хранения хода
class Move {
  final int from;
  final int to;
  Move(this.from, this.to);
}

// --- Класс с логикой игры ---
class CheckersGameLogic {
  late List<List<GamePiece?>> board;
  bool isWhiteTurn = true;
  List<int> mandatoryCapturePieces = [];
  int whiteCaptured = 0;
  int blackCaptured = 0;
  List<String> _history = []; // History for undo
  List<String> moveHistory =
      []; // Move history in algebraic notation for display

  CheckersGameLogic() {
    _initializeBoard();
    checkForMandatoryCaptures(); // Initial check
  }

  void _initializeBoard() {
    board = List.generate(8, (_) => List.generate(8, (_) => null));
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 != 0) {
          // Dark squares only
          if (r < 3)
            board[r][c] = GamePiece(color: Colors.black);
          else if (r > 4)
            board[r][c] = GamePiece(color: Colors.white);
        }
      }
    }
    isWhiteTurn = true;
    mandatoryCapturePieces.clear();
    whiteCaptured = 0;
    blackCaptured = 0;
    _history.clear();
    moveHistory.clear();
    // checkForMandatoryCaptures(); // Called initially now
  }

  // Convert board index to algebraic notation (e.g., 0 -> "a8", 63 -> "h1")
  String _indexToAlgebraic(int index) {
    int row = index ~/ 8;
    int col = index % 8;
    String file = String.fromCharCode('a'.codeUnitAt(0) + col);
    String rank = (8 - row).toString();
    return '$file$rank';
  }

  // --- History Management ---
  void _saveStateToHistory() {
    String boardState = board
        .map(
          (row) => row
              .map((p) {
                if (p == null) return '0';
                String colorChar = p.color == Colors.white ? 'w' : 'b';
                String typeChar = p.type == PieceType.king ? 'K' : 'm';
                return '$colorChar$typeChar';
              })
              .join(','),
        )
        .join('|'); // Use '|' to separate rows
    String state =
        "$boardState;${isWhiteTurn ? 'w' : 'b'};$whiteCaptured;$blackCaptured";
    // Add mandatory capture info? Could be complex to restore.
    _history.add(state);
    if (_history.length > 50) _history.removeAt(0);
  }

  bool undoMove() {
    if (_history.isEmpty) return false;
    String lastState = _history.removeLast();
    List<String> parts = lastState.split(';');

    // Restore board
    List<String> rowStrings = parts[0].split('|');
    if (rowStrings.length != 8) return false; // Basic validation
    board = List.generate(8, (row) {
      List<String> pieceStrings = rowStrings[row].split(',');
      if (pieceStrings.length != 8)
        return List.generate(8, (_) => null); // Basic validation
      return List.generate(8, (col) {
        String s = pieceStrings[col];
        if (s == '0') return null;
        if (s.length != 2) return null; // Basic validation
        Color color = (s[0] == 'w') ? Colors.white : Colors.black;
        PieceType type = (s[1] == 'K') ? PieceType.king : PieceType.man;
        return GamePiece(color: color, type: type);
      });
    });

    // Restore turn and score (with safety checks)
    if (parts.length >= 4) {
      isWhiteTurn = parts[1] == 'w';
      whiteCaptured =
          int.tryParse(parts[2]) ??
          whiteCaptured; // Keep old value if parse fails
      blackCaptured = int.tryParse(parts[3]) ?? blackCaptured;
    } else {
      // Handle potential error state if history string is corrupted
      print("Error: Corrupted history state string: $lastState");
      return false;
    }

    // Re-calculate mandatory captures based on restored state
    checkForMandatoryCaptures();
    print("Checkers Undo successful.");
    return true;
  }
  // --- End History ---

  // --- Game Moves and Validation ---
  bool tryMove(int fromIndex, int toIndex) {
    if (!isMoveValid(fromIndex, toIndex)) {
      print(
        "tryMove: Move $fromIndex -> $toIndex invalid according to isMoveValid.",
      );
      return false;
    }

    _saveStateToHistory(); // Save state BEFORE making the move

    int fromRow = fromIndex ~/ 8;
    int fromCol = fromIndex % 8;
    int toRow = toIndex ~/ 8;
    int toCol = toIndex % 8;
    GamePiece? pieceToMove = board[fromRow][fromCol]
        ?.clone(); // Work with a clone
    bool wasCapture = false;
    int? capturedPieceRow,
        capturedPieceCol; // Store coords of the captured piece

    // --- Capture Logic ---
    int rowDiff = (toRow - fromRow).abs();
    if (rowDiff >= 2) {
      // Potentially a capture move
      wasCapture = true; // Assume capture initially for distance >= 2
      if (pieceToMove?.type == PieceType.king) {
        // King capture: find the single opponent piece on the path
        int stepRow = (toRow > fromRow) ? 1 : -1;
        int stepCol = (toCol > fromCol) ? 1 : -1;
        int currentRow = fromRow + stepRow;
        int currentCol = fromCol + stepCol;
        int opponentCount = 0; // Count opponents on path before landing square
        while (currentRow != toRow || currentCol != toCol) {
          if (currentRow < 0 ||
              currentRow > 7 ||
              currentCol < 0 ||
              currentCol > 7)
            break; // Safety break
          GamePiece? pieceOnPath = board[currentRow][currentCol];
          if (pieceOnPath != null) {
            if (pieceOnPath.color != pieceToMove!.color) {
              // Found opponent
              opponentCount++;
              if (opponentCount == 1) {
                // Store first opponent found
                capturedPieceRow = currentRow;
                capturedPieceCol = currentCol;
              } else {
                // If >1 opponent found, isMoveValid should have caught this.
                // Mark as not a valid capture for execution.
                wasCapture = false;
                print(
                  "ERROR in tryMove: King path validation failed (found >1 opponent)",
                );
                break;
              }
            } else {
              // Found own piece
              wasCapture = false;
              print("ERROR in tryMove: King path blocked by own piece");
              break;
            }
          }
          currentRow += stepRow;
          currentCol += stepCol;
        }
        // Final check for King capture: Must have found exactly one opponent
        if (opponentCount != 1) wasCapture = false;
      } else {
        // Man capture (distance must be exactly 2)
        if (rowDiff == 2) {
          capturedPieceRow = (fromRow + toRow) ~/ 2;
          capturedPieceCol = (fromCol + toCol) ~/ 2;
        } else {
          wasCapture = false; // Man cannot jump > 2
        }
      }

      // Remove the captured piece and update score if capture was valid
      if (wasCapture && capturedPieceRow != null && capturedPieceCol != null) {
        GamePiece? captured = board[capturedPieceRow][capturedPieceCol];
        if (captured != null) {
          if (captured.color == Colors.white)
            blackCaptured++;
          else
            whiteCaptured++;
          board[capturedPieceRow][capturedPieceCol] = null; // Remove from board
          print("Captured piece at $capturedPieceRow, $capturedPieceCol");
        } else {
          // isMoveValid should prevent this, but log if it happens
          print(
            "ERROR: Tried to capture null piece at $capturedPieceRow, $capturedPieceCol (Invalidated Capture)",
          );
          wasCapture = false; // Mark as not a capture if something went wrong
        }
      } else if (rowDiff >= 2) {
        // If distance >= 2 but wasn't a valid capture
        wasCapture =
            false; // Ensure it's not treated as a capture for multi-jump logic
        print(
          "tryMove: Move $fromIndex->$toIndex distance >= 2 but not a valid capture.",
        );
      }
    }
    // --- End Capture Logic ---

    // Execute the move on the board
    board[fromRow][fromCol] = null;
    board[toRow][toCol] = pieceToMove;

    // Promotion
    bool promoted = false;
    if (pieceToMove != null &&
        pieceToMove.type == PieceType.man &&
        ((pieceToMove.color == Colors.white && toRow == 0) ||
            (pieceToMove.color == Colors.black && toRow == 7))) {
      pieceToMove.type = PieceType.king;
      promoted = true;
      // Promotion ends multi-capture sequence IN RUSSIAN CHECKERS
      wasCapture = false; // Override wasCapture if promotion happened
      print("Promoted piece at $toRow, $toCol");
    }

    // Check for multi-captures (only if a capture happened AND no promotion)
    List<int> nextCaptures = [];
    if (wasCapture) {
      // Check wasCapture again (could be false due to promotion)
      nextCaptures = findCapturesForPiece(
        toIndex,
      ); // Check from the landing square
    }

    // Record move in history (only if turn will change, not during multi-capture)
    if (!(wasCapture && nextCaptures.isNotEmpty)) {
      String fromSquare = _indexToAlgebraic(fromIndex);
      String toSquare = _indexToAlgebraic(toIndex);
      String moveNotation = wasCapture
          ? '$fromSquare×$toSquare'
          : '$fromSquare-$toSquare';
      if (promoted) {
        moveNotation += '♔'; // Add crown symbol for promotion
      }
      moveHistory.add(moveNotation);
    }

    if (wasCapture && nextCaptures.isNotEmpty) {
      mandatoryCapturePieces = [
        toIndex,
      ]; // Force next capture from new position
      print("Multi-capture available. Turn continues for same player.");
      // Turn does NOT change
      return true;
    } else {
      isWhiteTurn = !isWhiteTurn; // Change turn
      checkForMandatoryCaptures(); // Check captures for the *next* player
      print(
        "Turn changed to ${isWhiteTurn ? 'White' : 'Black'}. Checking mandatory moves.",
      );
      return true;
    }
  }

  // Validates if a move from fromIndex to toIndex is legal according to Russian Checkers rules
  bool isMoveValid(int fromIndex, int toIndex) {
    int fromRow = fromIndex ~/ 8;
    int fromCol = fromIndex % 8;
    int toRow = toIndex ~/ 8;
    int toCol = toIndex % 8;

    // Basic Bounds and Start/End Checks
    if (fromRow < 0 ||
        fromRow > 7 ||
        fromCol < 0 ||
        fromCol > 7 ||
        toRow < 0 ||
        toRow > 7 ||
        toCol < 0 ||
        toCol > 7)
      return false; // Out of bounds

    GamePiece? piece = board[fromRow][fromCol];
    // Check if starting square has the current player's piece
    if (piece == null || (piece.color == Colors.white) != isWhiteTurn)
      return false;
    // Check if landing square is empty
    if (board[toRow][toCol] != null) return false;
    // Check if move is diagonal
    int rowDiff = (toRow - fromRow).abs();
    int colDiff = (toCol - fromCol).abs();
    if (colDiff != rowDiff || rowDiff == 0) return false;

    // --- Man Logic ---
    if (piece.type == PieceType.man) {
      bool isForward =
          (piece.color == Colors.white && toRow < fromRow) ||
          (piece.color == Colors.black && toRow > fromRow);

      // Simple Move (Distance 1)
      if (rowDiff == 1) {
        // Must be forward, and no mandatory captures elsewhere on the board
        return isForward && mandatoryCapturePieces.isEmpty;
      }
      // Capture Move (Distance 2)
      else if (rowDiff == 2) {
        int capturedRow = (fromRow + toRow) ~/ 2;
        int capturedCol = (fromCol + toCol) ~/ 2;
        // Check bounds just in case (though covered by start/end checks usually)
        if (capturedRow < 0 ||
            capturedRow > 7 ||
            capturedCol < 0 ||
            capturedCol > 7)
          return false;
        GamePiece? capturedPiece = board[capturedRow][capturedCol];
        // Must jump an opponent piece (direction doesn't matter for capture itself)
        return capturedPiece != null && capturedPiece.color != piece.color;
      }
      return false; // Invalid distance for man
    }
    // --- King Logic ---
    else if (piece.type == PieceType.king) {
      int stepRow = (toRow > fromRow) ? 1 : -1;
      int stepCol = (toCol > fromCol) ? 1 : -1;
      int currentRow = fromRow + stepRow;
      int currentCol = fromCol + stepCol;
      int opponentCount = 0;
      int? capturedRow, capturedCol; // Store coords of the potential capture

      // Check path up to (but not including) the target square
      while (currentRow != toRow || currentCol != toCol) {
        // Check bounds during path traversal
        if (currentRow < 0 ||
            currentRow > 7 ||
            currentCol < 0 ||
            currentCol > 7)
          return false;
        GamePiece? pieceOnPath = board[currentRow][currentCol];
        if (pieceOnPath != null) {
          if (pieceOnPath.color == piece.color)
            return false; // Blocked by own piece
          opponentCount++;
          if (opponentCount == 1) {
            // Found first opponent
            capturedRow = currentRow;
            capturedCol = currentCol;
          } else {
            return false; // Blocked by second piece (opponent or own after opponent)
          }
        } // Empty square - king can continue moving
        currentRow += stepRow;
        currentCol += stepCol;
      } // End while loop checking path

      // Now, validate the move type based on path check and mandatory rules
      bool isCaptureAttempt =
          (opponentCount == 1); // Found exactly one opponent on path

      if (mandatoryCapturePieces.isNotEmpty) {
        // If mandatory moves exist, this move MUST be a capture,
        // originating from a mandatory piece
        // King can land anywhere beyond the captured piece as long as the path is clear
        return isCaptureAttempt && mandatoryCapturePieces.contains(fromIndex);
      } else {
        // If no mandatory moves, this move must be a "quiet" move (no captures along the path)
        return !isCaptureAttempt;
      }
    }
    return false; // Should not happen
  }

  // Checks and updates the list of pieces that MUST capture this turn
  void checkForMandatoryCaptures() {
    mandatoryCapturePieces.clear();
    List<int> potentialCaptures = [];
    for (int i = 0; i < 64; i++) {
      GamePiece? piece = board[i ~/ 8][i % 8];
      if (piece != null && (piece.color == Colors.white) == isWhiteTurn) {
        if (findCapturesForPiece(i).isNotEmpty) {
          potentialCaptures.add(i);
        }
      }
    }
    // If captures are possible, update the mandatory list
    if (potentialCaptures.isNotEmpty) {
      mandatoryCapturePieces = potentialCaptures;
    }
    // print("Mandatory captures for ${isWhiteTurn ? 'White' : 'Black'}: $mandatoryCapturePieces");
  }

  // Finds possible CAPTURE LANDING SQUARES for a single piece at pieceIndex
  List<int> findCapturesForPiece(int pieceIndex) {
    List<int> possibleLandings = [];
    int row = pieceIndex ~/ 8;
    int col = pieceIndex % 8;
    GamePiece? piece = board[row][col];
    if (piece == null) return [];

    if (piece.type == PieceType.man) {
      // Check all 4 diagonal jumps
      for (int dRow in [-2, 2]) {
        for (int dCol in [-2, 2]) {
          int targetRow = row + dRow;
          int targetCol = col + dCol;
          int landingIndex = targetRow * 8 + targetCol;
          // Use isMoveValid to check if landing here constitutes a valid capture
          if (targetRow >= 0 &&
              targetRow <= 7 &&
              targetCol >= 0 &&
              targetCol <= 7) {
            // Temporarily ignore mandatory captures flag for exploration
            List<int> tempMandatory = List.from(mandatoryCapturePieces);
            mandatoryCapturePieces.clear(); // Pretend no mandatory moves
            bool isValidLanding = isMoveValid(pieceIndex, landingIndex);
            mandatoryCapturePieces = tempMandatory; // Restore mandatory moves

            if (isValidLanding && (dRow.abs() == 2)) {
              // Ensure it was actually a capture validation
              possibleLandings.add(landingIndex);
            }
          }
        }
      }
    } else {
      // King
      for (int dRow in [-1, 1]) {
        for (int dCol in [-1, 1]) {
          int opponentRow = -1, opponentCol = -1;
          int opponentCount = 0;
          // Raycast along the diagonal
          for (int dist = 1; ; dist++) {
            int currentRow = row + dRow * dist;
            int currentCol = col + dCol * dist;

            if (currentRow < 0 ||
                currentRow > 7 ||
                currentCol < 0 ||
                currentCol > 7)
              break; // Off board

            GamePiece? currentPiece = board[currentRow][currentCol];

            if (currentPiece == null) {
              // Empty square
              // If we just jumped exactly one opponent...
              if (opponentCount == 1) {
                // ...check if this empty square is the one *immediately* after
                if (currentRow == opponentRow + dRow &&
                    currentCol == opponentCol + dCol) {
                  int landingIndex = currentRow * 8 + currentCol;
                  // Check if landing here is valid (considering mandatory rules)
                  List<int> tempMandatory = List.from(mandatoryCapturePieces);
                  mandatoryCapturePieces = [
                    pieceIndex,
                  ]; // Assume this piece MUST capture for validation
                  bool isValidLanding = isMoveValid(pieceIndex, landingIndex);
                  mandatoryCapturePieces = tempMandatory; // Restore

                  if (isValidLanding) {
                    possibleLandings.add(landingIndex);
                    // In Russian checkers, king stops after capture for multi-jump check
                    // So we only add the square right after the captured piece.
                    break; // Stop raycast on this diagonal after finding the landing spot
                  } else {
                    // If landing right after isn't valid (e.g., blocked further), stop.
                    break;
                  }
                } else {
                  // If empty square is further than 1 step after opponent, King cannot land here for capture
                  break; // Stop raycast on this diagonal after opponent
                }
              }
              // If no opponent found yet, continue searching empty squares
              else if (opponentCount == 0) {
                continue;
              }
            } else if (currentPiece.color == piece.color) {
              // Blocked by own piece
              break; // Stop raycast
            } else {
              // Opponent piece
              if (opponentCount == 0) {
                // Found the first opponent
                opponentRow = currentRow;
                opponentCol = currentCol;
                opponentCount = 1;
                // Continue raycast to find the empty square after it
              } else {
                // Found a second opponent piece
                break; // Cannot jump two pieces
              }
            }
          } // End raycast loop (dist)
        } // End dCol loop
      } // End dRow loop
    } // End King logic

    return possibleLandings;
  }

  // Helper function to get all possible moves (capture or regular) for the current player
  List<Move> getAllPossibleMoves() {
    List<Move> allMoves = [];
    List<int> piecesToCheck = [];

    // If mandatory captures exist, only check those pieces
    if (mandatoryCapturePieces.isNotEmpty) {
      piecesToCheck = List.from(mandatoryCapturePieces);
    } else {
      // Otherwise, check all pieces of the current player
      for (int i = 0; i < 64; i++) {
        GamePiece? p = board[i ~/ 8][i % 8];
        if (p != null && (p.color == Colors.white) == isWhiteTurn) {
          piecesToCheck.add(i);
        }
      }
    }

    // Find valid moves for the selected pieces
    for (int fromIndex in piecesToCheck) {
      if (mandatoryCapturePieces.isNotEmpty) {
        // Find only capture landings
        List<int> landings = findCapturesForPiece(fromIndex);
        for (int toIndex in landings) {
          allMoves.add(Move(fromIndex, toIndex));
        }
      } else {
        // Find regular moves (check all squares as potential destinations)
        GamePiece? piece = board[fromIndex ~/ 8][fromIndex % 8];
        if (piece?.type == PieceType.man) {
          // Check forward moves for man
          int moveDir = (piece!.color == Colors.white) ? -1 : 1;
          int r = fromIndex ~/ 8;
          int c = fromIndex % 8;
          int targetR = r + moveDir;
          // Check left diagonal
          int targetCL = c - 1;
          int toIndexL = targetR * 8 + targetCL;
          if (targetR >= 0 && targetR <= 7 && targetCL >= 0 && targetCL <= 7) {
            if (isMoveValid(fromIndex, toIndexL))
              allMoves.add(Move(fromIndex, toIndexL));
          }
          // Check right diagonal
          int targetCR = c + 1;
          int toIndexR = targetR * 8 + targetCR;
          if (targetR >= 0 && targetR <= 7 && targetCR >= 0 && targetCR <= 7) {
            if (isMoveValid(fromIndex, toIndexR))
              allMoves.add(Move(fromIndex, toIndexR));
          }
        } else if (piece?.type == PieceType.king) {
          // Raycast for King's quiet moves
          for (int dRow in [-1, 1]) {
            for (int dCol in [-1, 1]) {
              for (int dist = 1; ; dist++) {
                int r = fromIndex ~/ 8;
                int c = fromIndex % 8;
                int targetR = r + dRow * dist;
                int targetC = c + dCol * dist;
                if (targetR < 0 || targetR > 7 || targetC < 0 || targetC > 7)
                  break; // Off board
                int toIndex = targetR * 8 + targetC;
                if (isMoveValid(fromIndex, toIndex)) {
                  // isMoveValid confirms it's a quiet move here
                  allMoves.add(Move(fromIndex, toIndex));
                } else {
                  // If blocked or invalid, stop ray in this direction
                  break;
                }
                // If the square wasn't empty, stop ray (already checked in isMoveValid indirectly)
                if (board[targetR][targetC] != null) break;
              }
            }
          }
        }
      }
    }
    return allMoves;
  }

  Color? checkWinner() {
    // Check if the current player has any moves
    if (getAllPossibleMoves().isEmpty) {
      // If no moves, the *other* player wins
      return isWhiteTurn ? Colors.black : Colors.white;
    }
    // Check if pieces remain for both sides
    bool hasWhite = false;
    bool hasBlack = false;
    for (var row in board) {
      for (var piece in row) {
        if (piece != null) {
          if (piece.color == Colors.white) hasWhite = true;
          if (piece.color == Colors.black) hasBlack = true;
        }
        if (hasWhite && hasBlack) break; // Early exit if both found
      }
    }
    if (!hasWhite) return Colors.black; // Black wins if White has no pieces
    if (!hasBlack) return Colors.white; // White wins if Black has no pieces

    return null; // Game continues
  }

  // Clone remains the same - copies board state, turn, score, mandatory pieces
  CheckersGameLogic clone() {
    final newGame = CheckersGameLogic();
    // Deep copy board
    newGame.board = List.generate(
      8,
      (row) => List.generate(8, (col) => board[row][col]?.clone()),
    );
    newGame.isWhiteTurn = isWhiteTurn;
    newGame.whiteCaptured = whiteCaptured;
    newGame.blackCaptured = blackCaptured;
    // Copy mandatory pieces, IMPORTANT for AI simulation
    newGame.mandatoryCapturePieces = List.from(mandatoryCapturePieces);
    newGame.moveHistory = List.from(moveHistory);
    newGame._history = List.from(_history);
    return newGame;
  }
}
