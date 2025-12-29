import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../games/togyz_kumalak_ai.dart';
import '../games/togyz_kumalak_logic.dart' as togyz;
import '../screens/game_setup_screen.dart';
import '../utils/hint_system.dart';

class TogyzKumalakBoardWidget extends StatefulWidget {
  final togyz.TogyzKumalakLogic game;
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;
  final Function(Color)? onGameEnd;
  final VoidCallback? onMove;

  const TogyzKumalakBoardWidget({
    Key? key,
    required this.game,
    required this.gameMode,
    this.aiDifficulty,
    this.onGameEnd,
    this.onMove,
  }) : super(key: key);

  @override
  _TogyzKumalakBoardWidgetState createState() =>
      _TogyzKumalakBoardWidgetState();
}

class _TogyzKumalakBoardWidgetState extends State<TogyzKumalakBoardWidget>
    with SingleTickerProviderStateMixin {
  static const int _maxVisibleKumalaks = 24;
  late final TogyzKumalakAI _ai;
  bool _isAiThinking = false;

  late AnimationController _animationController;
  List<int> _animatingPits = [];
  bool _isAnimating = false;

  // Hint system variables
  bool _isLoadingHint = false;
  String? _currentHintText;
  int? _hintPitIndex;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    if (widget.gameMode == GameMode.pve) {
      _ai = TogyzKumalakAI();
      if (!widget.game.isWhiteTurn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              !widget.game.isWhiteTurn &&
              widget.game.winner == null) {
            _triggerAiMove();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _animateMove(int pitIndex) async {
    setState(() {
      _isAnimating = true;
      _animatingPits = [pitIndex];
    });

    await _animationController.forward();
    _animationController.reset();

    int kumalaks = widget.game.otaus[pitIndex];
    if (kumalaks <= 1) {
      setState(() {
        _isAnimating = false;
        _animatingPits = [];
      });
      return;
    }

    List<int> targetPits = [];
    int currentIndex = (pitIndex + 1) % 18;
    int stonesLeft = kumalaks - 1;

    while (stonesLeft > 0) {
      targetPits.add(currentIndex);
      currentIndex = (currentIndex + 1) % 18;
      stonesLeft--;
    }

    for (int target in targetPits) {
      setState(() {
        _animatingPits = [target];
      });
      await Future.delayed(const Duration(milliseconds: 150));
    }

    setState(() {
      _isAnimating = false;
      _animatingPits = [];
    });
  }

  void _handleTap(int index) async {
    if (_isAiThinking || widget.game.winner != null || _isAnimating) return;
    if (widget.gameMode == GameMode.pve && !widget.game.isWhiteTurn) return;

    if (widget.game.otaus[index] == 0) return;
    if (widget.game.isWhiteTurn && index >= 9) return;
    if (!widget.game.isWhiteTurn && index < 9) return;
    if (widget.game.isWhiteTurn && index == widget.game.blackTuzdyk) return;
    if (!widget.game.isWhiteTurn && index == widget.game.whiteTuzdyk) return;

    await _animateMove(index);

    bool turnWillChange = false;

    setState(() {
      bool turnBeforeMove = widget.game.isWhiteTurn;
      bool moveMade = widget.game.makeMove(index);

      if (moveMade) {
        widget.onMove?.call();
        if (widget.game.winner != null && widget.onGameEnd != null) {
          widget.onGameEnd!(widget.game.winner!);
          return;
        }
        if (widget.game.isWhiteTurn != turnBeforeMove) {
          turnWillChange = true;
        } else if (!widget.game.canMakeAnyMove()) {
          print("Togyz Atsyrau detected. Forcing turn change.");
          widget.game.isWhiteTurn = !widget.game.isWhiteTurn;
          widget.game.checkEndGameConditions();
          if (widget.game.winner != null && widget.onGameEnd != null) {
            widget.onGameEnd!(widget.game.winner!);
            return;
          }
          turnWillChange = true;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.game.winner != null) return;
      if (turnWillChange) {
        if (widget.gameMode == GameMode.pve && !widget.game.isWhiteTurn) {
          _triggerAiMove();
        }
      }
    });
  }

  void _triggerAiMove() async {
    if (!mounted ||
        widget.game.winner != null ||
        widget.game.isWhiteTurn ||
        _isAiThinking)
      return;

    if (!widget.game.canMakeAnyMove()) {
      setState(() {
        widget.game.isWhiteTurn = true;
        widget.game.checkEndGameConditions();
      });
      if (widget.game.winner != null && widget.onGameEnd != null) {
        widget.onGameEnd!(widget.game.winner!);
      }
      return;
    }

    setState(() {
      _isAiThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted ||
        widget.game.winner != null ||
        widget.game.isWhiteTurn ||
        !_isAiThinking) {
      if (mounted && _isAiThinking) {
        setState(() {
          _isAiThinking = false;
        });
      }
      return;
    }

    int bestMove = _ai.findBestMove(widget.game, _getAiDifficulty());

    bool isValidAITurn = !widget.game.isWhiteTurn;
    bool isValidPitIndex = bestMove >= 9 && bestMove < 18;
    bool isPitNotEmpty = isValidPitIndex && widget.game.otaus[bestMove] > 0;
    bool isNotOpponentTuzdykSource = bestMove != widget.game.whiteTuzdyk;

    if (isValidAITurn && isPitNotEmpty && isNotOpponentTuzdykSource) {
      await _animateMove(bestMove);

      bool turnBeforeAIMove = widget.game.isWhiteTurn;

      setState(() {
        widget.game.makeMove(bestMove);
        widget.onMove?.call();
      });

      if (widget.game.winner != null && widget.onGameEnd != null) {
        widget.onGameEnd!(widget.game.winner!);
        if (mounted) {
          setState(() {
            _isAiThinking = false;
          });
        }
        return;
      }

      if (widget.game.isWhiteTurn != turnBeforeAIMove) {
        if (mounted) {
          setState(() {
            _isAiThinking = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            widget.game.isWhiteTurn = true;
            _isAiThinking = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          widget.game.isWhiteTurn = true;
          _isAiThinking = false;
        });
      }
    }
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

  bool _isPlayerTurn() {
    if (widget.gameMode == GameMode.pvp) return true;
    // В режиме PvE игрок всегда играет за белых (верхняя сторона)
    return widget.game.isWhiteTurn;
  }

  Future<void> _requestHint() async {
    if (_isLoadingHint || !HintSystem.isTrainingModeEnabled()) return;
    if (_isAiThinking || _isAnimating) return;

    setState(() {
      _isLoadingHint = true;
      _currentHintText = null;
      _hintPitIndex = null;
    });

    try {
      final playerColor = widget.game.isWhiteTurn ? Colors.white : Colors.black;

      // Используем тот же AI что и для PvE режима
      final ai = widget.gameMode == GameMode.pve ? _ai : TogyzKumalakAI();

      final hint = ai.suggestMoveWithExplanation(
        widget.game,
        3, // depth
        playerColor,
      );

      if (hint != null && mounted) {
        setState(() {
          _hintPitIndex = hint.move;
          _currentHintText = hint.explanation;
        });

        HintSystem.showHint(
          context,
          title: 'Рекомендация AI',
          explanation: hint.explanation,
          moveSuggestion: HintSystem.formatTogyzMove(hint.pitNumber),
          onApplyHint: () async {
            // Анимируем и выполняем ход
            await _animateMove(hint.move);
            setState(() {
              widget.game.makeMove(hint.move);
              widget.onMove?.call();
              _hintPitIndex = null;
            });

            // Проверяем победу
            if (widget.game.winner != null && widget.onGameEnd != null) {
              widget.onGameEnd!(widget.game.winner!);
            }

            // ВАЖНО: Если режим PvE и игра не закончена, запускаем ход AI
            if (widget.gameMode == GameMode.pve && widget.game.winner == null) {
              _triggerAiMove();
            }
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingHint = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;
        double boardWidth = min(constraints.maxWidth, 900.0);
        if (boardWidth <= 0) {
          boardWidth = min(screenSize.width, 420.0);
        }
        final double boardHeight = boardWidth / 1.5; // ОГРОМНАЯ высота доски - увеличили для 4 рядов кумалаков

        return Center(
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: _isAiThinking,
                child: Container(
              width: boardWidth,
              height: boardHeight,
              decoration: BoxDecoration(
                // Реалистичная деревянная рамка в едином стиле с нардами и шахматами
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5D4E37), // Темный орех
                    Color(0xFF6B5D47),
                    Color(0xFF7A6A4F),
                    Color(0xFF6B5D47),
                    Color(0xFF5D4E37),
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3D2E1F), width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(boardWidth * 0.04), // Немного уменьшили темную рамку
              child: Container(
                decoration: BoxDecoration(
                  // Внутреннее игровое поле - более светлое
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B7355),
                      Color(0xFF9A8166),
                      Color(0xFFA68F77),
                      Color(0xFF9A8166),
                      Color(0xFF8B7355),
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF5D4E37),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(boardWidth * 0.04), // Увеличили светло-коричневую зону
                child: Column(
                  children: [
                    _buildNumberRow(List.generate(9, (i) => 9 - i), boardWidth, upsideDown: true),
                    SizedBox(height: boardHeight * 0.01),
                    Expanded(
                      flex: 5, // Ещё больше увеличили высоту лунок
                      child: _buildPitRow(
                        List.generate(9, (i) => 17 - i),
                        boardWidth,
                        upsideDown: true,
                      ),
                    ),
                    SizedBox(height: boardHeight * 0.02),
                    Expanded(flex: 3, child: _buildKazansRow(boardWidth)), // Увеличили высоту казанов
                    SizedBox(height: boardHeight * 0.02),
                    Expanded(
                      flex: 5, // Ещё больше увеличили высоту лунок
                      child: _buildPitRow(
                        List.generate(9, (i) => i),
                        boardWidth,
                      ),
                    ),
                    SizedBox(height: boardHeight * 0.01),
                    _buildNumberRow(List.generate(9, (i) => i + 1), boardWidth),
                  ],
                ),
              ),
            ),
          ),

          // Hint button (only in training mode and player's turn)
          if (HintSystem.isTrainingModeEnabled() && _isPlayerTurn())
            Positioned(
              bottom: 10,
              right: 10,
              child: HintSystem.buildHintButton(
                onPressed: _requestHint,
                isLoading: _isLoadingHint,
              ),
            ),

          // Hint panel
          if (HintSystem.isTrainingModeEnabled() && _currentHintText != null)
            Positioned(
              bottom: 70,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentHintText!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _currentHintText = null),
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }

  // Ряд с номерами лунок
  Widget _buildNumberRow(List<int> numbers, double boardWidth, {bool upsideDown = false}) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Center(
            child: Transform.rotate(
              angle: upsideDown ? 3.14159 : 0, // π радиан = 180 градусов
              child: Text(
                '$number',
                style: TextStyle(
                  // Темный цвет для контраста на светлом фоне
                  color: Color(0xFF3D2E1F),
                  fontSize: boardWidth * 0.028, // ЕЩЁ БОЛЬШЕ увеличили размер
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.white.withAlpha(100),
                      blurRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Ряд лунок
  Widget _buildPitRow(List<int> indices, double boardWidth, {bool upsideDown = false}) {
    return Row(
      children: indices.map((index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: boardWidth * 0.005),
            child: _buildPit(index, boardWidth, upsideDown: upsideDown),
          ),
        );
      }).toList(),
    );
  }

  // Одна лунка (узкая, вытянутая вертикально - ТОЧНО как на картинке)
  Widget _buildPit(int index, double boardWidth, {bool upsideDown = false}) {
    final pitCount = widget.game.otaus[index];
    final bool isTuzdyk =
        index == widget.game.whiteTuzdyk || index == widget.game.blackTuzdyk;
    final bool isAnimating = _animatingPits.contains(index);
    final bool isHintPit = _hintPitIndex == index;

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          // Темное углубление для лунки
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.5,
            colors: [Color(0xFF4A2F1A), Color(0xFF3A2515), Color(0xFF2A1B10)],
          ),
          borderRadius: BorderRadius.circular(boardWidth * 0.025),
          border: Border.all(
            color: isHintPit
                ? Colors.amber.shade700
                : (isAnimating
                    ? Color(0xFFFFB347)
                    : (isTuzdyk
                        ? Color(0xFFFFD700)
                        : Color(0xFF5A3820))),
            width: isHintPit ? 3 : (isAnimating ? 2.5 : (isTuzdyk ? 2 : 1)),
          ),
          boxShadow: isHintPit
              ? [
                  BoxShadow(
                    color: Colors.amber.withAlpha(150),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(140),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(140),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Кумалаки (черные шарики столбиками)
            Center(child: _buildKumalaksInPit(pitCount, isTuzdyk, boardWidth)),
            // Количество внизу справа лунки (переворачиваем если нужно)
            Positioned(
              bottom: 3,
              right: 3,
              child: Transform.rotate(
                angle: upsideDown ? 3.14159 : 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$pitCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: boardWidth * 0.022, // ЕЩЁ БОЛЬШЕ увеличили размер
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Кумалаки в лунке (БЕЛЫЕ шарики, золотой туздык) - накладываются при >9
  Widget _buildKumalaksInPit(int count, bool isTuzdyk, double boardWidth) {
    if (count == 0) return SizedBox();

    final kumalakSize = boardWidth * 0.0230;

    // До 9 кумалаков - отображаем все в 2 колонки
    if (count <= 9) {
      final leftColumn = <Widget>[];
      final rightColumn = <Widget>[];

      for (int i = 0; i < count; i++) {
        final isGolden = isTuzdyk && i == 0;
        final kumalak = _buildKumalak(kumalakSize, isGolden);

        if (i % 2 == 0) {
          leftColumn.add(kumalak);
        } else {
          rightColumn.add(kumalak);
        }
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(mainAxisSize: MainAxisSize.min, children: leftColumn),
          SizedBox(width: 2),
          Column(mainAxisSize: MainAxisSize.min, children: rightColumn),
        ],
      );
    }

    // От 10 до 20 - показываем базовые 9 + накладываем дополнительные
    if (count <= 20) {
      final stackChildren = <Widget>[];
      final baseCount = 9;
      final overlapOffset = kumalakSize * 0.20;

      // Базовый слой (9 кумалаков)
      for (int i = 0; i < baseCount; i++) {
        final row = i ~/ 2;
        final col = i % 2;
        final isGolden = isTuzdyk && i == 0;

        stackChildren.add(
          Positioned(
            left: col * (kumalakSize + 2),
            top: row * kumalakSize,
            child: _buildKumalak(kumalakSize, isGolden),
          ),
        );
      }

      // Дополнительные кумалаки (до 11 штук)
      final extraCount = min(count - baseCount, 11);
      for (int i = 0; i < extraCount; i++) {
        final row = i ~/ 2;
        final col = i % 2;

        stackChildren.add(
          Positioned(
            left: col * (kumalakSize + 2) + overlapOffset,
            top: row * kumalakSize + overlapOffset,
            child: _buildKumalak(kumalakSize * 0.85, false),
          ),
        );
      }

      return SizedBox(
        width: kumalakSize * 2 + 6,
        height: kumalakSize * 5,
        child: Stack(children: stackChildren),
      );
    }

    // Больше 20 - показываем сетку 3x3 с меньшими кумалаками
    final displayCount = min(count, 30);
    final smallSize = kumalakSize * 0.75;
    final gridChildren = <Widget>[];

    for (int i = 0; i < displayCount; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      final isGolden = isTuzdyk && i == 0;

      gridChildren.add(
        Positioned(
          left: col * (smallSize + 1.5),
          top: row * (smallSize + 1),
          child: _buildKumalak(smallSize, isGolden),
        ),
      );
    }

    return SizedBox(
      width: smallSize * 3 + 3,
      height: kumalakSize * 5,
      child: Stack(children: gridChildren),
    );
  }

  // Один кумалак (БЕЛЫЙ или ЗОЛОТОЙ шарик) - ОЧЕНЬ ОБЪЕМНЫЙ
  Widget _buildKumalak(double size, bool isGolden) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isGolden
              ? Color(0xFF8B6914).withAlpha(180) // Темно-золотой контур
              : Color(0xFF666666).withAlpha(160), // Темно-серый контур
          width: 0.5,
        ),
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.5), // Сдвинули блик сильнее
          radius: 0.7, // Уменьшили радиус для более резкого перехода
          colors: isGolden
              ? [
                  // ЗОЛОТОЙ туздык - ОЧЕНЬ ОБЪЕМНЫЙ
                  Color(0xFFFFFFFF), // Яркий белый блик на золоте
                  Color(0xFFFFEA00),
                  Color(0xFFFFD700),
                  Color(0xFFFFC107),
                  Color(0xFFFFB300),
                  Color(0xFFFF9800),
                  Color(0xFFEF6C00),
                  Color(0xFFD84315),
                  Color(0xFFBF360C), // Темная тень
                ]
              : [
                  // БЕЛЫЕ кумалаки - ОЧЕНЬ ОБЪЕМНЫЕ
                  Color(0xFFFFFFFF), // Очень яркий белый блик
                  Color(0xFFFDFDFD),
                  Color(0xFFF8F8F8),
                  Color(0xFFEEEEEE),
                  Color(0xFFDDDDDD),
                  Color(0xFFC5C5C5),
                  Color(0xFFAAAAAA),
                  Color(0xFF909090),
                  Color(0xFF757575), // Глубокая тень
                ],
          stops: [0.0, 0.1, 0.2, 0.35, 0.5, 0.65, 0.8, 0.9, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(220), // Более темная тень
            blurRadius: 5,
            offset: Offset(2, 2),
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: isGolden
                ? Color(0xFFFFD700).withAlpha(150)
                : Colors.white.withAlpha(120), // Более яркий блик
            blurRadius: 3,
            offset: Offset(-1.5, -1.5),
          ),
        ],
      ),
    );
  }

  // ДВА КАЗАНА ГОРИЗОНТАЛЬНО с визуальными кумалаками
  Widget _buildKazansRow(double boardWidth) {
    return Row(
      children: [
        // Левый казан (черный игрок)
        Expanded(child: _buildKazan(false, boardWidth)),
        SizedBox(width: 8),
        // Правый казан (белый игрок)
        Expanded(child: _buildKazan(true, boardWidth)),
      ],
    );
  }

  // Казан с визуальными кумалаками внутри
  Widget _buildKazan(bool isWhite, double boardWidth) {
    final kazanCount = isWhite
        ? widget.game.whiteKazan
        : widget.game.blackKazan;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF2A1B10),
            Color(0xFF1A1108),
            Color(0xFF0D0805),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(boardWidth * 0.035),
        border: Border.all(color: Color(0xFF6B5437), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(180),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            // Левый казан (черный) - слева, правый казан (белый) - справа
            alignment: isWhite ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: isWhite
                  ? EdgeInsets.only(right: boardWidth * 0.015)
                  : EdgeInsets.only(left: boardWidth * 0.015),
              child: _buildKazanKumalaks(kazanCount, boardWidth, alignRight: isWhite),
            ),
          ),
          // Число кумалаков внизу справа
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700).withAlpha(200), // Золотой фон
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF8B6914),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(180),
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$kazanCount',
                style: TextStyle(
                  color: Color(0xFF2A1B10), // Темно-коричневый текст
                  fontSize: boardWidth * 0.030,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.white.withAlpha(100),
                      blurRadius: 1,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Визуальные кумалаки в казане - МНОГО РЯДОВ
  Widget _buildKazanKumalaks(int count, double boardWidth, {required bool alignRight}) {
    if (count == 0) return SizedBox();

    final kumalakSize = boardWidth * 0.024; // Немного уменьшили размер
    final maxVisiblePerRow = 10; // Максимум 10 кумалаков в ряду
    final maxRows = 4; // Максимум 4 ряда
    final maxVisible = maxVisiblePerRow * maxRows; // 40 кумалаков максимум
    final visible = min(count, maxVisible);

    // Создаем ряды
    final rows = <Widget>[];
    int remainingCount = visible;
    int currentRow = 0;

    while (remainingCount > 0 && currentRow < maxRows) {
      final kumalaksInRow = min(remainingCount, maxVisiblePerRow);

      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: List.generate(kumalaksInRow, (i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.0),
              child: _buildKazanKumalak(kumalakSize),
            );
          }),
        ),
      );

      remainingCount -= kumalaksInRow;
      currentRow++;

      // Добавляем промежуток между рядами
      if (remainingCount > 0 && currentRow < maxRows) {
        rows.add(SizedBox(height: 2.0));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: rows,
    );
  }

  // Объемный кумалак для казана - ОЧЕНЬ ОБЪЕМНЫЙ
  Widget _buildKazanKumalak(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xFF666666).withAlpha(160), // Темно-серый контур
          width: 0.5,
        ),
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.5), // Сдвинули блик сильнее
          radius: 0.7, // Уменьшили радиус для более резкого перехода
          colors: [
            Color(0xFFFFFFFF), // Очень яркий белый блик
            Color(0xFFFDFDFD),
            Color(0xFFF8F8F8),
            Color(0xFFEEEEEE),
            Color(0xFFDDDDDD),
            Color(0xFFC5C5C5),
            Color(0xFFAAAAAA),
            Color(0xFF909090),
            Color(0xFF757575), // Глубокая тень
          ],
          stops: [0.0, 0.1, 0.2, 0.35, 0.5, 0.65, 0.8, 0.9, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(220), // Более темная тень
            blurRadius: 6,
            offset: Offset(3, 3),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(120), // Более яркий блик
            blurRadius: 3,
            offset: Offset(-2, -2),
          ),
        ],
      ),
    );
  }
}
