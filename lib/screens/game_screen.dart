import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess; // Импорт для Color

// Импортируем все игры и виджеты
import '../games/checkers_logic.dart' as checkers;
import '../widgets/checkers_board_widget.dart';
import '../games/togyz_kumalak_logic.dart' as togyz;
import '../widgets/togyz_kumalak_board_widget.dart';
import '../games/chess_logic.dart' as chess_logic;
import '../widgets/chess_board_widget.dart';
import '../games/backgammon_logic.dart' as backgammon;
import '../widgets/backgammon_board_widget.dart';

import 'game_setup_screen.dart'; // Нужен для enum'ов
import '../l10n/app_localizations.dart'; // Импорт локализации
import '../utils/training_mode_provider.dart'; // Для проверки режима обучения

class GameScreen extends StatefulWidget {
  final String gameKey;
  final GameMode mode;
  final AiDifficulty? difficulty;
  final chess.Color? chessPlayerColor; // Только для Шахмат
  final bool? checkersPlayAsWhite; // Только для Шашек
  final int gameDurationSeconds; // Добавлено для таймера

  const GameScreen({
    Key? key,
    required this.gameKey,
    required this.mode,
    this.difficulty,
    this.chessPlayerColor,
    this.checkersPlayAsWhite,
    required this.gameDurationSeconds, // Добавлено для таймера
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Объекты логики игр (nullable, инициализируются в initState)
  checkers.CheckersGameLogic? _checkersGame;
  togyz.TogyzKumalakLogic? _togyzGame;
  chess_logic.ChessGameLogic? _chessGame;
  backgammon.BackgammonLogic? _backgammonGame;

  Timer? _timer;
  late int _whiteTime; // Будет инициализировано в initState/restart
  late int _blackTime;
  Key _boardKey = UniqueKey(); // Для принудительного перезапуска доски

  // Контроллеры для прокрутки истории ходов (отдельные для каждой панели)
  final ScrollController _moveHistoryScrollController1 = ScrollController();
  final ScrollController _moveHistoryScrollController2 = ScrollController();

  // Навигация по истории ходов
  int?
  _viewingMoveIndex; // null = текущая позиция, иначе - индекс хода в истории
  chess_logic.ChessGameLogic?
  _historicalChessGame; // Копия игры для просмотра истории
  checkers.CheckersGameLogic?
  _historicalCheckersGame; // Копия игры шашек для просмотра истории

  // Удобные геттеры
  bool get _isChess => widget.gameKey == 'chess';
  bool get _isCheckers => widget.gameKey == 'checkers';
  bool get _isTogyz => widget.gameKey == 'togyz';
  bool get _isBackgammon => widget.gameKey == 'backgammon';
  String get _gameName => AppLocalizations.get(widget.gameKey);
  bool get _playerPlaysWhiteInCheckers => widget.checkersPlayAsWhite ?? true;

  bool _isHumanSide(bool isWhiteSide) {
    if (widget.mode == GameMode.pvp) return true;
    if (_isChess) {
      final selected = widget.chessPlayerColor ?? chess.Color.WHITE;
      return (isWhiteSide && selected == chess.Color.WHITE) ||
          (!isWhiteSide && selected == chess.Color.BLACK);
    }
    if (_isCheckers) {
      return (isWhiteSide && _playerPlaysWhiteInCheckers) ||
          (!isWhiteSide && !_playerPlaysWhiteInCheckers);
    }
    // Для остальных игр игрок всегда за белых
    return isWhiteSide;
  }

  String _sideDisplayName(bool isWhiteSide) {
    final suffix = isWhiteSide
        ? AppLocalizations.get('whitePieces')
        : AppLocalizations.get('blackPieces');
    final base = widget.mode == GameMode.pvp
        ? (isWhiteSide
              ? AppLocalizations.get('player1')
              : AppLocalizations.get('player2'))
        : (_isHumanSide(isWhiteSide)
              ? AppLocalizations.get('player1')
              : AppLocalizations.get('computer'));
    return '$base $suffix';
  }

  // Геттер для определения, чей ход
  bool get _isWhiteTurn {
    if (_isCheckers) return _checkersGame?.isWhiteTurn ?? true;
    if (_isTogyz) return _togyzGame?.isWhiteTurn ?? true;
    if (_isChess) return _chessGame?.game.turn == chess.Color.WHITE;
    if (_isBackgammon) return _backgammonGame?.isWhiteTurn ?? true;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _restartGame(
      isInitial: true,
    ); // Используем единый метод для старта и перезапуска
  }

  @override
  void dispose() {
    _timer?.cancel();
    _moveHistoryScrollController1.dispose();
    _moveHistoryScrollController2.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    // Если таймер отключен (время = -1), не запускаем его
    if (widget.gameDurationSeconds == -1) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_isWhiteTurn) {
          if (_whiteTime > 0) _whiteTime--;
        } else {
          if (_blackTime > 0) _blackTime--;
        }
        if (_whiteTime <= 0 || _blackTime <= 0) {
          _timer?.cancel();
          _onGameEnd(_whiteTime <= 0 ? Colors.black : Colors.white);
        }
      });
    });
  }

  void _restartGame({bool isInitial = false}) {
    _timer?.cancel();
    setState(() {
      // Инициализируем/Сбрасываем нужную логику
      if (_isCheckers) _checkersGame = checkers.CheckersGameLogic();
      if (_isTogyz) _togyzGame = togyz.TogyzKumalakLogic();
      if (_isChess) _chessGame = chess_logic.ChessGameLogic();
      if (_isBackgammon) _backgammonGame = backgammon.BackgammonLogic();

      _whiteTime = widget.gameDurationSeconds; // Устанавливаем выбранное время
      _blackTime = widget.gameDurationSeconds;
      _boardKey = UniqueKey();
    });
    if (!isInitial && Navigator.canPop(context)) {
      Navigator.of(context).pop(); // Закрываем диалог "Игра окончена"
    }
    _startTimer(); // Запускаем таймер для всех
  }

  // Общий обработчик для проверки конца игры (вызывается после onMove)
  void _handleGameEnd() {
    Color? winner;
    if (_isCheckers) winner = _checkersGame?.checkWinner();
    if (_isTogyz) winner = _togyzGame?.winner;
    if (_isChess) winner = _chessGame?.winner;
    if (_isBackgammon) winner = _backgammonGame?.winner;

    if (winner != null) {
      _onGameEnd(winner);
    }

    // Прокручиваем историю ходов после каждого хода в шахматах и шашках
    if (_isChess || _isCheckers) {
      _scrollMoveHistoryToEnd();
    }
  }

  // Прокручивает историю ходов в конец
  void _scrollMoveHistoryToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Прокручиваем оба контроллера
      if (_moveHistoryScrollController1.hasClients) {
        _moveHistoryScrollController1.animateTo(
          _moveHistoryScrollController1.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      if (_moveHistoryScrollController2.hasClients) {
        _moveHistoryScrollController2.animateTo(
          _moveHistoryScrollController2.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Получить список всех ходов из PGN
  List<String> _getAllMovesFromPGN() {
    if (_chessGame == null) return [];

    final pgn = _chessGame!.game.pgn();
    if (pgn.isEmpty || !pgn.contains('.')) return [];

    List<String> allMoves = [];
    final lines = pgn.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty && !line.startsWith('[')) {
        final tokens = line.split(RegExp(r'\s+'));

        for (var token in tokens) {
          if (!token.contains('.') && token.isNotEmpty) {
            allMoves.add(token);
          }
        }
      }
    }

    return allMoves;
  }

  // Переход к определенному ходу в истории (универсальный метод для шахмат и шашек)
  void _goToMove(int? moveIndex) {
    if (_isChess && _chessGame == null) return;
    if (_isCheckers && _checkersGame == null) return;

    setState(() {
      if (moveIndex == null) {
        // Возврат к текущей позиции
        _viewingMoveIndex = null;
        _historicalChessGame = null;
        _historicalCheckersGame = null;
        _boardKey = UniqueKey(); // Обновить доску
      } else if (_isChess) {
        // Создать копию игры шахмат и применить ходы до указанного индекса
        _viewingMoveIndex = moveIndex;
        _historicalChessGame = chess_logic.ChessGameLogic();

        final allMoves = _getAllMovesFromPGN();
        for (int i = 0; i <= moveIndex && i < allMoves.length; i++) {
          _historicalChessGame!.makeMoveSAN(allMoves[i]);
        }

        _boardKey = UniqueKey(); // Обновить доску
      } else if (_isCheckers) {
        // Для шашек используем undo для возврата к нужному состоянию
        // Создаем временную копию текущей игры
        _viewingMoveIndex = moveIndex;
        _historicalCheckersGame = _checkersGame!.clone();

        // Отматываем назад до нужной позиции
        final currentMoveCount = _checkersGame!.moveHistory.length;
        final movesToUndo = currentMoveCount - moveIndex - 1;

        for (int i = 0; i < movesToUndo; i++) {
          if (!_historicalCheckersGame!.undoMove()) {
            break; // Если не удалось отменить ход, прекращаем
          }
        }

        _boardKey = UniqueKey(); // Обновить доску
      }
    });
  }

  // Предыдущий ход (универсальный для шахмат и шашек)
  void _previousMove() {
    if (_isChess) {
      final allMoves = _getAllMovesFromPGN();
      if (allMoves.isEmpty) return;

      if (_viewingMoveIndex == null) {
        // Переход с текущей позиции на последний ход
        _goToMove(allMoves.length - 2 >= 0 ? allMoves.length - 2 : 0);
      } else if (_viewingMoveIndex! > 0) {
        _goToMove(_viewingMoveIndex! - 1);
      }
    } else if (_isCheckers) {
      final allMoves = _checkersGame?.moveHistory ?? [];
      if (allMoves.isEmpty) return;

      if (_viewingMoveIndex == null) {
        _goToMove(allMoves.length - 2 >= 0 ? allMoves.length - 2 : 0);
      } else if (_viewingMoveIndex! > 0) {
        _goToMove(_viewingMoveIndex! - 1);
      }
    }
  }

  // Следующий ход (универсальный для шахмат и шашек)
  void _nextMove() {
    if (_isChess) {
      final allMoves = _getAllMovesFromPGN();
      if (allMoves.isEmpty) return;

      if (_viewingMoveIndex == null) {
        return; // Уже на текущей позиции
      } else if (_viewingMoveIndex! < allMoves.length - 1) {
        _goToMove(_viewingMoveIndex! + 1);
      } else {
        // Вернуться к текущей позиции
        _goToMove(null);
      }
    } else if (_isCheckers) {
      final allMoves = _checkersGame?.moveHistory ?? [];
      if (allMoves.isEmpty) return;

      if (_viewingMoveIndex == null) {
        return;
      } else if (_viewingMoveIndex! < allMoves.length - 1) {
        _goToMove(_viewingMoveIndex! + 1);
      } else {
        _goToMove(null);
      }
    }
  }

  void _onGameEnd(Color winnerColor) {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String winnerText;
        if (winnerColor == Colors.white) {
          winnerText = AppLocalizations.get('whiteWins');
        } else if (winnerColor == Colors.black) {
          winnerText = AppLocalizations.get('blackWins');
        } else {
          winnerText = AppLocalizations.get('draw');
        }
        return AlertDialog(
          title: Text(AppLocalizations.get('gameFinished')),
          content: Text(winnerText),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.get('exitToMenu')),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.get('playAgain')),
              onPressed: () => _restartGame(), // Перезапускаем игру
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        // Фон
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade800, Colors.black87],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 1200 ? 60.0 : 15.0,
                      vertical: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: screenWidth > 1200 ? 2 : 3,
                          child: _buildPlayerInfoPanel(true),
                        ), // Панель Белых
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 1200 ? 40.0 : 20.0,
                          ),
                          child: Center(child: _buildGameWidget()),
                        ),
                        Expanded(
                          flex: screenWidth > 1200 ? 2 : 3,
                          child: _buildPlayerInfoPanel(false),
                        ), // Панель Черных
                      ],
                    ),
                  ),
                ),
              ),
              // Кнопка выхода в главное меню (верхний левый угол)
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white70, size: 32),
                  tooltip: AppLocalizations.get('exitToMainMenu'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.get('exitToMainMenu')),
                        content: Text(AppLocalizations.get('exitConfirm')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.get('no')),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Закрываем диалог
                              // Выключаем режим обучения при выходе в меню
                              TrainingMode().setEnabled(false);
                              Navigator.of(context).popUntil(
                                (route) => route.isFirst,
                              ); // Выходим в меню
                            },
                            child: Text(AppLocalizations.get('yes')),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Индикатор режима обучения (верхний правый угол)
              if (TrainingMode().isEnabled)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, color: Colors.black87, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Режим обучения',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Строит боковую панель (универсальная)
  Widget _buildPlayerInfoPanel(bool isWhite) {
    String name = '';
    String time = '';
    int score = 0;
    String scoreLabel = '';
    bool isCurrentTurn = _isWhiteTurn == isWhite;

    // Определяем, нужно ли переворачивать панель
    // Черная панель (правая) переворачивается для игры лицом к лицу
    bool shouldRotate = !isWhite;

    // Определяем данные для отображения
    if (_isCheckers && _checkersGame != null) {
      name = _sideDisplayName(isWhite);
      time = isWhite ? _formatTime(_whiteTime) : _formatTime(_blackTime);
      score = isWhite
          ? _checkersGame!.whiteCaptured
          : _checkersGame!.blackCaptured;
      scoreLabel = AppLocalizations.get('score');
    } else if (_isTogyz && _togyzGame != null) {
      name = _isHumanSide(isWhite)
          ? AppLocalizations.get('player1')
          : (widget.mode == GameMode.pve
                ? AppLocalizations.get('computer')
                : AppLocalizations.get('player2'));
      time = isWhite ? _formatTime(_whiteTime) : _formatTime(_blackTime);
      score = isWhite ? _togyzGame!.whiteKazan : _togyzGame!.blackKazan;
      scoreLabel = AppLocalizations.get('inKazan');
    } else if (_isChess && _chessGame != null) {
      name = _sideDisplayName(isWhite);
      time = isWhite ? _formatTime(_whiteTime) : _formatTime(_blackTime);
      score = isWhite
          ? _chessGame!.whiteCapturedValue
          : _chessGame!.blackCapturedValue;
      scoreLabel = AppLocalizations.get('score');
    } else if (_isBackgammon && _backgammonGame != null) {
      name = _sideDisplayName(isWhite);
      time = isWhite ? _formatTime(_whiteTime) : _formatTime(_blackTime);
      // Показываем шашки противника на баре
      score = isWhite
          ? _backgammonGame!
                .points[backgammon.BackgammonLogic.blackBarIndex]
                .count
          : _backgammonGame!
                .points[backgammon.BackgammonLogic.whiteBarIndex]
                .count;
      scoreLabel = AppLocalizations.get('onBar');
    }

    Widget panelContent = Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              time,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '$scoreLabel $score',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 30),

            // Лог ходов (для шахмат и шашек в обеих панелях)
            if ((_isChess && _chessGame != null) ||
                (_isCheckers && _checkersGame != null)) ...[
              Divider(color: Colors.white30, thickness: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.get('moveHistory'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.amber.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (_viewingMoveIndex != null) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('👁', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Заголовок таблицы
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 25,
                            child: Text(
                              '#',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.get('white'),
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.get('black'),
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Прокручиваемый список ходов
                    Expanded(
                      child: _buildMoveHistoryTable(
                        isWhite
                            ? _moveHistoryScrollController1
                            : _moveHistoryScrollController2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Кнопки навигации по истории (для шахмат и шашек)
              if (_isChess || _isCheckers) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.first_page, size: 16),
                      color: Colors.white70,
                      iconSize: 16,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                      tooltip: 'В начало',
                      onPressed:
                          (_isChess
                              ? _getAllMovesFromPGN().isNotEmpty
                              : (_checkersGame?.moveHistory.isNotEmpty ??
                                    false))
                          ? () => _goToMove(0)
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 16),
                      color: Colors.white70,
                      iconSize: 16,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                      tooltip: 'Предыдущий ход',
                      onPressed: _previousMove,
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 16),
                      color: Colors.white70,
                      iconSize: 16,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                      tooltip: 'Следующий ход',
                      onPressed: _nextMove,
                    ),
                    IconButton(
                      icon: Icon(Icons.last_page, size: 16),
                      color: Colors.white70,
                      iconSize: 16,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(),
                      tooltip: 'В конец',
                      onPressed: () => _goToMove(null),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],
            // Кнопка Отменить ход
            OutlinedButton.icon(
              // Активна только в ход игрока (и неактивна для ИИ)
              onPressed: (isCurrentTurn && _isHumanSide(isWhite))
                  ? () {
                      setState(() {
                        bool success = false;
                        if (_isCheckers)
                          success = _checkersGame?.undoMove() ?? false;
                        if (_isTogyz) success = _togyzGame?.undoMove() ?? false;
                        if (_isChess) success = _chessGame?.undoMove() ?? false;
                        if (_isBackgammon)
                          success = _backgammonGame?.undoMove() ?? false;
                        if (success) print("Undo executed for $_gameName");
                      });
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: (isCurrentTurn && _isHumanSide(isWhite))
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              icon: const Icon(Icons.undo),
              label: Text(AppLocalizations.get('undoMove')),
            ),
            const SizedBox(height: 10),
            // Кнопка Сдаться
            OutlinedButton.icon(
              onPressed: (isCurrentTurn && _isHumanSide(isWhite))
                  ? () =>
                        _onGameEnd(
                          isWhite ? Colors.black : Colors.white,
                        ) // Текущий игрок проигрывает
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: (isCurrentTurn && _isHumanSide(isWhite))
                    ? Colors.redAccent
                    : Colors.grey,
              ),
              icon: const Icon(Icons.flag),
              label: Text(AppLocalizations.get('resign')),
            ),
          ],
        ),
      ),
    );

    // Переворачиваем панель для второго игрока (для игры лицом к лицу)
    if (shouldRotate) {
      return Transform.rotate(
        angle: 3.14159, // 180 градусов в радианах (π)
        child: panelContent,
      );
    }

    return panelContent;
  }

  // Форматирует секунды в MM:SS
  String _formatTime(int seconds) {
    // Если таймер отключен, показываем "--:--"
    if (widget.gameDurationSeconds == -1) return '--:--';

    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Создает таблицу истории ходов для шахмат и шашек
  Widget _buildMoveHistoryTable(ScrollController controller) {
    // Проверяем, какая игра активна
    if (_isCheckers && _checkersGame != null) {
      return _buildCheckersMoveHistoryTable(controller);
    } else if (_isChess && _chessGame != null) {
      return _buildChessMoveHistoryTable(controller);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          AppLocalizations.get('noTimer').contains('No')
              ? 'No moves yet'
              : 'Ходов пока нет',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
    );
  }

  // Создает таблицу истории ходов для шашек
  Widget _buildCheckersMoveHistoryTable(ScrollController controller) {
    if (_checkersGame == null || _checkersGame!.moveHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            AppLocalizations.get('noTimer').contains('No')
                ? 'No moves yet'
                : 'Ходов пока нет',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      );
    }

    // Группируем ходы по парам (белые-черные)
    List<Map<String, String>> moves = [];
    for (int i = 0; i < _checkersGame!.moveHistory.length; i += 2) {
      moves.add({
        'number': '${(i ~/ 2) + 1}',
        'white': _checkersGame!.moveHistory[i],
        'black': i + 1 < _checkersGame!.moveHistory.length
            ? _checkersGame!.moveHistory[i + 1]
            : '',
      });
    }

    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: moves.length,
      itemBuilder: (context, index) {
        final move = moves[index];
        final isLastMove = index == moves.length - 1;
        final hasBlack = move['black']!.isNotEmpty;

        // Вычисляем индексы ходов (белые = index*2, черные = index*2+1)
        final whiteIndex = index * 2;
        final blackIndex = index * 2 + 1;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isLastMove && _viewingMoveIndex == null
                ? Colors.amber.shade700.withOpacity(0.2)
                : (index % 2 == 0
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              // Номер хода
              SizedBox(
                width: 25,
                child: Text(
                  '${move['number']}.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Ход белых (кликабельный)
              Expanded(
                child: GestureDetector(
                  onTap: () => _goToMove(whiteIndex),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    decoration: _viewingMoveIndex == whiteIndex
                        ? BoxDecoration(
                            color: Colors.blue.shade700.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(3),
                          )
                        : null,
                    child: Text(
                      move['white']!,
                      style: TextStyle(
                        color: _viewingMoveIndex == whiteIndex
                            ? Colors.white
                            : (isLastMove &&
                                      !hasBlack &&
                                      _viewingMoveIndex == null
                                  ? Colors.amber.shade400
                                  : Colors.white),
                        fontSize: 11,
                        fontWeight: _viewingMoveIndex == whiteIndex
                            ? FontWeight.bold
                            : (isLastMove &&
                                      !hasBlack &&
                                      _viewingMoveIndex == null
                                  ? FontWeight.bold
                                  : FontWeight.w500),
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Ход черных (кликабельный)
              Expanded(
                child: hasBlack
                    ? GestureDetector(
                        onTap: () => _goToMove(blackIndex),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 3,
                          ),
                          decoration: _viewingMoveIndex == blackIndex
                              ? BoxDecoration(
                                  color: Colors.blue.shade700.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                )
                              : null,
                          child: Text(
                            move['black']!,
                            style: TextStyle(
                              color: _viewingMoveIndex == blackIndex
                                  ? Colors.white
                                  : (isLastMove && _viewingMoveIndex == null
                                        ? Colors.amber.shade400
                                        : Colors.white),
                              fontSize: 11,
                              fontWeight: _viewingMoveIndex == blackIndex
                                  ? FontWeight.bold
                                  : (isLastMove && _viewingMoveIndex == null
                                        ? FontWeight.bold
                                        : FontWeight.w500),
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Создает таблицу истории ходов для шахмат
  Widget _buildChessMoveHistoryTable(ScrollController controller) {
    if (_chessGame == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            AppLocalizations.get('noTimer').contains('No')
                ? 'No moves yet'
                : 'Ходов пока нет',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      );
    }

    // Получаем PGN и парсим ходы
    final pgn = _chessGame!.game.pgn();

    if (pgn.isEmpty || !pgn.contains('.')) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            AppLocalizations.get('noTimer').contains('No')
                ? 'No moves yet'
                : 'Ходов пока нет',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      );
    }

    // Парсим PGN для извлечения ходов
    List<Map<String, String>> moves = [];
    final lines = pgn.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty && !line.startsWith('[')) {
        // Парсим строку формата "1. e4 e5 2. Nf3 Nc6"
        final tokens = line.split(RegExp(r'\s+'));
        String? currentMoveNumber;
        String? whiteMove;

        for (var token in tokens) {
          if (token.contains('.')) {
            // Это номер хода
            if (whiteMove != null && currentMoveNumber != null) {
              moves.add({
                'number': currentMoveNumber,
                'white': whiteMove,
                'black': '',
              });
            }
            currentMoveNumber = token.replaceAll('.', '');
            whiteMove = null;
          } else if (token.isNotEmpty) {
            // Это ход
            if (whiteMove == null) {
              whiteMove = token;
            } else {
              moves.add({
                'number': currentMoveNumber!,
                'white': whiteMove,
                'black': token,
              });
              whiteMove = null;
              currentMoveNumber = null;
            }
          }
        }

        // Добавляем последний ход, если есть
        if (whiteMove != null && currentMoveNumber != null) {
          moves.add({
            'number': currentMoveNumber,
            'white': whiteMove,
            'black': '',
          });
        }
      }
    }

    if (moves.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            AppLocalizations.get('noTimer').contains('No')
                ? 'No moves yet'
                : 'Ходов пока нет',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: moves.length,
      itemBuilder: (context, index) {
        final move = moves[index];
        final isLastMove = index == moves.length - 1;

        // Вычисляем индексы ходов (белые = index*2, черные = index*2+1)
        final whiteIndex = index * 2;
        final blackIndex = index * 2 + 1;
        final hasBlack = move['black']!.isNotEmpty;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isLastMove && _viewingMoveIndex == null
                ? Colors.amber.shade700.withOpacity(0.2)
                : (index % 2 == 0
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              // Номер хода
              SizedBox(
                width: 25,
                child: Text(
                  '${move['number']}.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Ход белых (кликабельный)
              Expanded(
                child: GestureDetector(
                  onTap: () => _goToMove(whiteIndex),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    decoration: _viewingMoveIndex == whiteIndex
                        ? BoxDecoration(
                            color: Colors.blue.shade700.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(3),
                          )
                        : null,
                    child: Text(
                      move['white'] ?? '',
                      style: TextStyle(
                        color: _viewingMoveIndex == whiteIndex
                            ? Colors.white
                            : (isLastMove &&
                                      !hasBlack &&
                                      _viewingMoveIndex == null
                                  ? Colors.amber.shade400
                                  : Colors.white),
                        fontSize: 11,
                        fontWeight: _viewingMoveIndex == whiteIndex
                            ? FontWeight.bold
                            : (isLastMove &&
                                      !hasBlack &&
                                      _viewingMoveIndex == null
                                  ? FontWeight.bold
                                  : FontWeight.w500),
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Ход черных (кликабельный)
              Expanded(
                child: hasBlack
                    ? GestureDetector(
                        onTap: () => _goToMove(blackIndex),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 3,
                          ),
                          decoration: _viewingMoveIndex == blackIndex
                              ? BoxDecoration(
                                  color: Colors.blue.shade700.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                )
                              : null,
                          child: Text(
                            move['black'] ?? '',
                            style: TextStyle(
                              color: _viewingMoveIndex == blackIndex
                                  ? Colors.white
                                  : (isLastMove && _viewingMoveIndex == null
                                        ? Colors.amber.shade400
                                        : Colors.white),
                              fontSize: 11,
                              fontWeight: _viewingMoveIndex == blackIndex
                                  ? FontWeight.bold
                                  : (isLastMove && _viewingMoveIndex == null
                                        ? FontWeight.bold
                                        : FontWeight.w500),
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Строит виджет нужной игры
  Widget _buildGameWidget() {
    switch (widget.gameKey) {
      case 'checkers':
        // Используем историческую игру при просмотре истории
        final gameToDisplay = _historicalCheckersGame ?? _checkersGame!;
        final isViewingHistory = _viewingMoveIndex != null;

        return CheckersBoardWidget(
          key: _boardKey,
          game: gameToDisplay,
          gameMode: isViewingHistory
              ? GameMode.pvp
              : widget.mode, // Отключаем AI при просмотре истории
          aiDifficulty: widget.difficulty,
          playerPlaysWhite: widget.mode == GameMode.pve
              ? _playerPlaysWhiteInCheckers
              : true,
          onGameEnd: _onGameEnd,
          onMove: isViewingHistory
              ? () {}
              : () => setState(
                  _handleGameEnd,
                ), // Отключаем ходы при просмотре истории
          isReadOnly: isViewingHistory, // Передаем флаг только для чтения
        );
      case 'togyz':
        return TogyzKumalakBoardWidget(
          key: _boardKey,
          game: _togyzGame!,
          gameMode: widget.mode,
          aiDifficulty: widget.difficulty,
          onGameEnd: _onGameEnd,
          onMove: () => setState(_handleGameEnd),
        );
      case 'chess':
        // Используем историческую игру при просмотре истории
        final gameToDisplay = _historicalChessGame ?? _chessGame!;
        final isViewingHistory = _viewingMoveIndex != null;

        return ChessBoardWidget(
          key: _boardKey,
          game: gameToDisplay,
          gameMode: isViewingHistory
              ? GameMode.pvp
              : widget.mode, // Отключаем AI при просмотре истории
          aiDifficulty: widget.difficulty,
          playerColor: widget.chessPlayerColor ?? chess.Color.WHITE,
          onGameEnd: _onGameEnd,
          onMove: isViewingHistory
              ? () {}
              : () => setState(
                  _handleGameEnd,
                ), // Отключаем ходы при просмотре истории
          isReadOnly: isViewingHistory, // Передаем флаг только для чтения
        );
      case 'backgammon':
        return BackgammonBoardWidget(
          key: _boardKey,
          game: _backgammonGame!,
          gameMode: widget.mode,
          aiDifficulty: widget.difficulty,
          onGameEnd: _onGameEnd,
          onMove: () => setState(_handleGameEnd),
        );
      default:
        return Text(
          AppLocalizations.get('rulesNotFound'),
          style: const TextStyle(fontSize: 24),
        );
    }
  }
}
