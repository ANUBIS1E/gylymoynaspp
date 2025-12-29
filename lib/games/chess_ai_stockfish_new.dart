import 'dart:async';
import 'package:stockfish_chess_engine/stockfish_chess_engine.dart';
import 'chess_logic.dart';

/// Профессиональный шахматный ИИ на основе Stockfish (кроссплатформенный)
/// Поддерживает Android, iOS, macOS, Windows, Linux
class ChessAIStockfishNew {
  late Stockfish _stockfish;
  bool _isInitialized = false;
  StreamSubscription? _subscription;

  /// Инициализация Stockfish движка
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _stockfish = Stockfish();

      // Подписываемся на вывод движка
      _subscription = _stockfish.stdout.listen((line) {
        print('Stockfish: $line');
      });

      // Инициализируем движок
      _stockfish.stdin = 'uci';
      await Future.delayed(Duration(milliseconds: 200));
      _stockfish.stdin = 'isready';
      await Future.delayed(Duration(milliseconds: 200));

      _isInitialized = true;
      print('✓ Stockfish инициализирован успешно');
    } catch (e) {
      print('✗ Ошибка инициализации Stockfish: $e');
      _isInitialized = false;
    }
  }

  /// Найти лучший ход для текущей позиции
  Future<String?> findBestMove(ChessGameLogic game, int difficulty) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      print('✗ Stockfish не инициализирован');
      final moves = game.game.moves();
      return moves.isEmpty ? null : moves[0];
    }

    try {
      // Настройки по уровням сложности
      final settings = _getDifficultySettings(difficulty);

      // Устанавливаем позицию
      final fen = game.game.fen;
      _stockfish.stdin = 'position fen $fen';

      // Настраиваем параметры движка
      _stockfish.stdin = 'setoption name Skill Level value ${settings['skillLevel']}';

      // Запускаем поиск
      final searchCommand = settings['moveTime'] != null
          ? 'go movetime ${settings['moveTime']}'
          : 'go depth ${settings['depth']}';
      _stockfish.stdin = searchCommand;

      // Ждем результат
      String? bestMove;
      final completer = Completer<String?>();

      StreamSubscription? tempSub;
      tempSub = _stockfish.stdout.listen((line) {
        if (line.startsWith('bestmove')) {
          final parts = line.split(' ');
          if (parts.length >= 2) {
            bestMove = parts[1];
            final convertedMove = _convertToStandardNotation(bestMove!, game);
            completer.complete(convertedMove);
          }
          tempSub?.cancel();
        }
      });

      // Таймаут
      final result = await completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          tempSub?.cancel();
          print('⚠ Таймаут Stockfish');
          final moves = game.game.moves();
          return moves.isEmpty ? null : moves[0];
        },
      );

      return result;
    } catch (e) {
      print('✗ Ошибка при поиске хода: $e');
      final moves = game.game.moves();
      return moves.isEmpty ? null : moves[0];
    }
  }

  /// Настройки для каждого уровня сложности
  Map<String, dynamic> _getDifficultySettings(int difficulty) {
    switch (difficulty) {
      case 1: // Новичок - очень слабый
        return {'skillLevel': 0, 'moveTime': 100};
      case 2: // Новичок
        return {'skillLevel': 2, 'moveTime': 200};
      case 3: // Легкий
        return {'skillLevel': 5, 'moveTime': 300};
      case 4: // Легко-средний
        return {'skillLevel': 7, 'moveTime': 500};
      case 5: // Средний
        return {'skillLevel': 10, 'moveTime': 1000};
      case 6: // Средне-сильный
        return {'skillLevel': 12, 'moveTime': 1500};
      case 7: // Сильный
        return {'skillLevel': 15, 'moveTime': 2000};
      case 8: // Очень сильный
        return {'skillLevel': 17, 'depth': 15};
      case 9: // Эксперт
        return {'skillLevel': 19, 'depth': 18};
      case 10: // Гроссмейстер
        return {'skillLevel': 20, 'depth': 20};
      default:
        return {'skillLevel': 10, 'moveTime': 1000};
    }
  }

  /// Конвертация хода из UCI формата (e2e4) в стандартный формат (e4)
  String? _convertToStandardNotation(String uciMove, ChessGameLogic game) {
    try {
      final moves = game.game.moves({'verbose': true});

      for (final move in moves) {
        final from = move['from'] as String;
        final to = move['to'] as String;
        final promotion = move['promotion'] as String?;

        String moveUci = '$from$to';
        if (promotion != null) {
          moveUci += promotion;
        }

        if (moveUci == uciMove) {
          return move['san'] as String;
        }
      }

      // Пробуем без promotion
      if (uciMove.length > 4) {
        final baseMove = uciMove.substring(0, 4);
        return _convertToStandardNotation(baseMove, game);
      }

      print('⚠ Не удалось конвертировать ход: $uciMove');
      return null;
    } catch (e) {
      print('✗ Ошибка конвертации хода: $e');
      return null;
    }
  }

  /// Освобождение ресурсов
  void dispose() {
    _subscription?.cancel();
    _stockfish.stdin = 'quit';
    _isInitialized = false;
  }
}
