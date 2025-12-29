import 'dart:math';
import 'package:flutter/material.dart';
import 'checkers_logic.dart';

class CheckersAI {
  // Позиционные веса для обычных шашек (чем ближе к концу доски, тем лучше)
  static const List<List<double>> _positionWeights = [
    [0.0, 4.0, 0.0, 4.0, 0.0, 4.0, 0.0, 4.0], // Ряд короля
    [4.0, 0.0, 3.0, 0.0, 3.0, 0.0, 3.0, 0.0],
    [0.0, 3.0, 0.0, 2.5, 0.0, 2.5, 0.0, 3.0],
    [2.5, 0.0, 2.0, 0.0, 2.0, 0.0, 2.5, 0.0],
    [0.0, 2.0, 0.0, 1.5, 0.0, 1.5, 0.0, 2.0],
    [1.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.5, 0.0],
    [0.0, 1.0, 0.0, 0.5, 0.0, 0.5, 0.0, 1.0],
    [0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5], // Начальный ряд
  ];

  // Главный метод поиска лучшего хода
  Move? findBestMove(
    CheckersGameLogic game,
    int depth, {
    required Color aiColor,
  }) {
    double bestValue = -double.infinity;
    Move? bestMove;

    final possibleMoves = game.getAllPossibleMoves();
    if (possibleMoves.isEmpty) return null;

    // Сортируем ходы: сначала взятия, потом продвижение к королю
    final sortedMoves = _sortMoves(possibleMoves, game, aiColor);

    for (final move in sortedMoves) {
      final tempGame = game.clone();
      tempGame.tryMove(move.from, move.to);

      // Минимакс с alpha-beta pruning
      double moveValue = _minimax(
        tempGame,
        depth - 1,
        false,
        aiColor,
        -double.infinity,
        double.infinity,
      );

      if (moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
    }
    return bestMove;
  }

  // Сортировка ходов для лучшей alpha-beta отсечки
  List<Move> _sortMoves(
    List<Move> moves,
    CheckersGameLogic game,
    Color aiColor,
  ) {
    moves.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      // Приоритет взятиям (проверяем есть ли шашка противника на доске после хода)
      final tempGameA = game.clone();
      final pieceCountBeforeA = _countPieces(tempGameA.board, _oppositeColor(aiColor));
      tempGameA.tryMove(a.from, a.to);
      final pieceCountAfterA = _countPieces(tempGameA.board, _oppositeColor(aiColor));
      if (pieceCountAfterA < pieceCountBeforeA) scoreA += 100;

      final tempGameB = game.clone();
      final pieceCountBeforeB = _countPieces(tempGameB.board, _oppositeColor(aiColor));
      tempGameB.tryMove(b.from, b.to);
      final pieceCountAfterB = _countPieces(tempGameB.board, _oppositeColor(aiColor));
      if (pieceCountAfterB < pieceCountBeforeB) scoreB += 100;

      // Приоритет продвижению к королю (для белых - к row 0, для черных - к row 7)
      final kingRow = aiColor == Colors.white ? 0 : 7;
      final distanceA = (a.to ~/ 8 - kingRow).abs();
      final distanceB = (b.to ~/ 8 - kingRow).abs();
      scoreA -= distanceA;
      scoreB -= distanceB;

      return scoreB - scoreA;
    });
    return moves;
  }

  int _countPieces(List<List<GamePiece?>> board, Color color) {
    int count = 0;
    for (var row in board) {
      for (var piece in row) {
        if (piece != null && piece.color == color) count++;
      }
    }
    return count;
  }

  Color _oppositeColor(Color color) {
    return color == Colors.white ? Colors.black : Colors.white;
  }

  // Минимакс с alpha-beta pruning
  double _minimax(
    CheckersGameLogic game,
    int depth,
    bool isMaximizingPlayer,
    Color aiColor,
    double alpha,
    double beta,
  ) {
    if (depth == 0) {
      return _evaluateBoard(game.board, aiColor);
    }

    final possibleMoves = game.getAllPossibleMoves();
    if (possibleMoves.isEmpty) {
      // Нет ходов = проигрыш для текущего игрока
      return isMaximizingPlayer ? -9999 : 9999;
    }

    if (isMaximizingPlayer) {
      double maxEval = -double.infinity;
      for (final move in possibleMoves) {
        final tempGame = game.clone();
        tempGame.tryMove(move.from, move.to);
        double eval = _minimax(tempGame, depth - 1, false, aiColor, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in possibleMoves) {
        final tempGame = game.clone();
        tempGame.tryMove(move.from, move.to);
        double eval = _minimax(tempGame, depth - 1, true, aiColor, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minEval;
    }
  }

  // Улучшенная оценочная функция
  double _evaluateBoard(List<List<GamePiece?>> board, Color aiColor) {
    double score = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null) continue;

        // Базовая стоимость фигуры
        double pieceValue = (piece.type == PieceType.king) ? 3.0 : 1.0;

        // Позиционная оценка (только для обычных шашек)
        double positionValue = 0.0;
        if (piece.type == PieceType.man) {
          // Для черных переворачиваем таблицу весов
          final weightRow = piece.color == Colors.white ? 7 - row : row;
          positionValue = _positionWeights[weightRow][col] * 0.1;
        }

        // Бонус за близость к центру для королей
        if (piece.type == PieceType.king) {
          final centerDistance = ((row - 3.5).abs() + (col - 3.5).abs()) / 2;
          positionValue = (7 - centerDistance) * 0.15;
        }

        double totalValue = pieceValue + positionValue;

        if (piece.color == aiColor) {
          score += totalValue;
        } else {
          score -= totalValue;
        }
      }
    }

    // Бонус за контроль центра
    score += _evaluateCenterControl(board, aiColor) * 0.2;

    // Бонус за защищенные шашки
    score += _evaluateProtection(board, aiColor) * 0.1;

    return score;
  }

  // Оценка контроля центра
  double _evaluateCenterControl(List<List<GamePiece?>> board, Color aiColor) {
    double control = 0;
    final centerSquares = [
      [3, 3], [3, 4], [4, 3], [4, 4], // 4 центральные клетки
      [2, 2], [2, 5], [5, 2], [5, 5], // Расширенный центр
    ];

    for (final square in centerSquares) {
      final piece = board[square[0]][square[1]];
      if (piece != null) {
        if (piece.color == aiColor) {
          control += 1.0;
        } else {
          control -= 1.0;
        }
      }
    }
    return control;
  }

  // Оценка защищенности шашек
  double _evaluateProtection(List<List<GamePiece?>> board, Color aiColor) {
    double protection = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null || piece.color != aiColor) continue;

        // Проверяем есть ли союзники по диагоналям сзади
        final behindLeft = aiColor == Colors.white ? [row + 1, col - 1] : [row - 1, col - 1];
        final behindRight = aiColor == Colors.white ? [row + 1, col + 1] : [row - 1, col + 1];

        if (_isValidSquare(behindLeft[0], behindLeft[1])) {
          final ally = board[behindLeft[0]][behindLeft[1]];
          if (ally != null && ally.color == aiColor) protection += 0.5;
        }

        if (_isValidSquare(behindRight[0], behindRight[1])) {
          final ally = board[behindRight[0]][behindRight[1]];
          if (ally != null && ally.color == aiColor) protection += 0.5;
        }
      }
    }
    return protection;
  }

  bool _isValidSquare(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  // Метод для получения подсказки с объяснением
  MoveWithExplanation? suggestMoveWithExplanation(
    CheckersGameLogic game,
    int depth,
    Color playerColor,
  ) {
    final bestMove = findBestMove(game, depth, aiColor: playerColor);
    if (bestMove == null) return null;

    // Анализируем почему этот ход хорош
    final tempGame = game.clone();
    final pieceCountBefore = _countPieces(tempGame.board, _oppositeColor(playerColor));
    tempGame.tryMove(bestMove.from, bestMove.to);
    final pieceCountAfter = _countPieces(tempGame.board, _oppositeColor(playerColor));

    String explanation = '';
    if (pieceCountAfter < pieceCountBefore) {
      explanation = 'Этот ход позволяет взять шашку противника';
    } else {
      final fromRow = bestMove.from ~/ 8;
      final toRow = bestMove.to ~/ 8;
      final kingRow = playerColor == Colors.white ? 0 : 7;

      if (toRow == kingRow) {
        explanation = 'Этот ход превращает шашку в дамку';
      } else if ((toRow - kingRow).abs() < (fromRow - kingRow).abs()) {
        explanation = 'Этот ход продвигает шашку ближе к превращению в дамку';
      } else {
        final toCol = bestMove.to % 8;
        if (toCol >= 3 && toCol <= 4) {
          explanation = 'Этот ход занимает центральную позицию';
        } else {
          explanation = 'Этот ход улучшает позицию';
        }
      }
    }

    return MoveWithExplanation(move: bestMove, explanation: explanation);
  }
}

// Класс для хода с объяснением
class MoveWithExplanation {
  final Move move;
  final String explanation;

  MoveWithExplanation({required this.move, required this.explanation});
}
