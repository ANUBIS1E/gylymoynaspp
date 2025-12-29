import 'dart:math';
import 'package:flutter/material.dart';
import 'togyz_kumalak_logic.dart';

class TogyzKumalakAI {
  // Стратегические веса для оценки позиции
  static const double KAZAN_WEIGHT = 1.0;
  static const double TUZDYK_WEIGHT = 15.0;
  static const double TUZDYK_THREAT_WEIGHT = 8.0;
  static const double CAPTURE_POTENTIAL_WEIGHT = 3.0;
  static const double PIT_CONTROL_WEIGHT = 0.5;
  static const double EMPTY_PIT_PENALTY = 0.3;

  int findBestMove(TogyzKumalakLogic game, int depth) {
    double bestValue = -double.infinity;
    int bestMove = -1;

    // ИИ (черные) может ходить только из лунок 9-17
    List<int> possibleMoves = [];
    for (int i = 9; i < 18; i++) {
      if (game.otaus[i] > 0) possibleMoves.add(i);
    }

    if (possibleMoves.isEmpty) {
      for (int i = 9; i < 18; i++) {
        if (game.otaus[i] > 0) return i;
      }
      return -1;
    }

    // Сортируем ходы для лучшей alpha-beta отсечки
    possibleMoves = _sortMoves(possibleMoves, game);

    for (int move in possibleMoves) {
      final tempGame = game.clone();
      tempGame.makeMove(move);

      double moveValue = _minimax(
        tempGame,
        depth - 1,
        false,
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

  // Сортировка ходов по приоритету
  List<int> _sortMoves(List<int> moves, TogyzKumalakLogic game) {
    moves.sort((a, b) {
      int scoreA = _evaluateMoveQuick(a, game);
      int scoreB = _evaluateMoveQuick(b, game);
      return scoreB - scoreA;
    });
    return moves;
  }

  // Быстрая оценка хода для сортировки
  int _evaluateMoveQuick(int move, TogyzKumalakLogic game) {
    int score = 0;
    final seeds = game.otaus[move];

    // Приоритет ходам с большим количеством кумалаков
    score += seeds * 2;

    // Проверяем может ли ход создать тудзик
    final tempGame = game.clone();
    final hadTuzdyk = tempGame.blackTuzdyk != null;
    tempGame.makeMove(move);
    if (!hadTuzdyk && tempGame.blackTuzdyk != null) {
      score += 100; // Очень высокий приоритет созданию тудзика
    }

    // Приоритет ходам которые захватывают много кумалаков
    final kazanBefore = game.blackKazan;
    final kazanAfter = tempGame.blackKazan;
    score += (kazanAfter - kazanBefore) * 10;

    return score;
  }

  // Минимакс с alpha-beta pruning
  double _minimax(
    TogyzKumalakLogic game,
    int depth,
    bool isMaximizingPlayer,
    double alpha,
    double beta,
  ) {
    if (depth == 0 || game.winner != null) {
      return _evaluateBoard(game);
    }

    List<int> possibleMoves = [];
    if (isMaximizingPlayer) {
      // Ход ИИ (черные)
      for (int i = 9; i < 18; i++) {
        if (game.otaus[i] > 0) possibleMoves.add(i);
      }
    } else {
      // Ход игрока (белые)
      for (int i = 0; i < 9; i++) {
        if (game.otaus[i] > 0) possibleMoves.add(i);
      }
    }

    if (possibleMoves.isEmpty) {
      return _evaluateBoard(game);
    }

    if (isMaximizingPlayer) {
      double maxEval = -double.infinity;
      for (final move in possibleMoves) {
        final tempGame = game.clone();
        tempGame.makeMove(move);
        double eval = _minimax(tempGame, depth - 1, false, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in possibleMoves) {
        final tempGame = game.clone();
        tempGame.makeMove(move);
        double eval = _minimax(tempGame, depth - 1, true, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minEval;
    }
  }

  // Улучшенная оценочная функция
  double _evaluateBoard(TogyzKumalakLogic game) {
    // Проверка победы
    if (game.winner != null) {
      if (game.winner == Colors.black) return 10000;
      if (game.winner == Colors.white) return -10000;
    }

    double score = 0;

    // 1. Основная оценка: разница в казанах
    score += (game.blackKazan - game.whiteKazan) * KAZAN_WEIGHT;

    // 2. Оценка тудзиков
    if (game.blackTuzdyk != null) {
      score += TUZDYK_WEIGHT;
      // Бонус если тудзик полон
      if (game.otaus[game.blackTuzdyk!] > 0) {
        score += game.otaus[game.blackTuzdyk!] * 0.5;
      }
    }
    if (game.whiteTuzdyk != null) {
      score -= TUZDYK_WEIGHT;
      if (game.otaus[game.whiteTuzdyk!] > 0) {
        score -= game.otaus[game.whiteTuzdyk!] * 0.5;
      }
    }

    // 3. Потенциальные угрозы тудзика
    score += _evaluateTuzdykThreats(game);

    // 4. Потенциал захвата
    score += _evaluateCapturePotential(game);

    // 5. Контроль лунок (распределение кумалаков)
    score += _evaluatePitControl(game);

    // 6. Штраф за пустые лунки (плохо иметь много пустых лунок)
    score -= _countEmptyPits(game, Colors.black) * EMPTY_PIT_PENALTY;
    score += _countEmptyPits(game, Colors.white) * EMPTY_PIT_PENALTY;

    return score;
  }

  // Оценка угроз создания тудзика
  double _evaluateTuzdykThreats(TogyzKumalakLogic game) {
    double score = 0;

    // Проверяем лунки противника на наличие 3 кумалаков (потенциальный тудзик)
    for (int i = 0; i < 9; i++) {
      if (game.otaus[i] == 3 && game.whiteTuzdyk != i) {
        // Белые могут сделать тудзик на следующем ходу
        score -= TUZDYK_THREAT_WEIGHT;
      }
    }

    for (int i = 9; i < 18; i++) {
      if (game.otaus[i] == 3 && game.blackTuzdyk != i) {
        // Черные могут сделать тудзик на следующем ходу
        score += TUZDYK_THREAT_WEIGHT;
      }
    }

    return score;
  }

  // Оценка потенциала захвата кумалаков
  double _evaluateCapturePotential(TogyzKumalakLogic game) {
    double score = 0;

    // Проверяем какие ходы могут привести к захвату
    // Для черных
    for (int i = 9; i < 18; i++) {
      if (game.otaus[i] > 0) {
        final targetPit = (i + game.otaus[i]) % 18;
        // Если последний кумалак упадет в четную лунку противника - захват
        if (targetPit < 9 && game.otaus[targetPit] > 0 && (game.otaus[targetPit] + 1) % 2 == 0) {
          score += CAPTURE_POTENTIAL_WEIGHT;
        }
      }
    }

    // Для белых
    for (int i = 0; i < 9; i++) {
      if (game.otaus[i] > 0) {
        final targetPit = (i + game.otaus[i]) % 18;
        if (targetPit >= 9 && game.otaus[targetPit] > 0 && (game.otaus[targetPit] + 1) % 2 == 0) {
          score -= CAPTURE_POTENTIAL_WEIGHT;
        }
      }
    }

    return score;
  }

  // Оценка контроля лунок (хорошо иметь равномерное распределение)
  double _evaluatePitControl(TogyzKumalakLogic game) {
    double score = 0;

    // Подсчитываем общее количество кумалаков в лунках каждого игрока
    int blackTotal = 0;
    int whiteTotal = 0;

    for (int i = 0; i < 9; i++) {
      whiteTotal += game.otaus[i];
    }
    for (int i = 9; i < 18; i++) {
      blackTotal += game.otaus[i];
    }

    score += (blackTotal - whiteTotal) * PIT_CONTROL_WEIGHT;

    // Бонус за наличие больших стопок (можно сделать длинные ходы)
    for (int i = 9; i < 18; i++) {
      if (game.otaus[i] >= 10) score += 1.0;
    }
    for (int i = 0; i < 9; i++) {
      if (game.otaus[i] >= 10) score -= 1.0;
    }

    return score;
  }

  // Подсчет пустых лунок
  int _countEmptyPits(TogyzKumalakLogic game, Color color) {
    int count = 0;
    if (color == Colors.black) {
      for (int i = 9; i < 18; i++) {
        if (game.otaus[i] == 0) count++;
      }
    } else {
      for (int i = 0; i < 9; i++) {
        if (game.otaus[i] == 0) count++;
      }
    }
    return count;
  }

  // Метод для получения подсказки с объяснением
  MoveWithExplanation? suggestMoveWithExplanation(
    TogyzKumalakLogic game,
    int depth,
    Color playerColor,
  ) {
    // Определяем диапазон ходов игрока
    final startPit = playerColor == Colors.white ? 0 : 9;
    final endPit = playerColor == Colors.white ? 9 : 18;

    double bestValue = -double.infinity;
    int bestMove = -1;

    List<int> possibleMoves = [];
    for (int i = startPit; i < endPit; i++) {
      if (game.otaus[i] > 0) possibleMoves.add(i);
    }

    if (possibleMoves.isEmpty) return null;

    for (int move in possibleMoves) {
      final tempGame = game.clone();
      tempGame.makeMove(move);

      double moveValue = _minimax(
        tempGame,
        depth - 1,
        playerColor == Colors.black, // isMaximizing for black
        -double.infinity,
        double.infinity,
      );

      if (moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
    }

    if (bestMove == -1) return null;

    // Анализируем почему этот ход хорош
    final tempGame = game.clone();
    final kazanBefore = playerColor == Colors.white ? tempGame.whiteKazan : tempGame.blackKazan;
    final hadTuzdyk = playerColor == Colors.white ? tempGame.whiteTuzdyk != null : tempGame.blackTuzdyk != null;

    tempGame.makeMove(bestMove);

    final kazanAfter = playerColor == Colors.white ? tempGame.whiteKazan : tempGame.blackKazan;
    final hasTuzdyk = playerColor == Colors.white ? tempGame.whiteTuzdyk != null : tempGame.blackTuzdyk != null;

    String explanation = '';
    if (!hadTuzdyk && hasTuzdyk) {
      explanation = 'Этот ход создает тудзик - лунку которая автоматически забирает кумалаки противника!';
    } else if (kazanAfter > kazanBefore) {
      final captured = kazanAfter - kazanBefore;
      explanation = 'Этот ход захватывает $captured кумалак${captured > 1 ? "а" : ""} в ваш казан';
    } else {
      final seeds = game.otaus[bestMove];
      final targetPit = (bestMove + seeds) % 18;
      final targetSide = targetPit < 9 ? 'противника' : 'вашей';

      if (seeds >= 10) {
        explanation = 'Этот ход распределяет $seeds кумалаков по доске, улучшая вашу позицию';
      } else {
        explanation = 'Этот ход завершается в лунке $targetSide стороны и создает хорошую позицию';
      }
    }

    return MoveWithExplanation(
      move: bestMove,
      explanation: explanation,
      pitNumber: bestMove - (playerColor == Colors.white ? 0 : 9) + 1,
    );
  }
}

// Класс для хода с объяснением
class MoveWithExplanation {
  final int move; // Индекс лунки (0-17)
  final String explanation;
  final int pitNumber; // Номер лунки для отображения (1-9)

  MoveWithExplanation({
    required this.move,
    required this.explanation,
    required this.pitNumber,
  });
}
