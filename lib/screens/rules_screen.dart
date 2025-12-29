import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/rule_example_container.dart';
import '../widgets/checkers_rule_example.dart';
import '../widgets/togyz_rule_example.dart';
import '../widgets/chess_rule_example.dart';
import '../widgets/backgammon_rule_example.dart';
import '../games/backgammon_logic.dart' as backgammon; // Import for PointState
import 'package:chess/chess.dart' as chess; // Import for Color

// Constant for initial chess position (FEN)
const String initialChessFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

class RulesScreen extends StatelessWidget {
  final String gameKey;
  const RulesScreen({Key? key, required this.gameKey}) : super(key: key);

  // Helper for Checkers initial setup
  List<List<ExamplePiece?>> _getCheckersInitialSetup() {
    List<List<ExamplePiece?>> board = List.generate(
      8,
      (_) => List.generate(8, (_) => null),
    );
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 != 0) {
          // Dark squares only
          if (row < 3)
            board[row][col] = ExamplePiece(Colors.black);
          else if (row > 4)
            board[row][col] = ExamplePiece(Colors.white);
        }
      }
    }
    return board;
  }

  // Helper for Backgammon initial setup
  List<backgammon.PointState> _getBackgammonInitialSetup() {
    List<backgammon.PointState> points = List.generate(
      28,
      (_) => backgammon.PointState(),
    );
    points[0] = backgammon.PointState(count: 2, color: Colors.white);
    points[11] = backgammon.PointState(count: 5, color: Colors.white);
    points[16] = backgammon.PointState(count: 3, color: Colors.white);
    points[18] = backgammon.PointState(count: 5, color: Colors.white);
    points[5] = backgammon.PointState(count: 5, color: Colors.black);
    points[7] = backgammon.PointState(count: 3, color: Colors.black);
    points[12] = backgammon.PointState(count: 5, color: Colors.black);
    points[23] = backgammon.PointState(count: 2, color: Colors.black);
    return points;
  }

  List<Widget> _getRulesContent(BuildContext context, String game) {
    switch (game) {
      case 'checkers':
        return [
          _buildHeader(AppLocalizations.get('checkersBasicRules')),
          _buildText(AppLocalizations.get('checkersGoal')),

          RuleExampleContainer(
            title: AppLocalizations.get('checkersInitialSetup'),
            example: CheckersRuleExample(
              initialBoardState: _getCheckersInitialSetup(),
              animationSteps: [],
            ),
            description: AppLocalizations.get('checkersInitialDesc'),
          ),

          _buildHeader(AppLocalizations.get('checkersMovesHeader')),
          _buildText(AppLocalizations.get('checkersMove1')),
          _buildText(AppLocalizations.get('checkersMove2')),

          RuleExampleContainer(
            title: AppLocalizations.get('checkersSimpleMoveTitle'),
            example: CheckersRuleExample(
              initialBoardState: [
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [
                  null,
                  null,
                  ExamplePiece(Colors.white),
                  null,
                  null,
                  null,
                  null,
                  null,
                ], // c4
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(fromRow: 3, fromCol: 2, toRow: 4, toCol: 3),
              ],
              size: 150,
            ),
            description: AppLocalizations.get('checkersSimpleMoveDesc'),
          ),

          _buildHeader(AppLocalizations.get('checkersCaptureHeader')),
          _buildText(AppLocalizations.get('checkersCapture1')),
          _buildText(AppLocalizations.get('checkersCapture2')),
          _buildText(AppLocalizations.get('checkersCapture3')),

          RuleExampleContainer(
            title: AppLocalizations.get('checkersCaptureExampleTitle'),
            example: CheckersRuleExample(
              initialBoardState: [
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [
                  null,
                  null,
                  ExamplePiece(Colors.white),
                  null,
                  null,
                  null,
                  null,
                  null,
                ], // c3
                [
                  null,
                  null,
                  null,
                  ExamplePiece(Colors.black),
                  null,
                  null,
                  null,
                  null,
                ], // d4
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(
                  fromRow: 2,
                  fromCol: 2,
                  toRow: 4,
                  toCol: 4,
                  captureRow: 3,
                  captureCol: 3,
                ),
              ],
              size: 150,
            ),
            description: AppLocalizations.get('checkersCaptureExampleDesc'),
          ),

          RuleExampleContainer(
            title: AppLocalizations.get('checkersMultiCaptureTitle'),
            example: CheckersRuleExample(
              initialBoardState: [
                [null, null, null, null, null, null, null, null],
                [
                  null,
                  ExamplePiece(Colors.white),
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                ], // b2
                [
                  null,
                  null,
                  ExamplePiece(Colors.black),
                  null,
                  null,
                  null,
                  null,
                  null,
                ], // c3
                [
                  null,
                  null,
                  null,
                  null,
                  ExamplePiece(Colors.black),
                  null,
                  null,
                  null,
                ], // e4
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(
                  fromRow: 1,
                  fromCol: 1,
                  toRow: 3,
                  toCol: 3,
                  captureRow: 2,
                  captureCol: 2,
                ),
                AnimationStep(
                  fromRow: 3,
                  fromCol: 3,
                  toRow: 5,
                  toCol: 5,
                  captureRow: 4,
                  captureCol: 4,
                ),
              ],
              size: 150,
            ),
            description: AppLocalizations.get('checkersMultiCaptureDesc'),
          ),

          _buildHeader(AppLocalizations.get('checkersKingHeader')),
          _buildText(AppLocalizations.get('checkersKing1')),
          _buildText(AppLocalizations.get('checkersKing2')),

          RuleExampleContainer(
            title: AppLocalizations.get('checkersKingPromotionTitle'),
            example: CheckersRuleExample(
              initialBoardState: [
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [
                  null,
                  ExamplePiece(Colors.white),
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                ], // b7
                [null, null, null, null, null, null, null, null], // a8 - empty
              ],
              animationSteps: [
                AnimationStep(fromRow: 6, fromCol: 1, toRow: 7, toCol: 0),
              ],
              size: 150,
            ),
            description: AppLocalizations.get('checkersKingPromotionDesc'),
          ),
          // TODO: Add example for queen move/capture
        ];

      case 'togyz':
        return [
          _buildHeader(AppLocalizations.get('togyzRulesHeader')),
          _buildText(AppLocalizations.get('togyzGoal')),

          RuleExampleContainer(
            title: AppLocalizations.get('togyzInitialSetupTitle'),
            example: TogyzRuleExample(
              initialOtaus: List.generate(18, (_) => ExampleTogyzPit(9)),
              animationSteps: [],
            ),
            description: AppLocalizations.get('togyzInitialDesc'),
          ),

          _buildHeader(AppLocalizations.get('togyzMoveHeader')),
          _buildText(AppLocalizations.get('togyzMove1')),
          _buildText(AppLocalizations.get('togyzMove2')),
          _buildText(AppLocalizations.get('togyzMove3')),

          RuleExampleContainer(
            title: AppLocalizations.get('togyzSimpleMoveTitle'),
            example: TogyzRuleExample(
              initialOtaus: [
                ExampleTogyzPit(3),
                ...List.generate(17, (_) => ExampleTogyzPit(9)),
              ],
              animationSteps: [
                TogyzAnimationStep(fromOtauIndex: 0, toOtauIndices: [1, 2]),
              ],
              width: 300,
            ),
            description: AppLocalizations.get('togyzSimpleMoveDesc'),
          ),

          _buildHeader(AppLocalizations.get('togyzCaptureHeader')),
          _buildText(AppLocalizations.get('togyzCaptureRule')),

          RuleExampleContainer(
            title: AppLocalizations.get('togyzCaptureExampleTitle'),
            example: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 6)
                    ? ExampleTogyzPit(2)
                    : (i == 9 ? ExampleTogyzPit(3) : ExampleTogyzPit(5)),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 6,
                  toOtauIndices: [7],
                  captureOtauIndex: 9,
                ),
              ],
              width: 300,
            ),
            description: AppLocalizations.get('togyzCaptureExampleDesc'),
          ),

          _buildHeader(AppLocalizations.get('togyzTuzdykHeader')),
          _buildText(AppLocalizations.get('togyzTuzdykRule')),

          RuleExampleContainer(
            title: AppLocalizations.get('togyzTuzdykExampleTitle'),
            example: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 5)
                    ? ExampleTogyzPit(4)
                    : (i == 10 ? ExampleTogyzPit(2) : ExampleTogyzPit(5)),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 5,
                  toOtauIndices: [6, 7, 8], // Last one lands on index 8 (pit 9)
                  // Imagine the 3rd kumalak landed on index 10 instead of 8
                  tuzdykCreationIndex:
                      10, // Simulate creating tuzdyk at index 10
                  tuzdykPlayerColor: Colors.white, // White creates it
                ),
              ],
              width: 300,
            ),
            description: AppLocalizations.get('togyzTuzdykExampleDesc'),
          ),
        ];

      case 'chess':
        return [
          _buildHeader(AppLocalizations.get('chessRulesHeader')),
          _buildText(AppLocalizations.get('chessGoal')),

          RuleExampleContainer(
            title: AppLocalizations.get('chessInitialSetupTitle'),
            example: ChessRuleExample(
              initialFen: initialChessFen,
              animationSteps: [],
              size: 250,
            ),
          ),

          _buildHeader(AppLocalizations.get('chessMovesHeader')),
          _buildText(AppLocalizations.get('chessPawnRule')),
          RuleExampleContainer(
            title: AppLocalizations.get('chessPawnMoveTitle'),
            example: ChessRuleExample(
              initialFen: '8/8/8/8/8/8/4P3/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'e2', toAlg: 'e4')],
              size: 150,
            ),
            description: AppLocalizations.get('chessPawnMoveDesc'),
          ),
          RuleExampleContainer(
            title: AppLocalizations.get('chessPawnCaptureTitle'),
            example: ChessRuleExample(
              initialFen: '8/8/8/8/3p4/4P3/8/8 w - - 0 1',
              animationSteps: [
                ChessAnimationStep(
                  fromAlg: 'e3',
                  toAlg: 'd4',
                  capturedAlg: 'd4',
                ),
              ],
              size: 150,
            ),
            description: AppLocalizations.get('chessPawnCaptureDesc'),
          ),

          _buildText(AppLocalizations.get('chessKnightRule')),
          RuleExampleContainer(
            title: AppLocalizations.get('chessKnightMoveTitle'),
            example: ChessRuleExample(
              initialFen: '8/8/8/8/8/3N4/8/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'd3', toAlg: 'f4')],
              size: 150,
            ),
            description: AppLocalizations.get('chessKnightMoveDesc'),
          ),

          _buildText(AppLocalizations.get('chessBishopRule')),
          _buildText(AppLocalizations.get('chessRookRule')),
          _buildText(AppLocalizations.get('chessQueenRule')),
          _buildText(AppLocalizations.get('chessKingRule')),

          RuleExampleContainer(
            title: AppLocalizations.get('chessCastlingTitle'),
            example: ChessRuleExample(
              initialFen: 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'e1', toAlg: 'g1')],
              size: 150,
            ),
            description: AppLocalizations.get('chessCastlingDesc'),
          ),
          // TODO: Add more chess examples
        ];

      case 'backgammon':
        return [
          _buildHeader(AppLocalizations.get('backgammonRulesHeader')),
          _buildText(AppLocalizations.get('backgammonGoal')),

          RuleExampleContainer(
            title: AppLocalizations.get('backgammonInitialSetupTitle'),
            example: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [],
            ),
          ),

          _buildHeader(AppLocalizations.get('backgammonMoveHeader')),
          _buildText(AppLocalizations.get('backgammonMove1')),
          _buildText(AppLocalizations.get('backgammonMove2')),
          _buildText(AppLocalizations.get('backgammonMove3')),
          _buildText(AppLocalizations.get('backgammonMove4')),

          RuleExampleContainer(
            title: AppLocalizations.get('backgammonMoveExampleTitle'),
            example: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [
                BackgammonAnimationStep(
                  diceRoll: [5, 2],
                  moves: [
                    {'from': 18, 'to': 23, 'die': 5},
                    {'from': 18, 'to': 20, 'die': 2},
                  ],
                ),
              ],
            ),
            description: AppLocalizations.get('backgammonMoveExampleDesc'),
          ),

          _buildHeader(AppLocalizations.get('backgammonHitHeader')),
          _buildText(AppLocalizations.get('backgammonHitRule')),

          RuleExampleContainer(
            title: AppLocalizations.get('backgammonHitExampleTitle'),
            example: BackgammonRuleExample(
              initialPoints: List.generate(
                28,
                (i) => (i == 0)
                    ? backgammon.PointState(count: 1, color: Colors.white)
                    : (i == 3)
                    ? backgammon.PointState(count: 1, color: Colors.black)
                    : backgammon.PointState(),
              ),
              animationSteps: [
                BackgammonAnimationStep(
                  diceRoll: [3, 1],
                  moves: [
                    {'from': 0, 'to': 3, 'die': 3},
                  ],
                ),
              ],
              width: 250,
            ),
            description: AppLocalizations.get('backgammonHitExampleDesc'),
          ),

          _buildHeader(AppLocalizations.get('backgammonBarHeader')),
          _buildText(AppLocalizations.get('backgammonBarRule')),

          // TODO: Example for entering from bar
          _buildHeader(AppLocalizations.get('backgammonBearOffHeader')),
          _buildText(AppLocalizations.get('backgammonBearOffRule')),
          // TODO: Example for bearing off
        ];
      default:
        return [Text(AppLocalizations.get('rulesNotFound'))];
    }
  }

  // Helper widgets for formatting
  Widget _buildHeader(String text) => Padding(
    padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Ensure you add 'rulesFor' key to app_localizations.dart
        title: Text(
          '${AppLocalizations.get('rulesFor')} ${AppLocalizations.get(gameKey)}',
        ),
      ),
      body: ListView(
        // Use ListView to allow scrolling
        padding: const EdgeInsets.all(16.0),
        children: _getRulesContent(context, gameKey),
      ),
    );
  }
}
