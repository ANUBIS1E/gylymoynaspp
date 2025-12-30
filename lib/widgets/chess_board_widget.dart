import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// УДАЛЕНО: import 'package:flutter_svg/flutter_svg.dart';
import '../games/chess_ai.dart'; // Резервный быстрый ИИ
import '../games/chess_ai_stockfish_new.dart'; // Профессиональный Stockfish ІІ
import '../games/chess_logic.dart' as chess_logic;
import 'package:chess/chess.dart' as chess;
import '../screens/game_setup_screen.dart';
import '../utils/hint_system.dart'; // Система подсказок

class ChessBoardWidget extends StatefulWidget {
  final chess_logic.ChessGameLogic game;
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;
  final chess.Color playerColor;
  final Function(Color) onGameEnd;
  final VoidCallback onMove;
  final bool isReadOnly; // Режим только для чтения (для просмотра истории)

  const ChessBoardWidget({
    Key? key,
    required this.game,
    required this.gameMode,
    this.aiDifficulty,
    required this.playerColor,
    required this.onGameEnd,
    required this.onMove,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  _ChessBoardWidgetState createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget>
    with SingleTickerProviderStateMixin {
  ChessAIStockfishNew? _stockfishAI;
  ChessAI? _fallbackAI;
  bool _useStockfish = true;
  String? _selectedSquare;
  List<String> _possibleMoves = [];

  // Hint system variables
  bool _isLoadingHint = false;
  String? _currentHintText;
  String? _hintMoveFrom;
  String? _hintMoveTo;

  // Animation variables
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  String? _animatingFrom;
  String? _animatingTo;
  chess.Piece? _animatingPiece;
  bool _isAnimating = false;

  String _squareFromDisplayIndex(int index) {
    final displayRow = index ~/ 8;
    final displayCol = index % 8;
    final boardRow = widget.playerColor == chess.Color.WHITE
        ? 7 - displayRow
        : displayRow;
    final boardCol = widget.playerColor == chess.Color.WHITE
        ? displayCol
        : 7 - displayCol;
    return '${String.fromCharCode(97 + boardCol)}${boardRow + 1}';
  }

  int _displayRowFromSquare(String squareName) {
    final boardRow = int.parse(squareName[1]) - 1;
    return widget.playerColor == chess.Color.WHITE ? 7 - boardRow : boardRow;
  }

  int _displayColFromSquare(String squareName) {
    final boardCol = squareName.codeUnitAt(0) - 97;
    return widget.playerColor == chess.Color.WHITE ? boardCol : 7 - boardCol;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.gameMode == GameMode.pve) {
      _initializeAI().then((_) {
        // AI инициализирован, можем запускать первый ход если нужно
        if (mounted &&
            widget.playerColor == chess.Color.BLACK &&
            widget.game.game.turn == chess.Color.WHITE) {
          _triggerAiMove();
        }
      });
    }
  }

  Future<void> _initializeAI() async {
    // Используем только простой рандомный AI (Stockfish отключен по запросу)
    _fallbackAI = ChessAI();
    _stockfishAI = null;
    if (mounted) {
      setState(() {
        _useStockfish = false;
      });
    }
    print('✓ Простой рандомный AI инициализирован (Stockfish отключен)');
  }

  @override
  void dispose() {
    _stockfishAI?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ЕДИНООБРАЗНЫЕ UNICODE СИМВОЛЫ - ОДИН СТИЛЬ ДЛЯ ВСЕХ
  String _getPieceUnicode(chess.Piece piece) {
    // Используем контурный (outlined) стиль для всех фигур
    switch (piece.type) {
      case chess.PieceType.PAWN:
        return '♙';
      case chess.PieceType.ROOK:
        return '♖';
      case chess.PieceType.KNIGHT:
        return '♘';
      case chess.PieceType.BISHOP:
        return '♗';
      case chess.PieceType.QUEEN:
        return '♕';
      case chess.PieceType.KING:
        return '♔';
      default:
        return '';
    }
  }

  // Calculate offset between two squares for animation
  Offset _calculateOffset(String from, String to) {
    final fromRow = _displayRowFromSquare(from);
    final fromCol = _displayColFromSquare(from);
    final toRow = _displayRowFromSquare(to);
    final toCol = _displayColFromSquare(to);

    double dx = (toCol - fromCol).toDouble();
    double dy = (toRow - fromRow).toDouble();

    return Offset(dx, dy);
  }

  // Animate piece movement
  Future<void> _animateMove(String from, String to) async {
    final piece = widget.game.game.get(from);
    if (piece == null) return;

    setState(() {
      _isAnimating = true;
      _animatingFrom = from;
      _animatingTo = to;
      _animatingPiece = piece;
    });

    final offset = _calculateOffset(from, to);
    _animation = Tween<Offset>(begin: Offset.zero, end: offset).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.reset();
    await _animationController.forward();

    setState(() {
      _isAnimating = false;
      _animatingFrom = null;
      _animatingTo = null;
      _animatingPiece = null;
    });
  }

  void _onSquareTap(String squareName) async {
    if (widget.isReadOnly) return; // Блокируем ходы в режиме просмотра истории
    if (widget.gameMode == GameMode.pve &&
        widget.game.game.turn != widget.playerColor)
      return;
    if (_isAnimating) return; // Don't allow moves during animation

    if (_selectedSquare == null) {
      var piece = widget.game.game.get(squareName);
      if (piece != null && piece.color == widget.game.game.turn) {
        setState(() {
          _selectedSquare = squareName;
          _possibleMoves = widget.game.game
              .moves({'square': squareName, 'verbose': true})
              .map((move) => move['to'] as String)
              .toList();
        });
      }
    } else {
      // Check if move is valid before animating
      final from = _selectedSquare!;
      final to = squareName;

      // Try the move on a temporary copy to validate
      bool isValidMove = widget.game.game
          .moves({'square': from, 'verbose': true})
          .any((move) => move['to'] == to);

      if (isValidMove) {
        // Animate then execute move
        await _animateMove(from, to);

        setState(() {
          widget.game.makeMove(from, to);
          _possibleMoves.clear();
          _selectedSquare = null;
        });

        widget.onMove();
        _checkEndGame();

        if (widget.gameMode == GameMode.pve &&
            widget.game.game.turn != widget.playerColor) {
          _triggerAiMove();
        }
      } else {
        // Invalid move - check if selecting a new piece
        var piece = widget.game.game.get(squareName);
        setState(() {
          if (piece != null && piece.color == widget.game.game.turn) {
            _selectedSquare = squareName;
            _possibleMoves = widget.game.game
                .moves({'square': squareName, 'verbose': true})
                .map((move) => move['to'] as String)
                .toList();
          } else {
            _selectedSquare = null;
            _possibleMoves.clear();
          }
        });
      }
    }
  }

  void _triggerAiMove() async {
    // Добавляем небольшую задержку, чтобы UI успел обновиться
    await Future.delayed(Duration(milliseconds: 100));

    if (!mounted || widget.game.game.game_over) return;

    // Проверяем что есть доступные ходы
    final availableMoves = widget.game.game.moves();
    if (availableMoves.isEmpty) return;

    // Используем Stockfish если доступен, иначе резервный AI
    String? aiMoveSAN;
    if (_useStockfish && _stockfishAI != null) {
      try {
        aiMoveSAN = await _stockfishAI!.findBestMove(widget.game, _getAiDifficulty()).timeout(
          Duration(seconds: 5),
          onTimeout: () => null,
        );
      } catch (e) {
        print('⚠ Stockfish ошибка в AI ходе: $e');
        aiMoveSAN = null;
      }
    }

    // Fallback на резервный AI если Stockfish не сработал
    if (aiMoveSAN == null && _fallbackAI != null) {
      aiMoveSAN = _fallbackAI!.findBestMove(widget.game, _getAiDifficulty());
    }

    if (aiMoveSAN == null) return;

    // Присваиваем локальную переменную для type promotion
    final String moveToMake = aiMoveSAN;

    if (!mounted || widget.game.game.game_over) return;

    // Get move details for animation
    final moves = widget.game.game.moves({'verbose': true});
    final moveDetails = moves.firstWhere(
      (m) => m['san'] == moveToMake,
      orElse: () => <String, dynamic>{},
    );

    if (moveDetails.isNotEmpty) {
      final from = moveDetails['from'] as String;
      final to = moveDetails['to'] as String;

      // Animate the AI move
      await _animateMove(from, to);
    }

    setState(() {
      widget.game.makeMoveSAN(moveToMake);
      widget.onMove();
      _checkEndGame();
    });
  }

  void _checkEndGame() {
    final winner = widget.game.winner;
    if (winner != null) {
      widget.onGameEnd(winner);
    }
  }

  // Метод для запроса подсказки от AI
  Future<void> _requestHint() async {
    if (_isLoadingHint || !HintSystem.isTrainingModeEnabled()) return;

    setState(() {
      _isLoadingHint = true;
      _currentHintText = null;
      _hintMoveFrom = null;
      _hintMoveTo = null;
    });

    try {
      // Проверяем что есть доступные ходы
      final availableMoves = widget.game.game.moves();
      if (availableMoves.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Нет доступных ходов')),
          );
        }
        return;
      }

      String? bestMove;

      // Используем Stockfish если доступен, иначе резервный AI
      if (_useStockfish && _stockfishAI != null) {
        try {
          bestMove = await _stockfishAI!.findBestMove(widget.game, _getAiDifficulty()).timeout(
            Duration(seconds: 5),
            onTimeout: () {
              print('⚠ Stockfish timeout, используем резервный AI');
              return null;
            },
          );
        } catch (e) {
          print('⚠ Stockfish ошибка: $e, используем резервный AI');
          bestMove = null;
        }
      }

      // Fallback на резервный AI если Stockfish не сработал
      if (bestMove == null && _fallbackAI != null) {
        bestMove = _fallbackAI!.findBestMove(widget.game, _getAiDifficulty());
      }

      if (bestMove != null && mounted) {
        // Анализируем ход для объяснения
        final moves = widget.game.game.moves({'verbose': true});
        final moveDetails = moves.firstWhere(
          (m) => m['san'] == bestMove,
          orElse: () => <String, dynamic>{},
        );

        String explanation = 'Этот ход улучшает вашу позицию';

        if (moveDetails.isNotEmpty) {
          _hintMoveFrom = moveDetails['from'] as String?;
          _hintMoveTo = moveDetails['to'] as String?;

          // Анализ хода
          if (moveDetails['captured'] != null) {
            final capturedPiece = moveDetails['captured'] as String;
            explanation = 'Этот ход захватывает ${_getPieceNameRu(capturedPiece)} противника';
          } else if (widget.game.game.in_check) {
            explanation = 'Этот ход дает шах королю противника';
          } else if (moveDetails['promotion'] != null) {
            explanation = 'Этот ход превращает пешку в фигуру';
          }

          setState(() {
            _currentHintText = explanation;
          });

          HintSystem.showHint(
            context,
            title: 'Рекомендация AI',
            explanation: explanation,
            moveSuggestion: HintSystem.formatChessMove(bestMove),
            onApplyHint: () async {
              // Анимируем ход
              final from = moveDetails['from'] as String;
              final to = moveDetails['to'] as String;
              await _animateMove(from, to);

              // Делаем ход
              widget.game.makeMoveSAN(bestMove!);
              widget.onMove();

              setState(() {
                _hintMoveFrom = null;
                _hintMoveTo = null;
                _currentHintText = null;
              });

              // Проверяем конец игры
              _checkEndGame();

              // ВАЖНО: Если режим PvE, запускаем ход AI
              if (widget.gameMode == GameMode.pve && !widget.game.game.game_over) {
                _triggerAiMove();
              }
            },
          );
        }
      }
    } catch (e) {
      print('Ошибка получения подсказки: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingHint = false);
      }
    }
  }

  // Получить название фигуры на русском
  String _getPieceNameRu(String pieceType) {
    switch (pieceType.toLowerCase()) {
      case 'p': return 'пешку';
      case 'n': return 'коня';
      case 'b': return 'слона';
      case 'r': return 'ладью';
      case 'q': return 'ферзя';
      default: return 'фигуру';
    }
  }

  bool _isPlayerTurn() {
    if (widget.gameMode == GameMode.pvp) return true;
    return widget.game.game.turn == widget.playerColor;
  }

  int _getAiDifficulty() {
    switch (widget.aiDifficulty) {
      case AiDifficulty.level1: return 1;
      case AiDifficulty.level2: return 2;
      case AiDifficulty.level3: return 3;
      case AiDifficulty.level4: return 4;
      case AiDifficulty.level5: return 5;
      case AiDifficulty.level6: return 6;
      case AiDifficulty.level7: return 7;
      case AiDifficulty.level8: return 8;
      case AiDifficulty.level9: return 9;
      case AiDifficulty.level10: return 10;
      default:
        return 5; // Средний уровень по умолчанию
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = min(screenWidth * 0.9, 600.0);
    final squareSize = boardSize / 8;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        // Реалистичная рамка из темного дерева
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4E37), Color(0xFF6B5D47), Color(0xFF5D4E37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(6), // Рамка вокруг доски
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3D2E1F), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // The board grid
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                String squareName = _squareFromDisplayIndex(index);
                var piece = widget.game.game.get(squareName);
                int boardRow = int.parse(squareName[1]) - 1;
                int boardCol = squareName.codeUnitAt(0) - 97;

                // Реалистичные деревянные текстуры
                bool isLightSquare = (boardRow + boardCol) % 2 == 0;
                List<Color> squareGradient = isLightSquare
                    ? [
                        const Color(0xFFF0D9B5),
                        const Color(0xFFEECEA0),
                        const Color(0xFFE8C297),
                      ] // Светлое дерево (клен)
                    : [
                        const Color(0xFFB58863),
                        const Color(0xFFA67C52),
                        const Color(0xFF987456),
                      ]; // Темное дерево (орех)

                bool isPossibleMove = _possibleMoves.contains(squareName);

                // Hide piece if it's currently animating from this square
                bool hidePiece = _isAnimating && squareName == _animatingFrom;

                return GestureDetector(
                  onTap: () => _onSquareTap(squareName),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: squareGradient,
                      ),
                      // Тонкие границы для эффекта отдельных клеток
                      border: Border.all(
                        color: isLightSquare
                            ? const Color(0xFFD7BE9E).withOpacity(0.3)
                            : const Color(0xFF8B6F47).withOpacity(0.3),
                        width: 0.5,
                      ),
                      // Тени для объема
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Тонкая текстура дерева (имитация волокон)
                        if (isLightSquare)
                          Opacity(
                            opacity: 0.05,
                            child: CustomPaint(
                              size: Size(squareSize, squareSize),
                              painter: _WoodGrainPainter(isLight: true),
                            ),
                          ),

                        if (_selectedSquare == squareName)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.35),
                              border: Border.all(
                                color: Colors.yellow.shade700,
                                width: 2,
                              ),
                            ),
                          ),

                        // ЕДИНООБРАЗНЫЙ РЕАЛИСТИЧНЫЙ СТИЛЬ ДЛЯ ВСЕХ ФИГУР
                        if (piece != null && !hidePiece)
                          Text(
                            _getPieceUnicode(piece),
                            style: TextStyle(
                              fontSize: boardSize / 9.2,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                              color: piece.color == chess.Color.WHITE
                                  ? const Color(
                                      0xFFFBFBFB,
                                    ) // Белые фигуры - светлые
                                  : const Color(
                                      0xFF1C1C1C,
                                    ), // Черные фигуры - темные
                              // Единообразные тени для всех фигур
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                                Shadow(
                                  color: Color(0x99000000),
                                  blurRadius: 6,
                                  offset: Offset(1.5, 1.5),
                                ),
                                Shadow(
                                  color: Color(0x55000000),
                                  blurRadius: 3,
                                  offset: Offset(0.5, 0.5),
                                ),
                                Shadow(
                                  color: Color(0x22000000),
                                  blurRadius: 1,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),

                        if (isPossibleMove)
                          Container(
                            width: boardSize / 8 * 0.32,
                            height: boardSize / 8 * 0.32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.shade700.withOpacity(0.4),
                              border: Border.all(
                                color: Colors.green.shade900.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Animated piece overlay
            if (_isAnimating &&
                _animatingPiece != null &&
                _animatingFrom != null)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Calculate starting position
                  int fromRow = _displayRowFromSquare(_animatingFrom!);
                  int fromCol = _displayColFromSquare(_animatingFrom!);

                  final double startX = fromCol * squareSize;
                  final double startY = fromRow * squareSize;

                  return Positioned(
                    left: startX + (_animation.value.dx * squareSize),
                    top: startY + (_animation.value.dy * squareSize),
                    width: squareSize,
                    height: squareSize,
                    child: Center(
                      child: Text(
                        _getPieceUnicode(_animatingPiece!),
                        style: TextStyle(
                          fontSize: boardSize / 9.2,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: _animatingPiece!.color == chess.Color.WHITE
                              ? const Color(0xFFFBFBFB)
                              : const Color(0xFF1C1C1C),
                          // Единообразные тени для всех фигур
                          shadows: const [
                            Shadow(
                              color: Color(0xFF000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 6,
                              offset: Offset(1.5, 1.5),
                            ),
                            Shadow(
                              color: Color(0x55000000),
                              blurRadius: 3,
                              offset: Offset(0.5, 0.5),
                            ),
                            Shadow(
                              color: Color(0x22000000),
                              blurRadius: 1,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Кнопка подсказки (только в режиме обучения и для хода игрока)
            if (HintSystem.isTrainingModeEnabled() && !widget.isReadOnly && _isPlayerTurn())
              Positioned(
                bottom: 10,
                right: 10,
                child: HintSystem.buildHintButton(
                  onPressed: _requestHint,
                  isLoading: _isLoadingHint,
                ),
              ),

            // Панель с текущей подсказкой
            if (HintSystem.isTrainingModeEnabled() && _currentHintText != null)
              Positioned(
                bottom: 70,
                left: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentHintText!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _currentHintText = null),
                        color: Colors.black54,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ), // Stack
      ), // Inner Container
    ); // Outer Container
  }
}

// Custom painter для имитации текстуры дерева
class _WoodGrainPainter extends CustomPainter {
  final bool isLight;

  _WoodGrainPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLight
          ? const Color(0xFFD4A76A).withAlpha(30)
          : const Color(0xFF8B6F47).withAlpha(40)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Рисуем тонкие линии для имитации волокон дерева
    for (double i = 0; i < size.width; i += 4) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_WoodGrainPainter oldDelegate) => false;
}
