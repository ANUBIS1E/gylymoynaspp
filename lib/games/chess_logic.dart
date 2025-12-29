import 'dart:math';
import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';

class ChessGameLogic {
  late chess.Chess game;
  int whiteCapturedValue = 0;
  int blackCapturedValue = 0;

  ChessGameLogic() {
    reset();
  }

  void reset() {
    game = chess.Chess();
    _recalculateScores();
  }

  bool makeMoveSAN(String san) {
    print("[Chess Logic] Attempting move (SAN): $san");
    final moveSuccessful = game.move(san);
    print("[Chess Logic] Move Result (SAN): ${moveSuccessful != false}");
    if (moveSuccessful != false) {
      _recalculateScores();
      return true;
    } else {
      print("[Chess Logic] Move failed (SAN).");
      return false;
    }
  }

  bool makeMove(String from, String to, {String promotion = 'q'}) {
     print("[Chess Logic] Attempting move (Coord): $from -> $to");
    final moveSuccessful = game.move({ 'from': from, 'to': to, 'promotion': promotion });
    print("[Chess Logic] Move Result (Coord): ${moveSuccessful != false}");
    if (moveSuccessful != false) {
       _recalculateScores();
      return true;
    } else {
       print("[Chess Logic] Move failed (Coord).");
       return false;
    }
  }

  bool undoMove() {
    final undoneMove = game.undo();
    if (undoneMove != null) {
      _recalculateScores();
      print("[Chess Logic] Undo successful.");
      return true;
    }
    print("[Chess Logic] Undo failed.");
    return false;
  }

  // --- REVISED RECALCULATE METHOD USING game.get() ---
  void _recalculateScores() {
    int currentWhiteValue = 0;
    int currentBlackValue = 0;

    // Iterate through all square names ('a1'...'h8')
    for (final squareName in chess.Chess.SQUARES.keys) {
      final piece = game.get(squareName); // Get piece by name
      if (piece != null) {
        int value = _getPieceValueForScore(piece.type);
        if (piece.color == chess.Color.WHITE) {
          currentWhiteValue += value;
        } else {
          currentBlackValue += value;
        }
      }
    }

    const int totalPieceValue = 39;
    whiteCapturedValue = totalPieceValue - currentBlackValue;
    blackCapturedValue = totalPieceValue - currentWhiteValue;
    whiteCapturedValue = max(0, whiteCapturedValue);
    blackCapturedValue = max(0, blackCapturedValue);

    print("[Chess Logic] Recalculated Scores: White=$whiteCapturedValue (captured Black), Black=$blackCapturedValue (captured White)");
  }
  // --- END REVISED METHOD ---


  int _getPieceValueForScore(chess.PieceType type) {
    switch (type) {
      case chess.PieceType.PAWN: return 1;
      case chess.PieceType.KNIGHT: return 3;
      case chess.PieceType.BISHOP: return 3;
      case chess.PieceType.ROOK: return 5;
      case chess.PieceType.QUEEN: return 9;
      default: return 0;
    }
  }

  ChessGameLogic clone() {
    final newLogic = ChessGameLogic();
    newLogic.game.load(game.fen);
    return newLogic;
  }

  Color? get winner {
     if (game.game_over) {
      if (game.in_checkmate) { return game.turn == chess.Color.BLACK ? Colors.white : Colors.black; }
      else { return Colors.grey; } // Draw
    }
    return null; // Ongoing
  }
}