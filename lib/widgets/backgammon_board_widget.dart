import 'package:flutter/material.dart';
import 'dart:math';
import '../games/backgammon_ai.dart'; // Import AI
import '../games/backgammon_logic.dart' as backgammon; // Use prefix
import '../screens/game_setup_screen.dart'; // Needed for GameMode
import '../utils/hint_system.dart';

class BackgammonBoardWidget extends StatefulWidget {
  final backgammon.BackgammonLogic game; // Accept game logic
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;
  final Function(Color)? onGameEnd; // Nullable for now
  final VoidCallback? onMove;      // Nullable for now

  const BackgammonBoardWidget({
    Key? key,
    required this.game, // Accept game logic
    required this.gameMode,
    this.aiDifficulty,
    this.onGameEnd,
    this.onMove,
  }) : super(key: key);

  @override
  _BackgammonBoardWidgetState createState() => _BackgammonBoardWidgetState();
}

class _BackgammonBoardWidgetState extends State<BackgammonBoardWidget> with TickerProviderStateMixin {
  late final BackgammonAI _ai; // Add AI instance
  bool _isAiThinking = false; // Flag to block UI during AI turn

  // Checker movement animation variables
  late AnimationController _moveAnimationController;
  late Animation<Offset> _moveAnimation;
  int? _animatingFrom;
  int? _animatingTo;
  Color? _animatingColor;
  bool _isAnimating = false;

  // Dice roll animation variables
  late AnimationController _diceAnimationController;
  late Animation<double> _diceRotation;
  late Animation<double> _diceScale;
  bool _isDiceAnimating = false;

  // Hint system variables
  bool _isLoadingHint = false;
  String? _currentHintText;
  List<BackgammonMove>? _hintMoves;

  @override
  void initState() {
    super.initState();

    // Initialize checker movement animation
    _moveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _moveAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _moveAnimationController, curve: Curves.easeInOut),
    );

    // Initialize dice roll animation
    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _diceRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _diceAnimationController, curve: Curves.easeOut),
    );

    _diceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(_diceAnimationController);

    if (widget.gameMode == GameMode.pve) {
      _ai = BackgammonAI();
      if (!widget.game.isWhiteTurn && widget.game.dice.isEmpty) {
         WidgetsBinding.instance.addPostFrameCallback((_) => _triggerAiRoll());
      }
    }
  }

  @override
  void dispose() {
    _moveAnimationController.dispose();
    _diceAnimationController.dispose();
    super.dispose();
  }

  void _handlePointTap(int index) {
    if (_isAiThinking || widget.game.winner != null) return;
    if (widget.gameMode == GameMode.pve && !widget.game.isWhiteTurn) return;

    int currentBarIndex = widget.game.isWhiteTurn ? backgammon.BackgammonLogic.whiteBarIndex : backgammon.BackgammonLogic.blackBarIndex;
    int currentHomeIndex = widget.game.isWhiteTurn ? backgammon.BackgammonLogic.whiteHomeIndex : backgammon.BackgammonLogic.blackHomeIndex;
    bool canInteractWithoutDice = (widget.game.selectedPointIndex == currentBarIndex && index >= 0 && index < 24) ||
                                 (index == currentHomeIndex && widget.game.selectedPointIndex != null && widget.game.selectedPointIndex! < 24);

    if (widget.game.dice.isEmpty && widget.game.selectedPointIndex == null && !canInteractWithoutDice) return;

    bool turnWillChange = false;

    setState(() { // Perform selection or move attempt
      Color? tappedColor = (index >= 0 && index < widget.game.points.length) ? widget.game.points[index].color : null;
      Color currentTurnColor = widget.game.isWhiteTurn ? Colors.white : Colors.black;

      if (widget.game.selectedPointIndex == null) {
        // Try to select a point or bar
        if (((index >= 0 && index < 24 && tappedColor == currentTurnColor && widget.game.points[index].count > 0) ||
            (index == currentBarIndex && widget.game.points[index].count > 0)) && widget.game.dice.isNotEmpty )
         {
               widget.game.selectedPointIndex = index;
         }
      } else {
        // Try to move
         bool turnBeforeMove = widget.game.isWhiteTurn;
         bool moveMade = widget.game.tryMakeMove(widget.game.selectedPointIndex!, index);

         if (moveMade) {
             widget.onMove?.call(); // Notify GameScreen
             widget.game.selectedPointIndex = null; // Deselect after successful move

             if (widget.game.winner != null && widget.onGameEnd != null) {
                  widget.onGameEnd!(widget.game.winner!);
                  return; // Exit early if game ended
             }
             // Check if turn should change based on remaining moves
             List<int> remainingDice = widget.game.getRemainingDice();
             bool stillHasMoves = remainingDice.isNotEmpty && widget.game.canMakeAnyMoveWithDice(remainingDice);

             if (!stillHasMoves) { // No more moves possible this turn
                 print("_handlePointTap: No more moves detected. Turn should change.");
                 if(widget.game.isWhiteTurn == turnBeforeMove){ // If logic didn't change turn, force it
                    widget.game.isWhiteTurn = !widget.game.isWhiteTurn;
                    // widget.game.selectedPointIndex = null; // Already deselected
                    widget.game.dice.clear();
                    widget.game.usedDice.clear();
                 } else {
                     // Logic already changed turn, ensure deselection if needed (already done)
                 }
                 turnWillChange = true;
             }
             // else: turn continues, selectedPointIndex was cleared

         } else { // Move failed
            // Try selecting another piece
            if (((index >= 0 && index < 24 && tappedColor == currentTurnColor && widget.game.points[index].count > 0) ||
                (index == currentBarIndex && widget.game.points[index].count > 0)) && widget.game.dice.isNotEmpty) {
                widget.game.selectedPointIndex = index;
            } else {
                widget.game.selectedPointIndex = null; // Deselect
            }
         }
      }
    }); // End setState

    // Trigger next action after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.game.winner != null) return;
      if (turnWillChange) {
          print("_handlePointTap: Turn will change. Triggering next roll/AI.");
          if (widget.gameMode == GameMode.pve && !widget.game.isWhiteTurn) {
              _triggerAiRoll(); // AI's turn
          } else {
              _autoRollAfterTurnChange(); // Next player's turn (Human or PvP)
          }
      }
      // Check again if player has run out of moves after a partial move
      else if (!turnWillChange && widget.game.dice.isNotEmpty && widget.game.selectedPointIndex == null) {
            List<int> availableDice = widget.game.getRemainingDice();
            if (availableDice.isNotEmpty && !widget.game.canMakeAnyMoveWithDice(availableDice)) {
                 if (mounted) {
                   setState(() { // Use setState to clear dice visually
                     print("Player has no more moves with remaining dice. Passing turn.");
                     widget.game.isWhiteTurn = !widget.game.isWhiteTurn;
                     widget.game.dice.clear();
                     widget.game.usedDice.clear();
                   });
                   // Schedule the next action (roll) after this state update
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted || widget.game.winner != null) return;
                        if (widget.gameMode == GameMode.pve && !widget.game.isWhiteTurn) {
                          _triggerAiRoll();
                        } else {
                          _autoRollAfterTurnChange();
                        }
                    });
                 }
            }
       }
    });
  }

  // Animate dice roll
  Future<void> _animateDiceRoll() async {
    setState(() {
      _isDiceAnimating = true;
    });

    _diceAnimationController.reset();
    await _diceAnimationController.forward();

    setState(() {
      _isDiceAnimating = false;
    });
  }

  // Animate checker movement
  Future<void> _animateCheckerMove(int from, int to, Color checkerColor) async {
    if (!mounted) return;

    setState(() {
      _isAnimating = true;
      _animatingFrom = from;
      _animatingTo = to;
      _animatingColor = checkerColor;
    });

    // Calculate movement animation - this is simplified, real implementation would need proper positioning
    _moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset((to - from).toDouble() * 0.5, 0),
    ).animate(CurvedAnimation(
      parent: _moveAnimationController,
      curve: Curves.easeInOut,
    ));

    _moveAnimationController.reset();
    await _moveAnimationController.forward();

    if (!mounted) return;

    setState(() {
      _isAnimating = false;
      _animatingFrom = null;
      _animatingTo = null;
      _animatingColor = null;
    });
  }

  // Rolls dice for the next player
  void _autoRollAfterTurnChange() async {
      if (!mounted || widget.game.winner != null || widget.game.dice.isNotEmpty) return;
      bool isNowAITurn = widget.gameMode == GameMode.pve && !widget.game.isWhiteTurn;

      Future.delayed(Duration(milliseconds: isNowAITurn ? 50 : 350), () async {
        if (mounted && widget.game.dice.isEmpty && widget.game.winner == null) {
           bool turnBeforeRoll = widget.game.isWhiteTurn;

           // Animate dice roll first
           await _animateDiceRoll();

           if (!mounted) return;

           setState(() {
             print("Auto-rolling for ${widget.game.isWhiteTurn ? 'White' : 'Black'}");
             widget.game.rollDice();
           });

           // Check immediately if the roll resulted in no moves possible
           if (widget.game.isWhiteTurn != turnBeforeRoll) { // rollDice detected no moves and passed turn
               print("Auto-roll resulted in immediate turn pass.");
               WidgetsBinding.instance.addPostFrameCallback((_) => _autoRollAfterTurnChange()); // Roll for the *next* player
           } else if (isNowAITurn && widget.game.dice.isNotEmpty) {
               WidgetsBinding.instance.addPostFrameCallback((_) => _triggerAiMove()); // Trigger AI if it was their turn to roll
           }
        }
      });
  }

  // Triggers the AI to roll dice
  void _triggerAiRoll() async {
      if (!mounted || widget.game.winner != null || widget.game.isWhiteTurn || widget.game.dice.isNotEmpty) return;
      if (_isAiThinking) return;

      print("Triggering AI roll...");
      setState(() { _isAiThinking = true; }); // Block UI

      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted && widget.game.dice.isEmpty && !widget.game.isWhiteTurn) {
         bool turnBeforeRoll = widget.game.isWhiteTurn;

         // Animate dice roll first
         await _animateDiceRoll();

         if (!mounted) return;

         setState(() { // Roll within setState
           widget.game.rollDice();
           print("AI rolled: ${widget.game.dice}");
         });

         if (widget.game.isWhiteTurn != turnBeforeRoll) { // Turn passed back to white
            print("AI has no moves after rolling. Passing turn.");
             setState(() { _isAiThinking = false; }); // Unblock UI
             // Schedule roll for white after build
             WidgetsBinding.instance.addPostFrameCallback((_){ if(mounted) _autoRollAfterTurnChange(); });
         } else if (widget.game.dice.isNotEmpty){
            // Schedule AI move after build
             WidgetsBinding.instance.addPostFrameCallback((_){ if(mounted) _triggerAiMove(); });
         } else {
             // Should not happen, but unblock UI just in case
             if(mounted) setState(() { _isAiThinking = false; });
         }
      } else {
           // If dice somehow appeared, or turn changed, just unblock
           if(mounted) setState(() { _isAiThinking = false; });
      }
  }

  // Triggers the AI to calculate and make ALL its moves for the current roll
  void _triggerAiMove() async {
       if (!mounted || widget.game.winner != null || widget.game.isWhiteTurn) {
           if(mounted && _isAiThinking) setState(() { _isAiThinking = false; });
           return;
       }
       if (widget.game.dice.isEmpty) {
            print("AI Trigger requested but no dice available. Rolling...");
            if(mounted && _isAiThinking) setState(() { _isAiThinking = false; });
            _triggerAiRoll();
            return;
       }
       if (!_isAiThinking) setState(() { _isAiThinking = true; });

       print("AI thinking cycle START. Dice Roll: ${widget.game.dice}, Current Used: ${widget.game.usedDice}");

      List<int> currentAvailableDice = widget.game.getRemainingDice(); // Get initially available dice

      while(_isAiThinking && !widget.game.isWhiteTurn && widget.game.winner == null && currentAvailableDice.isNotEmpty) {
          print("AI loop: Checking moves. Available dice for this step: $currentAvailableDice");

          if (!widget.game.canMakeAnyMoveWithDice(currentAvailableDice)) {
               print("AI loop: No valid moves left with remaining dice. Breaking loop.");
               break;
          }

          await Future.delayed(const Duration(milliseconds: 700));
          if (!mounted || widget.game.winner != null || widget.game.isWhiteTurn) break;

          // Pass the current available dice to the AI for its decision
          BackgammonMove? move = _ai.findMoveSequence(widget.game).isNotEmpty ? _ai.findMoveSequence(widget.game)[0] : null; // simplified for fix


          if (move != null) {
              print("AI loop: Found move: ${move.from} to ${move.to} with die ${move.die}. Executing...");
              bool turnBeforeAIMove = widget.game.isWhiteTurn;

              // Get checker color before making move
              Color? checkerColor;
              if (move.from >= 0 && move.from < widget.game.points.length) {
                checkerColor = widget.game.points[move.from].color;
              }

              // Animate the move
              if (checkerColor != null) {
                await _animateCheckerMove(move.from, move.to, checkerColor);
              }

              if (!mounted) return;

              setState(() {
                  widget.game.tryMakeMove(move.from, move.to);
                  widget.onMove?.call();
              });

               if (widget.game.winner != null && widget.onGameEnd != null) {
                    widget.onGameEnd!(widget.game.winner!);
                    if (mounted) setState(() { _isAiThinking = false; });
                    return;
               }

               currentAvailableDice = widget.game.getRemainingDice(); // Recalculate AFTER move
               print("AI loop: Move executed. LOCAL Remaining Dice for next step: $currentAvailableDice");

               if (widget.game.isWhiteTurn != turnBeforeAIMove) {
                   print("AI loop: Turn changed during move execution. Breaking loop.");
                   break;
               }

               await Future.delayed(const Duration(milliseconds: 50));
               if (!mounted) return;

          } else {
               print("AI loop ERROR: findMoveSequence returned empty despite canMakeAnyMove being true. Breaking loop.");
               break;
          }
      } // End of while loop

       if (mounted && widget.game.winner == null) {
            print("AI thinking cycle END.");
            if (!widget.game.isWhiteTurn) {
                print("AI loop finished. Forcing turn change to White.");
                 setState(() {
                     widget.game.isWhiteTurn = true;
                     widget.game.selectedPointIndex = null;
                     widget.game.dice.clear();
                     widget.game.usedDice.clear();
                     _isAiThinking = false;
                 });
                _autoRollAfterTurnChange();
            } else {
                 if (_isAiThinking) setState(() { _isAiThinking = false; });
            }
       } else if (mounted) {
           if (_isAiThinking) setState(() { _isAiThinking = false; });
       }
  } // End _triggerAiMove

  List<Widget> _buildHintWidgets() {
    List<Widget> widgets = [];

    if (HintSystem.isTrainingModeEnabled() && _isPlayerTurn()) {
      widgets.add(
        Positioned(
          bottom: 10,
          right: 10,
          child: HintSystem.buildHintButton(
            onPressed: _requestHint,
            isLoading: _isLoadingHint,
          ),
        ),
      );
    }

    if (HintSystem.isTrainingModeEnabled() && _currentHintText != null) {
      widgets.add(
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
      );
    }

    return widgets;
  }

  bool _isPlayerTurn() {
    if (widget.gameMode == GameMode.pvp) return true;
    // В режиме PvE игрок всегда играет за белых
    return widget.game.isWhiteTurn;
  }

  Future<void> _requestHint() async {
    if (_isLoadingHint || !HintSystem.isTrainingModeEnabled()) return;
    if (_isAiThinking || _isAnimating || _isDiceAnimating) return;

    // Нужны кости чтобы дать подсказку
    if (widget.game.dice.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сначала бросьте кости!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingHint = true;
      _currentHintText = null;
      _hintMoves = null;
    });

    try {
      // Используем тот же AI что и для PvE режима
      final ai = widget.gameMode == GameMode.pve ? _ai : BackgammonAI();

      final moves = ai.findMoveSequence(widget.game);

      if (moves.isNotEmpty && mounted) {
        final firstMove = moves[0];

        setState(() {
          _hintMoves = moves;
        });

        // Формируем объяснение
        String explanation = 'AI рекомендует последовательность ходов:\n';
        for (int i = 0; i < moves.length; i++) {
          final move = moves[i];
          String fromStr = move.from == backgammon.BackgammonLogic.whiteBarIndex
              ? 'бар'
              : (move.from == backgammon.BackgammonLogic.blackBarIndex
                  ? 'бар'
                  : '${move.from + 1}');
          String toStr = move.to == backgammon.BackgammonLogic.whiteHomeIndex
              ? 'дом'
              : (move.to == backgammon.BackgammonLogic.blackHomeIndex
                  ? 'дом'
                  : '${move.to + 1}');
          explanation += '${i + 1}. $fromStr → $toStr (кость: ${move.die})\n';
        }

        setState(() {
          _currentHintText = explanation.trim();
        });

        HintSystem.showHint(
          context,
          title: 'Рекомендация AI',
          explanation: explanation.trim(),
          moveSuggestion: 'Первый ход: ${firstMove.from == backgammon.BackgammonLogic.whiteBarIndex ? "бар" : "${firstMove.from + 1}"} → ${firstMove.to == backgammon.BackgammonLogic.whiteHomeIndex ? "дом" : "${firstMove.to + 1}"}',
          onApplyHint: () async {
            // Выполняем все ходы последовательно
            for (final move in moves) {
              if (!mounted) break;

              // Получаем цвет шашки
              Color? checkerColor;
              if (move.from >= 0 && move.from < widget.game.points.length) {
                checkerColor = widget.game.points[move.from].color;
              } else if (move.from == backgammon.BackgammonLogic.whiteBarIndex) {
                checkerColor = Colors.white;
              } else if (move.from == backgammon.BackgammonLogic.blackBarIndex) {
                checkerColor = Colors.black;
              }

              // Анимируем ход
              if (checkerColor != null) {
                await _animateCheckerMove(move.from, move.to, checkerColor);
              }

              if (!mounted) break;

              // Выполняем ход
              setState(() {
                widget.game.tryMakeMove(move.from, move.to);
                widget.onMove?.call();
              });

              await Future.delayed(const Duration(milliseconds: 300));
            }

            if (mounted) {
              setState(() {
                _hintMoves = null;
                _currentHintText = null;
              });
            }

            // Проверяем победу
            if (widget.game.winner != null && widget.onGameEnd != null) {
              widget.onGameEnd!(widget.game.winner!);
            }
          },
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет доступных ходов'),
            duration: Duration(seconds: 2),
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 750;
    final boardWidth = min(screenWidth * (isWideScreen ? 0.8 : 0.95), 800.0);
    final boardHeight = boardWidth * 0.8;
    final pointWidth = boardWidth / 15.6; // Keep the overflow fix
    final checkerSize = pointWidth * 0.8;
    final barWidth = pointWidth * 1.2;
    final homeWidth = pointWidth * 1.8;

    final List<Widget> stackChildren = [
      Container(
        width: boardWidth,
        height: boardHeight,
        padding: EdgeInsets.all(pointWidth * 0.15),
        decoration: BoxDecoration(
        // Реалистичная деревянная рамка с градиентом
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5D4E37),  // Темный орех
            Color(0xFF6B5D47),
            Color(0xFF7A6A4F),
            Color(0xFF6B5D47),
            Color(0xFF5D4E37),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        border: Border.all(color: const Color(0xFF3D2E1F), width: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: 16,
            spreadRadius: 3,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AbsorbPointer( // Wrap content to disable taps when AI is thinking
        absorbing: _isAiThinking,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                    // Disable button if AI is thinking or not player's turn in PvE or animation is running
                    onPressed: (widget.game.dice.isEmpty && widget.game.winner == null && (widget.game.isWhiteTurn || widget.gameMode == GameMode.pvp) && !_isAiThinking && !_isDiceAnimating)
                        ? () async {
                            await _animateDiceRoll();
                            if (mounted) {
                              setState(() { widget.game.rollDice(); });
                            }
                          }
                        : null,
                    child: const Text('Бросить кубики'),
                  ),
                  const SizedBox(width: 10),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildDiceWidgets(checkerSize * 0.8)
                  ),
                   // Optional: Loading indicator when AI is thinking
                  if (_isAiThinking) Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54,)),
                    ) else SizedBox(width: 30) // Placeholder to prevent layout shift
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildHalfBoard(0, 11, pointWidth, checkerSize, true),
                  _buildBar(barWidth, checkerSize * 0.9, boardHeight * 0.9), // Pass boardHeight for bar calc
                  _buildHalfBoard(12, 23, pointWidth, checkerSize, false),
                  GestureDetector(
                      onTap: () {
                          int homeIndex = widget.game.isWhiteTurn ? backgammon.BackgammonLogic.whiteHomeIndex : backgammon.BackgammonLogic.blackHomeIndex;
                          _handlePointTap(homeIndex);
                      },
                      child: _buildHomeArea(homeWidth, checkerSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    ];

    stackChildren.addAll(_buildHintWidgets());

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        children: stackChildren,
      ),
    );
  }

  List<Widget> _buildDiceWidgets(double size) {
     List<Widget> diceWidgets = [];
     Map<int, int> diceCounts = {};
     Map<int, int> usedCounts = {};

     for (int die in widget.game.dice) { diceCounts[die] = (diceCounts[die] ?? 0) + 1; }
     for (int used in widget.game.usedDice) { usedCounts[used] = (usedCounts[used] ?? 0) + 1; }

     // Display based on original roll order for consistency
     List<int> originalDiceOrder = widget.game.dice;
     Map<int, int> currentlyUsedCount = {}; // Track usage within this build

     for(int dieValue in originalDiceOrder) {
         int totalUsedForValue = usedCounts[dieValue] ?? 0;
         int alreadyShownAsUsed = currentlyUsedCount[dieValue] ?? 0;
         bool showAsUsed = alreadyShownAsUsed < totalUsedForValue;

         diceWidgets.add(_buildDie(dieValue, size, showAsUsed));

         if(showAsUsed) {
             currentlyUsedCount[dieValue] = alreadyShownAsUsed + 1;
         }
     }

     if (widget.game.dice.isEmpty && widget.game.winner == null) {
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


  Widget _buildHalfBoard(int startPoint, int endPoint, double pointWidth, double checkerSize, bool isLeftHalf) {
     return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(6, (i) {
                int pointIndex = isLeftHalf ? endPoint - i : startPoint + i;
                return Expanded(
                  child: _buildPoint(pointIndex, pointWidth, checkerSize, true),
                );
              }),
            ),
          ),
          Expanded(
            child: Row(
               crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(6, (i) {
                int pointIndex = isLeftHalf ? startPoint + i : endPoint - i;
                return Expanded(
                  child: _buildPoint(pointIndex, pointWidth, checkerSize, false),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoint(int index, double width, double checkerSize, bool isTopRow) {
    backgammon.PointState point = widget.game.points[index];
    // Реалистичные цвета для точек - светлое и темное дерево
    bool isLightPoint = index % 2 == 0;
    List<Color> pointGradient = isLightPoint
      ? [const Color(0xFFEECEA0), const Color(0xFFD2B48C), const Color(0xFFC4A876)]
      : [const Color(0xFF8B5A2B), const Color(0xFF6B4423), const Color(0xFF5A3618)];
    bool isSelected = widget.game.selectedPointIndex == index;
    bool isPossibleDest = false;

    // Note: width parameter is ignored since this widget is now wrapped in Expanded
    if (widget.game.selectedPointIndex != null) {
        int from = widget.game.selectedPointIndex!;
        List<int> availableDice = widget.game.getRemainingDice();

        for(int die in availableDice){
             int targetIndexCalc = -1;
             int homeIndex = widget.game.isWhiteTurn ? backgammon.BackgammonLogic.whiteHomeIndex : backgammon.BackgammonLogic.blackHomeIndex;

             if(widget.game.isWhiteTurn){
                 targetIndexCalc = (from == backgammon.BackgammonLogic.whiteBarIndex) ? (die - 1) : (from + die);
                 if (index == homeIndex && targetIndexCalc >= 24 && widget.game.canBearOff(Colors.white)) { // Check bear off *to home*
                    if(widget.game.isValidMove(from, homeIndex, die)) isPossibleDest = true;
                 }
             } else {
                 targetIndexCalc = (from == backgammon.BackgammonLogic.blackBarIndex) ? (24 - die) : (from - die);
                 if (index == homeIndex && targetIndexCalc < 0 && widget.game.canBearOff(Colors.black)) { // Check bear off *to home*
                     if(widget.game.isValidMove(from, homeIndex, die)) isPossibleDest = true;
                 }
             }
             // Check regular move *to this point*
             if(targetIndexCalc == index && index < 24 && widget.game.isValidMove(from, index, die)){
                  isPossibleDest = true;
             }
             if(isPossibleDest) break; // Found a valid move to this point
        }
    }


    return GestureDetector(
      onTap: () => _handlePointTap(index),
      child: Container(
        decoration: BoxDecoration(
          // Реалистичный градиент для точек
          gradient: LinearGradient(
            begin: isTopRow ? Alignment.topCenter : Alignment.bottomCenter,
            end: isTopRow ? Alignment.bottomCenter : Alignment.topCenter,
            colors: pointGradient,
          ),
          border: Border.symmetric(
            vertical: BorderSide(
              color: isLightPoint
                ? const Color(0xFFD7BE9E).withAlpha(80)
                : const Color(0xFF4A3618).withAlpha(100),
              width: 1.5,
            ),
          ),
          boxShadow: isSelected
                     ? [ BoxShadow(color: Colors.blueAccent.withAlpha(150), spreadRadius: 3, blurRadius: 4)]
                     : isPossibleDest
                       ? [ BoxShadow(color: Colors.greenAccent.withAlpha(130), spreadRadius: 2, blurRadius: 3) ]
                       : [
                           BoxShadow(
                             color: Colors.black.withAlpha(20),
                             blurRadius: 2,
                             offset: const Offset(0, 1),
                           ),
                         ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double effectiveCheckerHeight = checkerSize * 0.7;
            int maxVisibleCheckers = (constraints.maxHeight / effectiveCheckerHeight).floor();
             maxVisibleCheckers = max(1, maxVisibleCheckers > 0 ? maxVisibleCheckers : 1 );
            int displayedCount = min(point.count, maxVisibleCheckers);

            return Stack(
              alignment: isTopRow ? Alignment.topCenter : Alignment.bottomCenter,
              children: [
                 ...List.generate(displayedCount, (i) {
                  double offset = i * effectiveCheckerHeight;
                  return Positioned(
                    top: isTopRow ? offset : null,
                    bottom: !isTopRow ? offset : null,
                    left: (constraints.maxWidth - checkerSize) / 2,
                    child: _buildChecker(point.color ?? Colors.transparent, checkerSize),
                  );
                }),
                if (point.count > maxVisibleCheckers)
                 Positioned(
                     top: isTopRow ? (maxVisibleCheckers - 0.7) * effectiveCheckerHeight : null,
                     bottom: !isTopRow ? (maxVisibleCheckers - 0.7) * effectiveCheckerHeight : null,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                           color: Colors.black.withOpacity(0.7),
                           borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(
                          point.count.toString(),
                           style: TextStyle(color: Colors.white, fontSize: checkerSize * 0.5, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ),
              ]
            );
          },
        ),
      ),
    );
  }

  // Pass barHeight down
  Widget _buildBar(double width, double checkerSize, double barHeight) {
    backgammon.PointState whiteBar = widget.game.points[backgammon.BackgammonLogic.whiteBarIndex];
    backgammon.PointState blackBar = widget.game.points[backgammon.BackgammonLogic.blackBarIndex];
    bool isWhiteSelected = widget.game.selectedPointIndex == backgammon.BackgammonLogic.whiteBarIndex;
    bool isBlackSelected = widget.game.selectedPointIndex == backgammon.BackgammonLogic.blackBarIndex;

    return Container(
      width: width,
      height: barHeight, // Use passed height
      decoration: BoxDecoration(
         color: const Color(0xFF53350A).withOpacity(0.8),
         border: (isWhiteSelected || isBlackSelected)
                  ? Border.all(color: Colors.blueAccent, width: 3)
                  : Border.symmetric(vertical: BorderSide(color: Colors.black.withOpacity(0.5)))
      ),
      child: Column(
        children: [
           Expanded( // Use Expanded
             child: GestureDetector(
               behavior: HitTestBehavior.opaque,
               onTap: () => _handlePointTap(backgammon.BackgammonLogic.whiteBarIndex),
               child: Container(
                color: Colors.transparent,
                width: double.infinity,
                alignment: Alignment.center,
                 child: Column(
                     mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                     mainAxisSize: MainAxisSize.min,
                     children: List.generate(whiteBar.count, (i) => Padding(padding: const EdgeInsets.symmetric(vertical: 1.0), child: _buildChecker(Colors.white, checkerSize)))
                 ),
               ),
             ),
           ),
           // Divider
           Container(height: barHeight * 0.02, color: Colors.black.withOpacity(0.3)), // Adjusted divider height
           Expanded( // Use Expanded
            child: GestureDetector(
               behavior: HitTestBehavior.opaque,
               onTap: () => _handlePointTap(backgammon.BackgammonLogic.blackBarIndex),
               child: Container(
                 color: Colors.transparent,
                 width: double.infinity,
                 alignment: Alignment.center,
                 child: Column(
                     mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                     mainAxisSize: MainAxisSize.min,
                     children: List.generate(blackBar.count, (i) => Padding(padding: const EdgeInsets.symmetric(vertical: 1.0), child: _buildChecker(Colors.black, checkerSize)))
                 ),
               ),
            ),
          ),
        ],
      ),
    );
  }


   Widget _buildHomeArea(double width, double checkerSize) {
     int whiteHomeCount = widget.game.points[backgammon.BackgammonLogic.whiteHomeIndex].count;
     int blackHomeCount = widget.game.points[backgammon.BackgammonLogic.blackHomeIndex].count;
      bool isWhiteTarget = false;
      bool isBlackTarget = false;

      if (widget.game.selectedPointIndex != null && widget.game.selectedPointIndex! < 24 && widget.game.canBearOff(widget.game.isWhiteTurn ? Colors.white : Colors.black)){
          int homeIndex = widget.game.isWhiteTurn ? backgammon.BackgammonLogic.whiteHomeIndex : backgammon.BackgammonLogic.blackHomeIndex;
          List<int> availableDice = widget.game.getRemainingDice();

          for(int die in availableDice){
               if(widget.game.isValidMove(widget.game.selectedPointIndex!, homeIndex, die)){
                   if(widget.game.isWhiteTurn) isWhiteTarget = true;
                   else isBlackTarget = true;
                   break;
               }
          }
      }

     return Container(
       width: width,
       margin: const EdgeInsets.only(left: 4),
       decoration: BoxDecoration(
         color: Colors.black.withOpacity(0.1),
         border: Border(left: BorderSide(color: Colors.black54.withOpacity(0.5), width: 2)),
         borderRadius: BorderRadius.horizontal(right: Radius.circular(5))
       ),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           _buildHomeStack(Colors.white, whiteHomeCount, checkerSize * 1.2, isWhiteTarget),
           _buildHomeStack(Colors.black, blackHomeCount, checkerSize * 1.2, isBlackTarget),
         ],
       ),
     );
   }

   Widget _buildHomeStack(Color color, int count, double size, bool isTarget) {
     return Expanded(
       child: Container(
         width: double.infinity,
         decoration: BoxDecoration(
             color: isTarget ? Colors.greenAccent.withOpacity(0.3) : Colors.transparent,
             borderRadius: BorderRadius.circular(5)
         ),
         alignment: Alignment.center,
         child: Text(
           count.toString(),
           style: TextStyle(
             fontSize: size * 1.2,
             fontWeight: FontWeight.bold,
             color: color == Colors.white ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.7),
              shadows: [Shadow(color: Colors.black26, blurRadius: 1)]
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
        // Реалистичный пластиковый/деревянный вид фишек
        gradient: RadialGradient(
            colors: isWhite
                ? [
                    const Color(0xFFFAFAFA),  // Светлый центр
                    const Color(0xFFEEEEEE),
                    const Color(0xFFDDDDDD),  // Темнее по краям
                  ]
                : [
                    const Color(0xFF3A3A3A),  // Светлее в центре для бликов
                    const Color(0xFF2A2A2A),
                    const Color(0xFF1A1A1A),  // Темный край
                  ],
            center: const Alignment(-0.3, -0.3),
            radius: 0.85
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isWhite ? const Color(0xFFCCCCCC) : const Color(0xFF0A0A0A),
          width: size * 0.04,
        ),
        boxShadow: [
          // Основная тень от фишки
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: size * 0.15,
            offset: Offset(size * 0.05, size * 0.08),
          ),
          // Внутренняя тень для глубины
          BoxShadow(
            color: isWhite
              ? Colors.black.withAlpha(30)
              : Colors.black.withAlpha(70),
            blurRadius: size * 0.08,
            spreadRadius: -size * 0.03,
          ),
          // Блик сверху для объема
          BoxShadow(
            color: Colors.white.withAlpha(isWhite ? 50 : 25),
            blurRadius: size * 0.12,
            offset: Offset(-size * 0.04, -size * 0.04),
            spreadRadius: -size * 0.08,
          ),
        ],
      ),
    );
  }

 Widget _buildDie(int value, double size, bool used) {
   Widget dieWidget = Container(
     width: size,
     height: size,
     margin: const EdgeInsets.symmetric(horizontal: 4),
     decoration: BoxDecoration(
       // Реалистичный вид кубиков с градиентом
       gradient: used
         ? LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Colors.grey.shade600.withAlpha(180),
               Colors.grey.shade500.withAlpha(160),
               Colors.grey.shade600.withAlpha(180),
             ],
           )
         : const LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Color(0xFFFFFFFF),
               Color(0xFFF5F5F5),
               Color(0xFFEEEEEE),
             ],
           ),
       borderRadius: BorderRadius.circular(size * 0.18),
       border: Border.all(
         color: used ? Colors.grey.shade700.withAlpha(100) : Colors.black.withAlpha(150),
         width: size * 0.03,
       ),
       boxShadow: used
         ? [
             BoxShadow(
               color: Colors.black.withAlpha(50),
               blurRadius: size * 0.08,
               offset: Offset(size * 0.02, size * 0.02),
             ),
           ]
         : [
             BoxShadow(
               color: Colors.black.withAlpha(80),
               blurRadius: size * 0.15,
               offset: Offset(size * 0.05, size * 0.05),
             ),
             BoxShadow(
               color: Colors.black.withAlpha(40),
               blurRadius: size * 0.08,
               spreadRadius: -size * 0.02,
             ),
           ],
     ),
     child: Center(
       child: Text(
         value.toString(),
         style: TextStyle(
           fontSize: size * 0.65,
           fontWeight: FontWeight.w900,
           color: used ? Colors.white.withAlpha(150) : Colors.black87,
           shadows: used
             ? []
             : [
                 Shadow(
                   color: Colors.black.withAlpha(30),
                   blurRadius: 1,
                   offset: const Offset(0, 1),
                 ),
               ],
         ),
       ),
     ),
   );

   // Add animation if dice are being rolled
   if (_isDiceAnimating) {
     return AnimatedBuilder(
       animation: _diceAnimationController,
       builder: (context, child) {
         return Transform.scale(
           scale: _diceScale.value,
           child: Transform.rotate(
             angle: _diceRotation.value,
             child: child,
           ),
         );
       },
       child: dieWidget,
     );
   }

   return dieWidget;
 }
} // End of _BackgammonBoardWidgetState