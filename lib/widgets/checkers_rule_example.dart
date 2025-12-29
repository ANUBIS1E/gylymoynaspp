import 'package:flutter/material.dart';
import 'dart:async'; // Для задержки анимации

import 'rule_animation_button.dart';

// Описание шашки (как раньше)
class ExamplePiece {
  final Color color;
  final bool isKing;
  ExamplePiece(this.color, {this.isKing = false});
}

// Описание шага анимации (откуда, куда, какая фигура берется)
class AnimationStep {
  final int fromRow, fromCol;
  final int toRow, toCol;
  final int? captureRow, captureCol; // Опционально: координаты сбитой шашки

  AnimationStep({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.captureRow,
    this.captureCol,
  });
}

class CheckersRuleExample extends StatefulWidget {
  final List<List<ExamplePiece?>> initialBoardState;
  // Список шагов анимации, которые нужно показать
  final List<AnimationStep> animationSteps;
  final double size;
  final Duration animationDuration; // Длительность анимации

  const CheckersRuleExample({
    Key? key,
    required this.initialBoardState,
    required this.animationSteps,
    this.size = 200.0,
    this.animationDuration = const Duration(
      milliseconds: 600,
    ), // Длительность по умолчанию
  }) : super(key: key);

  @override
  _CheckersRuleExampleState createState() => _CheckersRuleExampleState();
}

class _CheckersRuleExampleState extends State<CheckersRuleExample> {
  late List<List<ExamplePiece?>> currentBoardState;
  int _currentStepIndex = -1;
  double? animatedPieceTop;
  double? animatedPieceLeft;
  ExamplePiece? animatedPieceData;
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
      currentBoardState = List.generate(
        widget.initialBoardState.length,
        (row) => List.generate(
          widget.initialBoardState[row].length,
          (col) => widget.initialBoardState[row][col],
        ),
      );
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
    AnimationStep step,
    int visualIndex,
    int runId,
  ) async {
    final double squareSize = widget.size / 8;
    final ExamplePiece? piece = currentBoardState[step.fromRow][step.fromCol];
    if (piece == null || !_canContinue(runId)) return;

    setState(() {
      _currentStepIndex = visualIndex;
      animatedPieceData = piece;
      currentBoardState[step.fromRow][step.fromCol] = null;
      animatedPieceTop = step.fromRow * squareSize;
      animatedPieceLeft = step.fromCol * squareSize;
    });

    await Future.delayed(_liftDelay);
    if (!_canContinue(runId)) return;

    setState(() {
      animatedPieceTop = step.toRow * squareSize;
      animatedPieceLeft = step.toCol * squareSize;
    });

    await Future.delayed(widget.animationDuration);
    if (!_canContinue(runId)) return;

    setState(() {
      currentBoardState[step.toRow][step.toCol] = piece;
      if (step.captureRow != null && step.captureCol != null) {
        currentBoardState[step.captureRow!][step.captureCol!] = null;
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

  @override
  Widget build(BuildContext context) {
    final double squareSize = widget.size / 8;

    return GestureDetector(
      onTap: _handlePlayPressed,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          // Реалистичная деревянная рамка
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
        padding: const EdgeInsets.all(6),
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
            // Используем Stack для наложения анимированной фигуры
            children: [
              // Статичная доска (Grid) с улучшенными цветами
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 64,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  ExamplePiece? piece;
                  if (row < currentBoardState.length &&
                      col < currentBoardState[row].length) {
                    piece = currentBoardState[row][col];
                  }
                  // Улучшенные деревянные текстуры
                  bool isLightSquare = (row + col) % 2 == 0;
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
                    ),
                    child: piece != null
                        ? _buildPieceWidget(piece, squareSize)
                        : null,
                  );
                },
              ),

              // Анимированная фигура (если есть)
              if (animatedPieceData != null &&
                  animatedPieceTop != null &&
                  animatedPieceLeft != null)
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOut,
                  top: animatedPieceTop!,
                  left: animatedPieceLeft!,
                  child: SizedBox(
                    // Ограничиваем размер анимируемой фигуры
                    width: squareSize,
                    height: squareSize,
                    child: _buildPieceWidget(animatedPieceData!, squareSize),
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

  // Виджет фигуры с улучшенным 3D эффектом
  Widget _buildPieceWidget(ExamplePiece piece, double squareSize) {
    return FractionallySizedBox(
      widthFactor: 0.75,
      heightFactor: 0.75,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: piece.color == Colors.white
                ? [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF5F5F5),
                    const Color(0xFFE0E0E0),
                    const Color(0xFFD0D0D0),
                  ]
                : [
                    const Color(0xFF505050),
                    const Color(0xFF404040),
                    const Color(0xFF303030),
                    const Color(0xFF202020),
                  ],
            stops: const [0.0, 0.4, 0.7, 1.0],
            center: const Alignment(-0.3, -0.3),
          ),
          border: Border.all(
            color: piece.color == Colors.white
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: piece.isKing
            ? Icon(
                Icons.star,
                color: piece.color == Colors.white
                    ? const Color(0xFFFFD700)
                    : const Color(0xFFFFD700),
                size: squareSize * 0.35,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
