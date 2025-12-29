import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'rule_animation_button.dart';

// Описание состояния лунки/казана
class ExampleTogyzPit {
  final int count;
  final bool isTuzdyk;
  final Color? tuzdykOwner;

  ExampleTogyzPit(this.count, {this.isTuzdyk = false, this.tuzdykOwner});
}

// Описание шага анимации
class TogyzAnimationStep {
  final int fromOtauIndex;
  final List<int> toOtauIndices;
  final int? captureOtauIndex;
  final int? tuzdykCreationIndex;
  final Color? tuzdykPlayerColor;

  TogyzAnimationStep({
    required this.fromOtauIndex,
    required this.toOtauIndices,
    this.captureOtauIndex,
    this.tuzdykCreationIndex,
    this.tuzdykPlayerColor,
  });
}

class TogyzRuleExample extends StatefulWidget {
  final List<ExampleTogyzPit> initialOtaus;
  final int initialWhiteKazan;
  final int initialBlackKazan;
  final List<TogyzAnimationStep> animationSteps;
  final double width;
  final Duration stepDuration;

  const TogyzRuleExample({
    Key? key,
    required this.initialOtaus,
    this.initialWhiteKazan = 0,
    this.initialBlackKazan = 0,
    required this.animationSteps,
    this.width = 350.0,
    this.stepDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _TogyzRuleExampleState createState() => _TogyzRuleExampleState();
}

class _TogyzRuleExampleState extends State<TogyzRuleExample> {
  static const int _maxVisibleExampleKumalaks = 24;
  late List<ExampleTogyzPit> currentOtaus;
  late int currentWhiteKazan;
  late int currentBlackKazan;
  int _currentMasterStepIndex = -1;
  int _currentSubStepIndex = -1;
  bool _isAnimating = false;
  int _animationRunId = 0;

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _resetState({bool notify = false}) {
    void apply() {
      _updateStateOnReset();
    }

    if (notify && mounted) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _updateStateOnReset() {
    currentOtaus = widget.initialOtaus
        .map(
          (pit) => ExampleTogyzPit(
            pit.count,
            isTuzdyk: pit.isTuzdyk,
            tuzdykOwner: pit.tuzdykOwner,
          ),
        )
        .toList();
    currentWhiteKazan = widget.initialWhiteKazan;
    currentBlackKazan = widget.initialBlackKazan;
    _currentMasterStepIndex = -1;
    _currentSubStepIndex = -1;
    _isAnimating = false;
  }

  int? get _currentHighlightedPit {
    if (!_isAnimating ||
        _currentMasterStepIndex < 0 ||
        _currentMasterStepIndex >= widget.animationSteps.length) {
      return null;
    }
    final step = widget.animationSteps[_currentMasterStepIndex];
    if (_currentSubStepIndex < 0) return step.fromOtauIndex;
    if (_currentSubStepIndex >= step.toOtauIndices.length) return null;
    return step.toOtauIndices[_currentSubStepIndex];
  }

  bool get _hasAnimation => widget.animationSteps.isNotEmpty;

  bool _canContinue(int runId) => mounted && _animationRunId == runId;

  void _handlePlayPressed() {
    if (_isAnimating) {
      _animationRunId++;
      _resetState(notify: true);
    } else {
      _playSequence();
    }
  }

  Future<void> _playSequence() async {
    if (!_hasAnimation) {
      _resetState(notify: true);
      return;
    }

    final int runId = ++_animationRunId;
    setState(() {
      _isAnimating = true;
      _currentMasterStepIndex = -1;
      _currentSubStepIndex = -1;
    });

    for (int i = 0; i < widget.animationSteps.length; i++) {
      await _runSingleStep(widget.animationSteps[i], i, runId);
      if (!_canContinue(runId)) return;
      await Future.delayed(widget.stepDuration);
      if (!_canContinue(runId)) return;
    }

    if (_canContinue(runId) && mounted) {
      setState(() {
        _isAnimating = false;
        _currentSubStepIndex = -1;
      });
    }
  }

  Future<void> _runSingleStep(
    TogyzAnimationStep step,
    int stepIndex,
    int runId,
  ) async {
    if (!_canContinue(runId)) return;

    setState(() {
      _currentMasterStepIndex = stepIndex;
      _currentSubStepIndex = -1;
      final int initialCount = currentOtaus[step.fromOtauIndex].count;
      currentOtaus[step.fromOtauIndex] = ExampleTogyzPit(
        initialCount == 1 ? 0 : 1,
      );
    });

    for (int i = 0; i < step.toOtauIndices.length; i++) {
      if (!_canContinue(runId)) return;
      await Future.delayed(widget.stepDuration);
      if (!_canContinue(runId)) return;

      final int targetIndex = step.toOtauIndices[i];
      setState(() {
        _currentSubStepIndex = i;
        if (_isOpponentTuzdyk(step, targetIndex)) {
          if (currentOtaus[targetIndex].tuzdykOwner == Colors.white) {
            currentWhiteKazan++;
          } else {
            currentBlackKazan++;
          }
        } else {
          currentOtaus[targetIndex] = ExampleTogyzPit(
            currentOtaus[targetIndex].count + 1,
            isTuzdyk: currentOtaus[targetIndex].isTuzdyk,
            tuzdykOwner: currentOtaus[targetIndex].tuzdykOwner,
          );
        }
      });
    }

    if (!_canContinue(runId)) return;
    await Future.delayed(widget.stepDuration);
    if (!_canContinue(runId)) return;

    setState(() {
      if (step.captureOtauIndex != null) {
        final captureIndex = step.captureOtauIndex!;
        if (captureIndex >= 0 && captureIndex < currentOtaus.length) {
          final capturedCount = currentOtaus[captureIndex].count;
          if (captureIndex >= 9) {
            currentWhiteKazan += capturedCount;
          } else {
            currentBlackKazan += capturedCount;
          }
          currentOtaus[captureIndex] = ExampleTogyzPit(0);
        }
      }
      if (step.tuzdykCreationIndex != null) {
        final tuzdykIndex = step.tuzdykCreationIndex!;
        if (tuzdykIndex >= 0 && tuzdykIndex < currentOtaus.length) {
          final tuzdykCount = currentOtaus[tuzdykIndex].count;
          if (step.tuzdykPlayerColor == Colors.white) {
            currentWhiteKazan += tuzdykCount;
          } else {
            currentBlackKazan += tuzdykCount;
          }
          currentOtaus[tuzdykIndex] = ExampleTogyzPit(
            0,
            isTuzdyk: true,
            tuzdykOwner: step.tuzdykPlayerColor,
          );
        }
      }
    });
  }

  bool _isOpponentTuzdyk(TogyzAnimationStep step, int targetIndex) {
    return (step.tuzdykPlayerColor == Colors.white &&
            currentOtaus[targetIndex].tuzdykOwner == Colors.black) ||
        (step.tuzdykPlayerColor == Colors.black &&
            currentOtaus[targetIndex].tuzdykOwner == Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final double boardWidth = widget.width;
    final double boardHeight = boardWidth / 1.5; // ОГРОМНАЯ высота доски - увеличили для 4 рядов кумалаков
    final int? highlightPit = _currentHighlightedPit;

    return SizedBox(
      width: boardWidth,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handlePlayPressed,
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
                    // Верхняя нумерация (9-1) - перевернутая
                    _buildNumberRow(List.generate(9, (i) => 9 - i), boardWidth, upsideDown: true),
                    SizedBox(height: boardHeight * 0.01),

                    // Верхний ряд лунок - перевернутый
                    Expanded(
                      flex: 5, // Ещё больше увеличили высоту лунок
                      child: _buildPitRow(
                        List.generate(9, (i) => 17 - i),
                        boardWidth,
                        highlightPit,
                        upsideDown: true,
                      ),
                    ),

                    SizedBox(height: boardHeight * 0.02),

                    // ДВА КАЗАНА ГОРИЗОНТАЛЬНО - УВЕЛИЧИЛИ высоту
                    Expanded(flex: 3, child: _buildKazansRow(boardWidth)),

                    SizedBox(height: boardHeight * 0.02),

                    // Нижний ряд лунок
                    Expanded(
                      flex: 5, // Ещё больше увеличили высоту лунок
                      child: _buildPitRow(
                        List.generate(9, (i) => i),
                        boardWidth,
                        highlightPit,
                      ),
                    ),

                    SizedBox(height: boardHeight * 0.01),
                    // Нижняя нумерация (1-9)
                    _buildNumberRow(List.generate(9, (i) => i + 1), boardWidth),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: RuleAnimationButton(
              isPlaying: _isAnimating,
              enabled: _hasAnimation,
              onPressed: _handlePlayPressed,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPitRow(List<int> indices, double boardWidth, int? highlightPit, {bool upsideDown = false}) {
    return Row(
      children: indices.map((index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: boardWidth * 0.005),
            child: _buildPit(index, boardWidth, highlightPit == index, upsideDown: upsideDown),
          ),
        );
      }).toList(),
    );
  }

  // Узкая вытянутая вертикально лунка (ТОЧНО как на картинке)
  Widget _buildPit(int index, double boardWidth, bool isHighlighted, {bool upsideDown = false}) {
    final pit = currentOtaus[index];
    final bool isTuzdyk = pit.isTuzdyk;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.5,
          colors: [Color(0xFF4A2F1A), Color(0xFF3A2515), Color(0xFF2A1B10)],
        ),
        borderRadius: BorderRadius.circular(boardWidth * 0.025),
        border: Border.all(
          color: isHighlighted
              ? Color(0xFFFFB347)
              : isTuzdyk
              ? Color(0xFFFFD700)
              : Color(0xFF5A3820),
          width: isHighlighted ? 2.5 : (isTuzdyk ? 2 : 1),
        ),
        boxShadow: [
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
          Center(child: _buildKumalaksInPit(pit.count, isTuzdyk, boardWidth)),
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
                  '${pit.count}',
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
    );
  }

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
        Expanded(child: _buildKazan(boardWidth, currentBlackKazan, isLeft: true)),
        SizedBox(width: 8),
        // Правый казан (белый игрок)
        Expanded(child: _buildKazan(boardWidth, currentWhiteKazan, isLeft: false)),
      ],
    );
  }

  // Казан с визуальными кумалаками внутри
  Widget _buildKazan(double boardWidth, int count, {required bool isLeft}) {
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
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: isLeft
              ? EdgeInsets.only(left: boardWidth * 0.015)
              : EdgeInsets.only(right: boardWidth * 0.015),
          // Визуальные кумалаки в казане БЕЗ числа
          child: _buildKazanKumalaks(count, boardWidth, alignRight: !isLeft),
        ),
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

// Painter для РЕАЛИСТИЧНОЙ текстуры дерева с настоящими древесными волокнами
