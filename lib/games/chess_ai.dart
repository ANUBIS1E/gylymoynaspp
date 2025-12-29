import 'dart:math';
import 'package:chess/chess.dart' as chess;
import 'chess_logic.dart';

class ChessAI {

  // Таблицы позиционной оценки для пешек (белые)
  static const List<List<double>> _pawnTable = [
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0],
    [1.0, 1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 1.0],
    [0.5, 0.5, 1.0, 2.5, 2.5, 1.0, 0.5, 0.5],
    [0.0, 0.0, 0.0, 2.0, 2.0, 0.0, 0.0, 0.0],
    [0.5, -0.5, -1.0, 0.0, 0.0, -1.0, -0.5, 0.5],
    [0.5, 1.0, 1.0, -2.0, -2.0, 1.0, 1.0, 0.5],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  ];

  // Таблица для коней
  static const List<List<double>> _knightTable = [
    [-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0],
    [-4.0, -2.0, 0.0, 0.0, 0.0, 0.0, -2.0, -4.0],
    [-3.0, 0.0, 1.0, 1.5, 1.5, 1.0, 0.0, -3.0],
    [-3.0, 0.5, 1.5, 2.0, 2.0, 1.5, 0.5, -3.0],
    [-3.0, 0.0, 1.5, 2.0, 2.0, 1.5, 0.0, -3.0],
    [-3.0, 0.5, 1.0, 1.5, 1.5, 1.0, 0.5, -3.0],
    [-4.0, -2.0, 0.0, 0.5, 0.5, 0.0, -2.0, -4.0],
    [-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0]
  ];

  String? findBestMove(ChessGameLogic game, int difficulty) {
    final int maxDepth = _getDifficultyDepth(difficulty);

    // Для низких уровней используем случайность
    if (difficulty <= 2) {
      var possibleMoves = game.game.moves({'verbose': true});
      if (possibleMoves.isEmpty) return null;

      // 30% шанс сделать случайный ход на уровне 1
      if (difficulty == 1 && Random().nextDouble() < 0.3) {
        final randomMove = possibleMoves[Random().nextInt(possibleMoves.length)];
        return randomMove['san'] as String;
      }
    }

    double bestValue = -double.infinity;
    String? bestMove;

    var possibleMoves = game.game.moves({'verbose': true});
    if (possibleMoves.isEmpty) return null;

    // Сортировка ходов для лучшей альфа-бета отсечки
    possibleMoves = _sortMoves(possibleMoves, game);

    // Ограничиваем количество рассматриваемых ходов для скорости
    final movesToConsider = difficulty <= 4 ? min(10, possibleMoves.length) : possibleMoves.length;

    for (int i = 0; i < movesToConsider; i++) {
      final moveObj = possibleMoves[i];
      final move = moveObj['san'] as String;
      final tempGame = game.clone();
      tempGame.game.move(move);

      double moveValue = _minimax(tempGame, maxDepth - 1, false, -double.infinity, double.infinity);

      if (moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
    }

    return bestMove;
  }

  // Быстрая сортировка ходов без клонирования игры
  List<dynamic> _sortMoves(List<dynamic> moves, ChessGameLogic game) {
    moves.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      // Приоритет взятиям (MVV-LVA: Most Valuable Victim - Least Valuable Attacker)
      if (a['captured'] != null) {
        scoreA += _getPieceValue(a['captured']) * 10;
        scoreA -= _getPieceValue(a['piece']);
      }
      if (b['captured'] != null) {
        scoreB += _getPieceValue(b['captured']) * 10;
        scoreB -= _getPieceValue(b['piece']);
      }

      // Приоритет продвижению пешек
      if (a['piece'] == 'p' && (a['to'] as String)[1] == '7') scoreA += 30;
      if (a['piece'] == 'p' && (a['to'] as String)[1] == '8') scoreA += 50;
      if (b['piece'] == 'p' && (b['to'] as String)[1] == '2') scoreB += 30;
      if (b['piece'] == 'p' && (b['to'] as String)[1] == '1') scoreB += 50;

      // Приоритет центральным ходам
      final centerSquares = ['d4', 'e4', 'd5', 'e5'];
      if (centerSquares.contains(a['to'])) scoreA += 10;
      if (centerSquares.contains(b['to'])) scoreB += 10;

      return scoreB - scoreA;
    });

    return moves;
  }

  int _getPieceValue(String pieceType) {
    switch (pieceType.toLowerCase()) {
      case 'p': return 1;
      case 'n': return 3;
      case 'b': return 3;
      case 'r': return 5;
      case 'q': return 9;
      case 'k': return 0;
      default: return 0;
    }
  }

  double _minimax(ChessGameLogic game, int depth, bool isMaximizingPlayer, double alpha, double beta) {
    if (depth == 0 || game.game.game_over) {
      return _evaluateBoard(game.game);
    }

    final possibleMoves = game.game.moves();
    if (possibleMoves.isEmpty) return _evaluateBoard(game.game);

    if (isMaximizingPlayer) {
      double maxEval = -double.infinity;
      for (final move in possibleMoves) {
        final tempGame = game.clone();
        tempGame.game.move(move);
        double eval = _minimax(tempGame, depth - 1, false, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in possibleMoves) {
        final tempGame = game.clone();
        tempGame.game.move(move);
        double eval = _minimax(tempGame, depth - 1, true, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  double _evaluateBoard(chess.Chess game) {
    if (game.in_checkmate) {
      return game.turn == chess.Color.BLACK ? -9999 : 9999;
    }
    if (game.in_draw || game.in_stalemate) {
      return 0;
    }

    double score = 0;

    // Подсчет текущей очереди для оценки мобильности
    final currentTurn = game.turn;
    int whiteMoveCount = 0;
    int blackMoveCount = 0;

    // Материал + позиция
    for (final squareName in chess.Chess.SQUARES.keys) {
      final piece = game.get(squareName);
      if (piece != null) {
        score += _getPieceValueWithPosition(piece, squareName);
      }
    }

    // Бонус за контроль центра
    score += _evaluateControl(game) * 0.1;

    // Бонус за мобильность (считаем ходы для текущей позиции)
    final currentMoves = game.moves().length;
    if (currentTurn == chess.Color.WHITE) {
      whiteMoveCount = currentMoves;
    } else {
      blackMoveCount = currentMoves;
    }
    score += (whiteMoveCount - blackMoveCount) * 0.05;

    return score;
  }

  double _getPieceValueWithPosition(chess.Piece piece, String squareName) {
    double baseValue = 0;
    double positionValue = 0;

    // Базовая ценность фигуры
    switch (piece.type) {
      case chess.PieceType.PAWN:
        baseValue = 100;
        positionValue = _getPositionValue(piece, squareName, _pawnTable);
        break;
      case chess.PieceType.KNIGHT:
        baseValue = 320;
        positionValue = _getPositionValue(piece, squareName, _knightTable);
        break;
      case chess.PieceType.BISHOP:
        baseValue = 330;
        break;
      case chess.PieceType.ROOK:
        baseValue = 500;
        break;
      case chess.PieceType.QUEEN:
        baseValue = 900;
        break;
      case chess.PieceType.KING:
        baseValue = 0;
        break;
    }

    final totalValue = baseValue + positionValue;
    return piece.color == chess.Color.WHITE ? totalValue / 100 : -totalValue / 100;
  }

  double _getPositionValue(chess.Piece piece, String squareName, List<List<double>> table) {
    final file = squareName.codeUnitAt(0) - 97; // a=0, b=1, ...
    final rank = int.parse(squareName[1]) - 1;   // 1=0, 2=1, ...

    if (piece.color == chess.Color.WHITE) {
      return table[7 - rank][file]; // Белые снизу
    } else {
      return table[rank][file];     // Черные сверху
    }
  }

  double _evaluateControl(chess.Chess game) {
    // Оценка контроля центральных клеток
    double control = 0;
    final centerSquares = ['d4', 'e4', 'd5', 'e5'];

    for (final square in centerSquares) {
      final piece = game.get(square);
      if (piece != null) {
        control += piece.color == chess.Color.WHITE ? 1 : -1;
      }
    }

    return control;
  }

  int _getDifficultyDepth(int difficulty) {
    // Очень быстрая глубина для мгновенного отклика
    if (difficulty <= 2) return 1;  // Новичок - мгновенно
    if (difficulty <= 4) return 1;  // Легкий - мгновенно
    if (difficulty <= 6) return 2;  // Средний - быстро
    if (difficulty <= 8) return 2;  // Сильный - быстро
    return 3;                        // Эксперт - нормально
  }
}
