import 'package:flutter/material.dart';
import 'dart:async';
import 'package:chess/chess.dart' as chess; // Используем библиотеку chess

import 'rule_animation_button.dart';

// Описание шага анимации (откуда, куда, какая фигура берется)
class ChessAnimationStep {
  final String fromAlg; // 'e2'
  final String toAlg; // 'e4'
  final String? capturedAlg; // 'e5' (если было взятие)

  ChessAnimationStep({
    required this.fromAlg,
    required this.toAlg,
    this.capturedAlg,
  });
}

class ChessRuleExample extends StatefulWidget {
  // Начальное состояние доски в формате FEN
  final String initialFen;
  // Список шагов анимации
  final List<ChessAnimationStep> animationSteps;
  final double size;
  final Duration animationDuration;
  final bool boardFlipped; // Перевернуть ли доску (если показываем ход черных)

  const ChessRuleExample({
    Key? key,
    required this.initialFen,
    required this.animationSteps,
    this.size = 200.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.boardFlipped = false, // По умолчанию доска не перевернута
  }) : super(key: key);

  @override
  _ChessRuleExampleState createState() => _ChessRuleExampleState();
}

class _ChessRuleExampleState extends State<ChessRuleExample> {
  late chess.Chess _game;
  int _currentStepIndex = -1;
  double? animatedPieceTop;
  double? animatedPieceLeft;
  chess.Piece? animatedPieceData;
  bool _isAnimating = false;

  final Duration _liftDelay = const Duration(milliseconds: 80);
  final Duration _betweenStepsDelay = const Duration(milliseconds: 220);
  int _animationRunId = 0;

  bool get _hasAnimation => widget.animationSteps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  @override
  void dispose() {
    _animationRunId++;
    super.dispose();
  }

  void _resetState({bool notify = false}) {
    void apply() {
      _game = chess.Chess.fromFEN(widget.initialFen);
      _currentStepIndex = -1;
      animatedPieceData = null;
      animatedPieceTop = null;
      animatedPieceLeft = null;
      _isAnimating = false;
    }

    if (notify && mounted) {
      setState(apply);
    } else {
      apply();
    }
  }

  Map<String, int> _algToCoords(String alg) {
    int col = alg.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int row = int.parse(alg.substring(1)) - 1;
    int displayRow = widget.boardFlipped ? row : 7 - row;
    int displayCol = widget.boardFlipped ? 7 - col : col;
    return {'row': displayRow, 'col': displayCol};
  }

  bool _canContinue(int runId) => mounted && _animationRunId == runId;

  Future<void> _playSequence() async {
    if (!_hasAnimation) {
      _resetState(notify: true);
      return;
    }
    final int runId = ++_animationRunId;
    setState(() {
      _isAnimating = true;
      _currentStepIndex = -1;
    });

    for (int i = 0; i < widget.animationSteps.length; i++) {
      await _runSingleStep(widget.animationSteps[i], i, runId);
      if (!_canContinue(runId)) return;
      await Future.delayed(_betweenStepsDelay);
      if (!_canContinue(runId)) return;
    }

    if (_canContinue(runId) && mounted) {
      setState(() {
        _isAnimating = false;
        _currentStepIndex = widget.animationSteps.length - 1;
        animatedPieceData = null;
        animatedPieceTop = null;
        animatedPieceLeft = null;
      });
    }
  }

  Future<void> _runSingleStep(
    ChessAnimationStep step,
    int visualIndex,
    int runId,
  ) async {
    final double squareSize = widget.size / 8;
    final chess.Piece? piece = _game.get(step.fromAlg);
    if (piece == null || !_canContinue(runId)) return;

    setState(() {
      _currentStepIndex = visualIndex;
      animatedPieceData = piece;
      _game.remove(step.fromAlg);
      final startCoords = _algToCoords(step.fromAlg);
      animatedPieceTop = startCoords['row']! * squareSize;
      animatedPieceLeft = startCoords['col']! * squareSize;
    });

    await Future.delayed(_liftDelay);
    if (!_canContinue(runId)) return;

    final endCoords = _algToCoords(step.toAlg);
    setState(() {
      animatedPieceTop = endCoords['row']! * squareSize;
      animatedPieceLeft = endCoords['col']! * squareSize;
    });

    await Future.delayed(widget.animationDuration);
    if (!_canContinue(runId) || animatedPieceData == null) return;

    setState(() {
      _game.put(animatedPieceData!, step.toAlg);
      if (step.capturedAlg != null) {
        _game.remove(step.capturedAlg!);
      }
      animatedPieceData = null;
    });
  }

  void _handlePlayPressed() {
    if (_isAnimating) {
      _resetState(notify: true);
      _animationRunId++;
    } else {
      _playSequence();
    }
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

  @override
  Widget build(BuildContext context) {
    final double squareSize = widget.size / 8;

    return GestureDetector(
      onTap: _handlePlayPressed,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          // Реалистичная рамка из темного дерева
          gradient: const LinearGradient(
            colors: [Color(0xFF5D4E37), Color(0xFF6B5D47), Color(0xFF5D4E37)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
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
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Статичная доска (Grid) с реалистичными деревянными текстурами
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 64,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // Определяем реальные координаты (0-7) с учетом переворота
                  int displayRow = index ~/ 8;
                  int displayCol = index % 8;
                  int logicalRow = widget.boardFlipped
                      ? displayRow
                      : 7 - displayRow;
                  int logicalCol = widget.boardFlipped
                      ? 7 - displayCol
                      : displayCol;

                  // Получаем имя клетки и фигуру
                  String squareName =
                      '${String.fromCharCode(97 + logicalCol)}${logicalRow + 1}';
                  var piece = _game.get(
                    squareName,
                  ); // Берем из текущего состояния _game

                  // Реалистичные деревянные текстуры как в игровой доске
                  bool isLightSquare = (logicalRow + logicalCol) % 2 == 0;
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

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: squareGradient,
                      ),
                      border: Border.all(
                        color: isLightSquare
                            ? const Color(0xFFD7BE9E).withValues(alpha: 0.3)
                            : const Color(0xFF8B6F47).withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: piece != null
                        ? Center(
                            child: Text(
                              _getPieceUnicode(piece),
                              style: TextStyle(
                                fontSize: squareSize * 0.7,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                                color: piece.color == chess.Color.WHITE
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
                          )
                        : null,
                  );
                },
              ),

              // Анимированная фигура с улучшенным стилем
              if (animatedPieceData != null &&
                  animatedPieceTop != null &&
                  animatedPieceLeft != null)
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOut,
                  top: animatedPieceTop!,
                  left: animatedPieceLeft!,
                  child: SizedBox(
                    width: squareSize,
                    height: squareSize,
                    child: Center(
                      child: Text(
                        _getPieceUnicode(animatedPieceData!),
                        style: TextStyle(
                          fontSize: squareSize * 0.7,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: animatedPieceData!.color == chess.Color.WHITE
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
                  ),
                ),

              Positioned(
                bottom: 6,
                right: 6,
                child: RuleAnimationButton(
                  isPlaying: _isAnimating,
                  enabled: _hasAnimation,
                  onPressed: _handlePlayPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
