import 'package:flutter/material.dart';
import '../games/checkers_ai.dart';
import '../games/checkers_logic.dart' as checkers;
import '../screens/game_setup_screen.dart';
import '../utils/hint_system.dart';

class CheckersBoardWidget extends StatefulWidget {
  final checkers.CheckersGameLogic game;
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;
  final bool playerPlaysWhite;
  final Function(Color) onGameEnd;
  final VoidCallback onMove;
  final bool isReadOnly; // Флаг для отключения ходов при просмотре истории

  const CheckersBoardWidget({
    Key? key,
    required this.game,
    required this.gameMode,
    this.aiDifficulty,
    this.playerPlaysWhite = true,
    required this.onGameEnd,
    required this.onMove,
    this.isReadOnly = false, // По умолчанию доска интерактивная
  }) : super(key: key);

  @override
  _CheckersBoardWidgetState createState() => _CheckersBoardWidgetState();
}

class _CheckersBoardWidgetState extends State<CheckersBoardWidget>
    with SingleTickerProviderStateMixin {
  final CheckersAI _ai = CheckersAI();
  int _selectedIndex = -1;

  // Animation variables
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  int? _animatingFrom;
  int? _animatingTo;
  checkers.GamePiece? _animatingPiece;
  bool _isAnimating = false;

  // Hint system variables
  bool _isLoadingHint = false;
  String? _currentHintText;
  int? _hintMoveFrom;
  int? _hintMoveTo;

  Color get _aiColor => widget.playerPlaysWhite ? Colors.black : Colors.white;

  int _boardIndexFromDisplay(int displayIndex) =>
      widget.playerPlaysWhite ? displayIndex : 63 - displayIndex;

  int _displayIndexFromBoard(int boardIndex) =>
      widget.playerPlaysWhite ? boardIndex : 63 - boardIndex;

  int _displayRowFromBoard(int boardIndex) =>
      _displayIndexFromBoard(boardIndex) ~/ 8;

  int _displayColFromBoard(int boardIndex) =>
      _displayIndexFromBoard(boardIndex) % 8;

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

    if (widget.gameMode == GameMode.pve &&
        !widget.playerPlaysWhite &&
        widget.game.isWhiteTurn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.gameMode == GameMode.pve &&
            widget.game.isWhiteTurn &&
            !widget.playerPlaysWhite) {
          _triggerAiMove();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate offset between two squares for animation
  Offset _calculateOffset(int from, int to) {
    int fromRow = _displayRowFromBoard(from);
    int fromCol = _displayColFromBoard(from);
    int toRow = _displayRowFromBoard(to);
    int toCol = _displayColFromBoard(to);

    double dx = (toCol - fromCol).toDouble();
    double dy = (toRow - fromRow).toDouble();

    return Offset(dx, dy);
  }

  // Animate piece movement
  Future<void> _animateMove(int from, int to) async {
    final piece = widget.game.board[from ~/ 8][from % 8];
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

  void _onSquareTapped(int index) async {
    if (widget.isReadOnly) return; // Блокируем ходы при просмотре истории
    if (widget.gameMode == GameMode.pve &&
        (widget.game.isWhiteTurn != widget.playerPlaysWhite))
      return;
    if (_isAnimating) return; // Block moves during animation

    checkers.GamePiece? piece = widget.game.board[index ~/ 8][index % 8];

    if (_selectedIndex == -1) {
      if (piece != null &&
          (piece.color == Colors.white) == widget.game.isWhiteTurn) {
        setState(() {
          _selectedIndex = index;
        });
      }
    } else {
      // Check if move is valid before animating
      final from = _selectedIndex;
      final to = index;

      // Use game logic to validate the move BEFORE animating
      bool isValidMove = widget.game.isMoveValid(from, to);

      if (isValidMove) {
        // Animate then execute move
        await _animateMove(from, to);

        bool moveSuccessful = widget.game.tryMove(from, to);
        if (moveSuccessful) {
          setState(() {});
          widget.onMove();
          _checkEndGame();

          if (widget.game.mandatoryCapturePieces.contains(index)) {
            setState(() {
              _selectedIndex = index;
            });
          } else {
            setState(() {
              _selectedIndex = -1;
            });
            if (widget.gameMode == GameMode.pve) {
              _triggerAiMove();
            }
          }
        } else {
          // Animation played but move failed - reselect or deselect
          setState(() {
            if (piece != null &&
                (piece.color == Colors.white) == widget.game.isWhiteTurn) {
              _selectedIndex = index;
            } else {
              _selectedIndex = -1;
            }
          });
        }
      } else {
        // Invalid selection - try selecting new piece or deselect
        setState(() {
          if (piece != null &&
              (piece.color == Colors.white) == widget.game.isWhiteTurn) {
            _selectedIndex = index;
          } else {
            _selectedIndex = -1;
          }
        });
      }
    }
  }

  void _triggerAiMove() async {
    if (widget.gameMode != GameMode.pve) return;
    if (widget.game.isWhiteTurn != (_aiColor == Colors.white)) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final bestMove = _ai.findBestMove(
      widget.game,
      _getAiDepth(),
      aiColor: _aiColor,
    );
    if (bestMove != null) {
      // Animate the AI move
      await _animateMove(bestMove.from, bestMove.to);

      if (!mounted) return;
      setState(() {
        widget.game.tryMove(bestMove.from, bestMove.to);
        widget.onMove();
        _checkEndGame();
      });

      if (widget.game.mandatoryCapturePieces.isNotEmpty &&
          widget.game.isWhiteTurn == (_aiColor == Colors.white)) {
        _triggerAiMove();
      }
    }
  }

  void _checkEndGame() {
    final winner = widget.game.checkWinner();
    if (winner != null) {
      widget.onGameEnd(winner);
    }
  }

  int _getAiDepth() {
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
    final playerColor = widget.playerPlaysWhite ? Colors.white : Colors.black;
    return widget.game.isWhiteTurn == (playerColor == Colors.white);
  }

  Future<void> _requestHint() async {
    if (_isLoadingHint || !HintSystem.isTrainingModeEnabled()) return;

    setState(() {
      _isLoadingHint = true;
      _currentHintText = null;
      _hintMoveFrom = null;
      _hintMoveTo = null;
    });

    try {
      final playerColor = widget.playerPlaysWhite ? Colors.white : Colors.black;
      final hint = _ai.suggestMoveWithExplanation(
        widget.game,
        3, // depth
        playerColor,
      );

      if (hint != null && mounted) {
        setState(() {
          _hintMoveFrom = hint.move.from;
          _hintMoveTo = hint.move.to;
          _currentHintText = hint.explanation;
        });

        HintSystem.showHint(
          context,
          title: 'Рекомендация AI',
          explanation: hint.explanation,
          moveSuggestion: HintSystem.formatCheckersMove(hint.move.from, hint.move.to),
          onApplyHint: () async {
            // Анимируем и выполняем ход
            await _animateMove(hint.move.from, hint.move.to);
            widget.game.tryMove(hint.move.from, hint.move.to);
            setState(() {
              _hintMoveFrom = null;
              _hintMoveTo = null;
              _selectedIndex = -1;
            });
            widget.onMove();
            _checkEndGame();

            // ВАЖНО: Если режим PvE и игра не закончена, запускаем ход AI
            if (widget.gameMode == GameMode.pve && widget.game.checkWinner() == null) {
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
    const boardSize = 600.0;
    const squareSize = boardSize / 8;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        // Реалистичная деревянная рамка
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
      padding: const EdgeInsets.all(6),
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
                final boardIndex = _boardIndexFromDisplay(index);
                final boardRow = boardIndex ~/ 8;
                final boardCol = boardIndex % 8;
                checkers.GamePiece? piece =
                    widget.game.board[boardRow][boardCol];

                // Реалистичные деревянные текстуры
                bool isLightSquare = (boardRow + boardCol) % 2 == 0;
                List<Color> squareGradient = isLightSquare
                    ? [
                        const Color(0xFFF0D9B5),
                        const Color(0xFFEECEA0),
                        const Color(0xFFE8C297),
                      ]
                    : [
                        const Color(0xFFB58863),
                        const Color(0xFFA67C52),
                        const Color(0xFF987456),
                      ];

                bool isMandatory = widget.game.mandatoryCapturePieces.contains(
                  boardIndex,
                );

                // Hide piece if it's currently animating from this square
                bool hidePiece = _isAnimating && boardIndex == _animatingFrom;

                // Check if this square is part of the hint
                bool isHintFrom = _hintMoveFrom == boardIndex;
                bool isHintTo = _hintMoveTo == boardIndex;

                return GestureDetector(
                  onTap: () => _onSquareTapped(boardIndex),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: squareGradient,
                      ),
                      border: Border.all(
                        color: (isHintFrom || isHintTo)
                            ? Colors.amber.shade700
                            : (_selectedIndex == boardIndex
                                ? Colors.blue.shade700
                                : (isMandatory
                                      ? Colors.red.shade700
                                      : (isLightSquare
                                            ? const Color(0xFFD7BE9E).withAlpha(76)
                                            : const Color(
                                                0xFF8B6F47,
                                              ).withAlpha(76)))),
                        width: (isHintFrom || isHintTo)
                            ? 3
                            : (_selectedIndex == boardIndex
                                ? 3
                                : (isMandatory ? 3 : 0.5)),
                      ),
                      boxShadow: (isHintFrom || isHintTo)
                          ? [
                              BoxShadow(
                                color: Colors.amber.withAlpha(150),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : (_selectedIndex == boardIndex || isMandatory
                              ? [
                                  BoxShadow(
                                    color:
                                        (_selectedIndex == boardIndex
                                                ? Colors.blue
                                                : Colors.red)
                                            .withAlpha(100),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ]),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Тонкая текстура дерева
                        if (isLightSquare)
                          Opacity(
                            opacity: 0.05,
                            child: CustomPaint(
                              size: const Size(squareSize, squareSize),
                              painter: _WoodGrainPainter(isLight: true),
                            ),
                          ),
                        if (piece != null && !hidePiece)
                          _buildPieceWidget(piece),
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
                  int fromRow = _displayRowFromBoard(_animatingFrom!);
                  int fromCol = _displayColFromBoard(_animatingFrom!);

                  final double startX = fromCol * squareSize;
                  final double startY = fromRow * squareSize;

                  return Positioned(
                    left: startX + (_animation.value.dx * squareSize),
                    top: startY + (_animation.value.dy * squareSize),
                    width: squareSize,
                    height: squareSize,
                    child: _buildPieceWidget(_animatingPiece!),
                  );
                },
              ),

            // Hint button (only in training mode and player's turn)
            if (HintSystem.isTrainingModeEnabled() &&
                !widget.isReadOnly &&
                _isPlayerTurn())
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
        ), // Stack
      ), // Inner Container
    ); // Outer Container
  }

  Widget _buildPieceWidget(checkers.GamePiece piece) {
    bool isWhite = piece.color == Colors.white;

    return FractionallySizedBox(
      widthFactor: 0.8,
      heightFactor: 0.8,
      child: Container(
        decoration: BoxDecoration(
          // Реалистичный пластиковый/деревянный вид фишек
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 0.8,
            colors: isWhite
                ? [
                    const Color(0xFFFAFAFA), // Светлый центр
                    const Color(0xFFEEEEEE),
                    const Color(0xFFDDDDDD), // Темнее по краям
                  ]
                : [
                    const Color(0xFF3A3A3A), // Светлее в центре для бликов
                    const Color(0xFF2A2A2A),
                    const Color(0xFF1A1A1A), // Темный край
                  ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isWhite ? const Color(0xFFCCCCCC) : const Color(0xFF0A0A0A),
            width: 2.5,
          ),
          boxShadow: [
            // Тень от фишки
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            // Внутренняя тень для глубины
            BoxShadow(
              color: isWhite
                  ? Colors.black.withAlpha(25)
                  : Colors.black.withAlpha(60),
              blurRadius: 4,
              spreadRadius: -2,
            ),
            // Блик сверху
            BoxShadow(
              color: Colors.white.withAlpha(isWhite ? 40 : 20),
              blurRadius: 6,
              offset: const Offset(-2, -2),
              spreadRadius: -4,
            ),
          ],
        ),
        child: piece.type == checkers.PieceType.king
            ? Stack(
                alignment: Alignment.center,
                children: [
                  // Корона для дамки
                  Icon(
                    Icons.workspace_premium,
                    color: isWhite
                        ? const Color(0xFFFFD700) // Золотая корона для белых
                        : const Color(0xFFFFA500), // Оранжевая для черных
                    size: 32,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ],
              )
            : null,
      ),
    );
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
