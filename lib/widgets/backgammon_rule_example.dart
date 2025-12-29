import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../games/backgammon_logic.dart' as backgammon; // Use logic for state
import 'rule_animation_button.dart';

// Animation step definition
class BackgammonAnimationStep {
  final List<int> diceRoll;
  final List<Map<String, int>> moves;
  BackgammonAnimationStep({required this.diceRoll, required this.moves});
}

class BackgammonRuleExample extends StatefulWidget {
  final List<backgammon.PointState> initialPoints;
  final List<BackgammonAnimationStep> animationSteps;
  final double width;
  final Duration moveDuration;

  const BackgammonRuleExample({
    Key? key,
    required this.initialPoints,
    required this.animationSteps,
    this.width = 300.0,
    this.moveDuration = const Duration(milliseconds: 700), // Slower animation
  }) : super(key: key);

  @override
  _BackgammonRuleExampleState createState() => _BackgammonRuleExampleState();
}

class _BackgammonRuleExampleState extends State<BackgammonRuleExample> {
  late List<backgammon.PointState> currentPoints;
  List<int> currentDice = [];
  List<int> usedDiceVisual = [];
  int _currentMasterStepIndex = -1;
  int _currentMoveIndex = -1;
  bool _isAnimating = false;
  int _animationRunId = 0;

  // Animated checker properties
  double? animatedCheckerTop;
  double? animatedCheckerLeft;
  Color? animatedCheckerColor;
  bool _showAnimatedChecker = false;

  // Board dimensions calculated in build
  late double pointWidth;
  late double checkerSize;
  late double boardHeight;
  late double barWidth;
  late double homeWidth;
  late double boardPadding; // Store padding

  @override
  void initState() {
    super.initState();
    // Dimensions will be initialized in build before first use
    _resetState();
  }

  @override
  void dispose() {
    _animationRunId++;
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
    // Deep copy initial state
    currentPoints = widget.initialPoints.map((p) => p.clone()).toList();
    _currentMasterStepIndex = -1;
    _currentMoveIndex = -1;
    _isAnimating = false;
    currentDice = [];
    usedDiceVisual = [];
    _showAnimatedChecker = false;
  }

  // --- Coordinate Calculation ---
  Offset _getPointCenter(int index, bool isTopRow) {
    double halfCount = 6.0; // Points per quadrant
    // boardPadding is calculated in build
    double halfBoardWidth = pointWidth * halfCount;
    double effectiveBoardHeight =
        boardHeight; // boardHeight calculated in build

    // Y position based on row (relative to the board container)
    double yPos = isTopRow
        ? (effectiveBoardHeight / 4)
        : (effectiveBoardHeight * 3 / 4);

    // X position calculation (more precise)
    double xPos = 0;
    if (index >= 0 && index <= 5) {
      // Bottom Left (0-5)
      xPos = boardPadding + (index + 0.5) * pointWidth;
    } else if (index >= 6 && index <= 11) {
      // Top Left (11-6) - Indices need reversal
      xPos = boardPadding + (halfCount - (index - 6) - 0.5) * pointWidth;
    } else if (index >= 12 && index <= 17) {
      // Top Right (12-17)
      xPos =
          boardPadding +
          halfBoardWidth +
          barWidth +
          ((index - 12) + 0.5) * pointWidth;
    } else if (index >= 18 && index <= 23) {
      // Bottom Right (23-18) - Indices need reversal
      xPos =
          boardPadding +
          halfBoardWidth +
          barWidth +
          (halfCount - (index - 18) - 0.5) * pointWidth;
    } else {
      // Fallback for bar/home or invalid index (shouldn't happen for points)
      xPos = widget.width / 2; // Use widget width as fallback basis
    }

    return Offset(xPos, yPos);
  }

  Offset _getBarPosition(Color color) {
    // Use calculated dimensions
    double xPos = boardPadding + pointWidth * 6 + barWidth / 2;
    double yPos = (color == Colors.white)
        ? boardHeight * 0.25
        : boardHeight * 0.75;
    return Offset(xPos, yPos);
  }

  Offset _getHomePosition(Color color) {
    // Use calculated dimensions
    double xPos = boardPadding + pointWidth * 12 + barWidth + homeWidth / 2;
    double yPos = (color == Colors.white)
        ? boardHeight * 0.25
        : boardHeight * 0.75;
    return Offset(xPos, yPos);
  }
  // --- End Coordinate Calculation ---

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions here
    final screenWidth = MediaQuery.of(context).size.width;
    final boardWidthCalc = widget.width;
    boardHeight = boardWidthCalc * 0.8;
    // Use the adjusted divisor to prevent overflow
    pointWidth = boardWidthCalc / 16.2;
    checkerSize = pointWidth * 0.8;
    barWidth = pointWidth * 1.3;
    homeWidth = pointWidth * 1.9;
    boardPadding = pointWidth * 0.1;

    return GestureDetector(
      onTap: _handlePlayPressed,
      child: Container(
        width: boardWidthCalc,
        height: boardHeight + 45, // Adjusted height
        padding: EdgeInsets.all(boardPadding), // Use calculated padding
        decoration: BoxDecoration(
          // Реалистичная деревянная текстура как у других досок
          gradient: const LinearGradient(
            colors: [Color(0xFF8B6F47), Color(0xFF9B7F57), Color(0xFF8B6F47)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF3D2E1F), width: 4),
          borderRadius: BorderRadius.circular(6),
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
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RuleAnimationButton(
                        isPlaying: _isAnimating,
                        enabled: _hasAnimation,
                        onPressed: _handlePlayPressed,
                      ),
                      const SizedBox(width: 15),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildDiceWidgets(checkerSize),
                      ),
                    ],
                  ),
                ),
                // Use Expanded for the board area
                Expanded(
                  child: SizedBox(
                    height: boardHeight, // Constrain height explicitly
                    child: Row(
                      children: [
                        _buildHalfBoard(0, 11, pointWidth, checkerSize, true),
                        _buildBar(
                          barWidth,
                          checkerSize * 0.9,
                          boardHeight * 0.98,
                        ), // Pass height
                        _buildHalfBoard(12, 23, pointWidth, checkerSize, false),
                        _buildHomeArea(homeWidth, checkerSize),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Animated checker overlay
            if (_showAnimatedChecker &&
                animatedCheckerColor != null &&
                animatedCheckerTop != null &&
                animatedCheckerLeft != null)
              AnimatedPositioned(
                duration: widget.moveDuration,
                curve: Curves.easeOut,
                top: animatedCheckerTop!,
                left: animatedCheckerLeft!,
                child: _buildChecker(animatedCheckerColor!, checkerSize),
              ),
          ],
        ),
      ),
    );
  }

  // --- BUILD METHODS ---

  List<Widget> _buildDiceWidgets(double size) {
    List<Widget> diceWidgets = [];
    Map<int, int> diceCounts = {};
    Map<int, int> usedCounts = {};
    for (int die in currentDice) {
      diceCounts[die] = (diceCounts[die] ?? 0) + 1;
    }
    for (int used in usedDiceVisual) {
      usedCounts[used] = (usedCounts[used] ?? 0) + 1;
    }
    List<int> sortedUniqueDice = currentDice.toSet().toList()..sort();
    for (int dieValue in sortedUniqueDice) {
      int totalCount = diceCounts[dieValue] ?? 0;
      int usedCount = usedCounts[dieValue] ?? 0;
      int unusedCount = totalCount - usedCount;
      for (int i = 0; i < unusedCount; i++) {
        diceWidgets.add(_buildDie(dieValue, size, false));
      }
      for (int i = 0; i < usedCount; i++) {
        diceWidgets.add(_buildDie(dieValue, size, true));
      }
    }
    if (currentDice.isEmpty) {
      diceWidgets.add(_buildDiePlaceholder(size));
      diceWidgets.add(_buildDiePlaceholder(size));
    }
    return diceWidgets;
  }

  Widget _buildDiePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(color: Colors.black.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildHalfBoard(
    int startPoint,
    int endPoint,
    double pointWidth,
    double checkerSize,
    bool isLeftHalf,
  ) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(6, (i) {
                int pointIndex = isLeftHalf ? endPoint - i : startPoint + i;
                return _buildPoint(pointIndex, pointWidth, checkerSize, true);
              }),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(6, (i) {
                int pointIndex = isLeftHalf ? startPoint + i : endPoint - i;
                return _buildPoint(pointIndex, pointWidth, checkerSize, false);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoint(
    int index,
    double width,
    double checkerSize,
    bool isTopRow,
  ) {
    if (index < 0 || index >= currentPoints.length)
      return SizedBox(width: width);
    backgammon.PointState point = currentPoints[index];
    Color pointColor = index % 2 == 0
        ? const Color(0xFFD2B48C)
        : const Color(0xFF8B5A2B);
    bool isSelected = false; // Simplified for rules
    bool isPossibleDest = false; // Simplified for rules

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: pointColor,
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.6),
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
              ]
            : null, // No destination highlight in rules
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double effectiveCheckerHeight = checkerSize * 0.7;
          int maxVisibleCheckers =
              (constraints.maxHeight / effectiveCheckerHeight).floor();
          maxVisibleCheckers = max(
            1,
            maxVisibleCheckers > 0 ? maxVisibleCheckers : 1,
          );
          int displayedCount = min(point.count, maxVisibleCheckers);

          return Stack(
            alignment: isTopRow ? Alignment.topCenter : Alignment.bottomCenter,
            children: [
              ...List.generate(displayedCount, (i) {
                double offset = i * effectiveCheckerHeight;
                return Positioned(
                  top: isTopRow ? offset : null,
                  bottom: !isTopRow ? offset : null,
                  left: (width - checkerSize) / 2,
                  child: _buildChecker(
                    point.color ?? Colors.transparent,
                    checkerSize,
                  ),
                );
              }),
              if (point.count > maxVisibleCheckers)
                Positioned(
                  top: isTopRow
                      ? (maxVisibleCheckers - 0.7) * effectiveCheckerHeight
                      : null,
                  bottom: !isTopRow
                      ? (maxVisibleCheckers - 0.7) * effectiveCheckerHeight
                      : null,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        point.count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: checkerSize * 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }, // Added comma
      ),
    );
  }

  Widget _buildBar(double width, double checkerSize, double barHeight) {
    if (backgammon.BackgammonLogic.whiteBarIndex >= currentPoints.length ||
        backgammon.BackgammonLogic.blackBarIndex >= currentPoints.length)
      return SizedBox(width: width);
    backgammon.PointState whiteBar =
        currentPoints[backgammon.BackgammonLogic.whiteBarIndex];
    backgammon.PointState blackBar =
        currentPoints[backgammon.BackgammonLogic.blackBarIndex];

    return Container(
      width: width,
      height: barHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF53350A).withOpacity(0.8),
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.black.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Container(
                constraints: BoxConstraints(minHeight: barHeight * 0.45),
                color: Colors.transparent,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    whiteBar.count,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: _buildChecker(Colors.white, checkerSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: max(1.0, barHeight * 0.02),
            color: Colors.black.withOpacity(0.3),
          ),
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Container(
                constraints: BoxConstraints(minHeight: barHeight * 0.45),
                color: Colors.transparent,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    blackBar.count,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: _buildChecker(Colors.black, checkerSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeArea(double width, double checkerSize) {
    int whiteHomeCount =
        currentPoints[backgammon.BackgammonLogic.whiteHomeIndex].count;
    int blackHomeCount =
        currentPoints[backgammon.BackgammonLogic.blackHomeIndex].count;
    bool isWhiteTarget = false;
    bool isBlackTarget = false;

    // Highlight logic simplified/removed for rules example
    // if (widget.game.selectedPointIndex != null ... ) { ... }

    return Container(
      width: width,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        border: Border(
          left: BorderSide(color: Colors.black54.withOpacity(0.5), width: 2),
        ),
        borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHomeStack(
            Colors.white,
            whiteHomeCount,
            checkerSize * 1.2,
            isWhiteTarget,
          ),
          _buildHomeStack(
            Colors.black,
            blackHomeCount,
            checkerSize * 1.2,
            isBlackTarget,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeStack(Color color, int count, double size, bool isTarget) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isTarget
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Text(
          count.toString(),
          style: TextStyle(
            fontSize: size * 1.2,
            fontWeight: FontWeight.bold,
            color: color == Colors.white
                ? Colors.white.withOpacity(0.9)
                : Colors.black.withOpacity(0.7),
            shadows: [Shadow(color: Colors.black26, blurRadius: 1)],
          ),
        ),
      ),
    );
  }

  Widget _buildChecker(Color color, double size) {
    bool isWhite = color == Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: isWhite
              ? [Colors.white, Colors.grey.shade400]
              : [Colors.grey.shade800, Colors.black],
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withOpacity(isWhite ? 0.3 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildDie(int value, double size, bool used) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        // Реалистичный 3D кубик
        gradient: RadialGradient(
          colors: used
              ? [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                  Colors.grey.shade600,
                ]
              : [
                  Colors.white,
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8E8E8),
                ],
          center: const Alignment(-0.3, -0.3),
          radius: 1.0,
        ),
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(
          color: Colors.black.withValues(alpha: used ? 0.3 : 0.6),
          width: 1.5,
        ),
        boxShadow: used
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: used ? Colors.white.withValues(alpha: 0.6) : Colors.black87,
            shadows: used
                ? []
                : [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 1,
                      offset: const Offset(0.5, 0.5),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  bool get _hasAnimation => widget.animationSteps.isNotEmpty;

  bool _canContinue(int runId) => mounted && _animationRunId == runId;

  void _handlePlayPressed() {
    if (_isAnimating) {
      _animationRunId++;
      _resetState(notify: true);
    } else {
      _playAnimationSequence();
    }
  }

  Future<void> _playAnimationSequence() async {
    if (!_hasAnimation) {
      _resetState(notify: true);
      return;
    }

    final int runId = ++_animationRunId;
    _resetState();
    if (!mounted) return;

    setState(() {
      _isAnimating = true;
      _currentMasterStepIndex = -1;
      _currentMoveIndex = -1;
      currentDice = [];
      usedDiceVisual = [];
      _showAnimatedChecker = false;
    });

    for (int i = 0; i < widget.animationSteps.length; i++) {
      await _playSingleMasterStep(widget.animationSteps[i], i, runId);
      if (!_canContinue(runId)) return;
      await Future.delayed(const Duration(milliseconds: 300));
      if (!_canContinue(runId)) return;
    }

    if (_canContinue(runId) && mounted) {
      setState(() {
        _isAnimating = false;
        _currentMoveIndex = -1;
        currentDice = [];
        usedDiceVisual = [];
        _showAnimatedChecker = false;
      });
    }
  }

  Future<void> _playSingleMasterStep(
    BackgammonAnimationStep step,
    int stepIndex,
    int runId,
  ) async {
    if (!_canContinue(runId)) return;

    setState(() {
      _currentMasterStepIndex = stepIndex;
      _currentMoveIndex = -1;
      currentDice = List.from(step.diceRoll);
      usedDiceVisual = [];
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!_canContinue(runId)) return;

    for (int moveIndex = 0; moveIndex < step.moves.length; moveIndex++) {
      await _animateMove(step.moves[moveIndex], moveIndex, runId);
      if (!_canContinue(runId)) return;
    }
  }

  Future<void> _animateMove(
    Map<String, int> move,
    int moveIndex,
    int runId,
  ) async {
    final int fromIndex = move['from'] ?? -1;
    final int toIndex = move['to'] ?? -1;
    final int dieValue = move['die'] ?? 0;

    if (!_canContinue(runId)) return;
    if (fromIndex < 0 ||
        fromIndex >= currentPoints.length ||
        toIndex < 0 ||
        toIndex >= currentPoints.length) {
      return;
    }

    final Color? movingColor = currentPoints[fromIndex].color;
    if (movingColor == null) return;

    final bool isFromBar = fromIndex >= 24;
    final bool isToHome = toIndex >= 26;
    final bool isFromTopRow = fromIndex >= 12 && fromIndex <= 23;
    final bool isToTopRow = toIndex >= 12 && toIndex <= 23;

    Offset startPos = isFromBar
        ? _getBarPosition(movingColor)
        : _getPointCenter(fromIndex, isFromTopRow);

    setState(() {
      _currentMoveIndex = moveIndex;
      animatedCheckerColor = movingColor;
      animatedCheckerLeft = startPos.dx - checkerSize / 2;
      animatedCheckerTop = startPos.dy - checkerSize / 2;
      _showAnimatedChecker = true;
      currentPoints[fromIndex].count--;
      if (currentPoints[fromIndex].count == 0) {
        currentPoints[fromIndex].color = null;
      }
    });

    await Future.delayed(const Duration(milliseconds: 70));
    if (!_canContinue(runId)) return;

    Offset endPos = isToHome
        ? _getHomePosition(movingColor)
        : _getPointCenter(toIndex, isToTopRow);
    setState(() {
      animatedCheckerLeft = endPos.dx - checkerSize / 2;
      animatedCheckerTop = endPos.dy - checkerSize / 2;
    });

    await Future.delayed(widget.moveDuration);
    if (!_canContinue(runId)) return;

    setState(() {
      _showAnimatedChecker = false;
      if (!isToHome) {
        if (currentPoints[toIndex].color != null &&
            currentPoints[toIndex].color != movingColor) {
          final int opponentBar = movingColor == Colors.white
              ? backgammon.BackgammonLogic.blackBarIndex
              : backgammon.BackgammonLogic.whiteBarIndex;
          if (opponentBar >= 0 && opponentBar < currentPoints.length) {
            currentPoints[opponentBar].count++;
            currentPoints[opponentBar].color = currentPoints[toIndex].color;
            currentPoints[toIndex].count = 0;
            currentPoints[toIndex].color = null;
          }
        }
        currentPoints[toIndex].count++;
        currentPoints[toIndex].color = movingColor;
      } else if (toIndex >= 0 && toIndex < currentPoints.length) {
        currentPoints[toIndex].count++;
        currentPoints[toIndex].color = movingColor;
      }
      usedDiceVisual.add(dieValue);
    });

    await Future.delayed(const Duration(milliseconds: 160));
  }
}
