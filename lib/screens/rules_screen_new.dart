import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/checkers_rule_example.dart';
import '../widgets/togyz_rule_example.dart';
import '../widgets/chess_rule_example.dart';
import '../widgets/backgammon_rule_example.dart';
import '../games/backgammon_logic.dart' as backgammon;
import 'package:chess/chess.dart' as chess;

const String initialChessFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

class RulesScreenNew extends StatefulWidget {
  final String gameKey;
  const RulesScreenNew({Key? key, required this.gameKey}) : super(key: key);

  @override
  State<RulesScreenNew> createState() => _RulesScreenNewState();
}

class _RulesScreenNewState extends State<RulesScreenNew> {
  int _selectedRuleIndex = 0;

  // Helper for Checkers initial setup
  List<List<ExamplePiece?>> _getCheckersInitialSetup() {
    List<List<ExamplePiece?>> board = List.generate(
      8,
      (_) => List.generate(8, (_) => null),
    );
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 != 0) {
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

  List<RuleItem> _getRuleItems(String game) {
    switch (game) {
      case 'checkers':
        return [
          RuleItem(
            title: AppLocalizations.get('checkersBasicRules'),
            textContent: [
              AppLocalizations.get('checkersGoal'),
              '',
              AppLocalizations.get('checkersMovesHeader'),
              AppLocalizations.get('checkersMove1'),
              AppLocalizations.get('checkersMove2'),
            ],
            visualization: CheckersRuleExample(
              initialBoardState: _getCheckersInitialSetup(),
              animationSteps: [],
              size: 500,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('checkersSimpleMoveTitle'),
            textContent: [AppLocalizations.get('checkersSimpleMoveDesc')],
            visualization: CheckersRuleExample(
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
                ],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(fromRow: 3, fromCol: 2, toRow: 4, toCol: 3),
              ],
              size: 450,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('checkersCaptureHeader'),
            textContent: [
              AppLocalizations.get('checkersCapture1'),
              AppLocalizations.get('checkersCapture2'),
              AppLocalizations.get('checkersCapture3'),
            ],
            visualization: CheckersRuleExample(
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
                ],
                [
                  null,
                  null,
                  null,
                  ExamplePiece(Colors.black),
                  null,
                  null,
                  null,
                  null,
                ],
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
              size: 450,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('checkersKingHeader'),
            textContent: [
              AppLocalizations.get('checkersKing1'),
              AppLocalizations.get('checkersKing2'),
            ],
            visualization: CheckersRuleExample(
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
                ],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(fromRow: 6, fromCol: 1, toRow: 7, toCol: 0),
              ],
              size: 450,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('checkersMandatoryCaptureTitle'),
            textContent: [AppLocalizations.get('checkersMandatoryCaptureDesc')],
            visualization: CheckersRuleExample(
              initialBoardState: [
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [
                  null,
                  null,
                  null,
                  null,
                  null,
                  ExamplePiece(Colors.black),
                  null,
                  null,
                ],
                [
                  null,
                  null,
                  null,
                  null,
                  ExamplePiece(Colors.white),
                  null,
                  null,
                  null,
                ],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(
                  fromRow: 4,
                  fromCol: 4,
                  toRow: 2,
                  toCol: 6,
                  captureRow: 3,
                  captureCol: 5,
                ),
              ],
              size: 450,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('checkersKingLongCaptureTitle'),
            textContent: [AppLocalizations.get('checkersKingLongCaptureDesc')],
            visualization: CheckersRuleExample(
              initialBoardState: [
                [
                  null,
                  ExamplePiece(Colors.white, isKing: true),
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                ],
                [null, null, null, null, null, null, null, null],
                [
                  null,
                  null,
                  null,
                  ExamplePiece(Colors.black),
                  null,
                  null,
                  null,
                  null,
                ],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
                [null, null, null, null, null, null, null, null],
              ],
              animationSteps: [
                AnimationStep(
                  fromRow: 0,
                  fromCol: 1,
                  toRow: 5,
                  toCol: 6,
                  captureRow: 2,
                  captureCol: 3,
                ),
              ],
              size: 450,
            ),
          ),
        ];

      case 'togyz':
        return [
          RuleItem(
            title: AppLocalizations.get('togyzRulesHeader'),
            textContent: [
              AppLocalizations.get('togyzGoal'),
              '',
              AppLocalizations.get('togyzInitialDesc'),
            ],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(18, (_) => ExampleTogyzPit(9)),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzMoveHeader'),
            textContent: [
              AppLocalizations.get('togyzMove1'),
              AppLocalizations.get('togyzMove2'),
              AppLocalizations.get('togyzMove3'),
            ],
            visualization: TogyzRuleExample(
              initialOtaus: [
                ExampleTogyzPit(3),
                ...List.generate(17, (_) => ExampleTogyzPit(9)),
              ],
              animationSteps: [
                TogyzAnimationStep(fromOtauIndex: 0, toOtauIndices: [1, 2]),
              ],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzCaptureHeader'),
            textContent: [AppLocalizations.get('togyzCaptureRule')],
            visualization: TogyzRuleExample(
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
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzTuzdykHeader'),
            textContent: [AppLocalizations.get('togyzTuzdykRule')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 5)
                    ? ExampleTogyzPit(4)
                    : (i == 10 ? ExampleTogyzPit(2) : ExampleTogyzPit(5)),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 5,
                  toOtauIndices: [6, 7, 8],
                  tuzdykCreationIndex: 10,
                  tuzdykPlayerColor: Colors.white,
                ),
              ],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzWinConditionTitle'),
            textContent: [AppLocalizations.get('togyzWinConditionDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(18, (_) => ExampleTogyzPit(5)),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzStrategyTitle'),
            textContent: [AppLocalizations.get('togyzStrategyDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 3 || i == 14)
                    ? ExampleTogyzPit(2)
                    : ExampleTogyzPit(7),
              ),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzAutoCaptureTitle'),
            textContent: [AppLocalizations.get('togyzAutoCaptureDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 4)
                    ? ExampleTogyzPit(3)
                    : (i == 10
                        ? ExampleTogyzPit(0, isTuzdyk: true, tuzdykOwner: Colors.white)
                        : ExampleTogyzPit(5)),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 4,
                  toOtauIndices: [5, 6, 7, 8, 9, 10],
                  tuzdykPlayerColor: Colors.white,
                ),
              ],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzTuzdykRestrictionsTitle'),
            textContent: [AppLocalizations.get('togyzTuzdykRestrictionsDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 8 || i == 17)
                    ? ExampleTogyzPit(2)
                    : ExampleTogyzPit(5),
              ),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzEmptyPitRuleTitle'),
            textContent: [AppLocalizations.get('togyzEmptyPitRuleDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 0 || i == 2)
                    ? ExampleTogyzPit(0)
                    : ExampleTogyzPit(7),
              ),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzAtsyrauTitle'),
            textContent: [AppLocalizations.get('togyzAtsyrauDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i >= 0 && i <= 8)
                    ? ExampleTogyzPit(3)
                    : ExampleTogyzPit(0),
              ),
              initialWhiteKazan: 75,
              initialBlackKazan: 59,
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzNoCaptureSameTitle'),
            textContent: [AppLocalizations.get('togyzNoCaptureSameDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 0)
                    ? ExampleTogyzPit(2)
                    : (i == 2 ? ExampleTogyzPit(3) : ExampleTogyzPit(5)),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 0,
                  toOtauIndices: [1],
                ),
              ],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzContinuingMoveTitle'),
            textContent: [AppLocalizations.get('togyzContinuingMoveDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 3)
                    ? ExampleTogyzPit(20)
                    : ExampleTogyzPit(5),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 3,
                  toOtauIndices: List.generate(19, (i) => (4 + i) % 18),
                ),
              ],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzTuzdykOnlyOnceTitle'),
            textContent: [AppLocalizations.get('togyzTuzdykOnceDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 12)
                    ? ExampleTogyzPit(0, isTuzdyk: true, tuzdykOwner: Colors.white)
                    : ExampleTogyzPit(6),
              ),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzOneRemainsTitle'),
            textContent: [AppLocalizations.get('togyzOneRemainsDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 2)
                    ? ExampleTogyzPit(5)
                    : ExampleTogyzPit(9),
              ),
              animationSteps: [
                TogyzAnimationStep(
                  fromOtauIndex: 2,
                  toOtauIndices: [3, 4, 5, 6],
                ),
              ],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzNo9thPitTitle'),
            textContent: [AppLocalizations.get('togyzNo9thPitDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(
                18,
                (i) => (i == 8 || i == 17)
                    ? ExampleTogyzPit(3)
                    : ExampleTogyzPit(7),
              ),
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzDrawTitle'),
            textContent: [AppLocalizations.get('togyzDrawDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(18, (_) => ExampleTogyzPit(0)),
              initialWhiteKazan: 81,
              initialBlackKazan: 81,
              animationSteps: [],
              width: 650,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('togyzScoreCountTitle'),
            textContent: [AppLocalizations.get('togyzScoreCountDesc')],
            visualization: TogyzRuleExample(
              initialOtaus: List.generate(18, (i) => ExampleTogyzPit(3)),
              initialWhiteKazan: 45,
              initialBlackKazan: 63,
              animationSteps: [],
              width: 650,
            ),
          ),
        ];

      case 'chess':
        return [
          RuleItem(
            title: AppLocalizations.get('chessRulesHeader'),
            textContent: [AppLocalizations.get('chessGoal')],
            visualization: ChessRuleExample(
              initialFen: initialChessFen,
              animationSteps: [],
              size: 520,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessPawnRule'),
            textContent: [
              AppLocalizations.get('chessPawnMoveDesc'),
              AppLocalizations.get('chessPawnCaptureDesc'),
            ],
            visualization: ChessRuleExample(
              initialFen: '8/8/8/8/8/8/4P3/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'e2', toAlg: 'e4')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessKnightRule'),
            textContent: [AppLocalizations.get('chessKnightMoveDesc')],
            visualization: ChessRuleExample(
              initialFen: '8/8/8/8/8/3N4/8/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'd3', toAlg: 'f4')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessMovesHeader'),
            textContent: [
              AppLocalizations.get('chessBishopRule'),
              AppLocalizations.get('chessRookRule'),
              AppLocalizations.get('chessQueenRule'),
              AppLocalizations.get('chessKingRule'),
            ],
            visualization: ChessRuleExample(
              initialFen: initialChessFen,
              animationSteps: [],
              size: 520,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessCastlingTitle'),
            textContent: [AppLocalizations.get('chessCastlingDesc')],
            visualization: ChessRuleExample(
              initialFen: 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'e1', toAlg: 'g1')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessEnPassantTitle'),
            textContent: [AppLocalizations.get('chessEnPassantDesc')],
            visualization: ChessRuleExample(
              initialFen:
                  'rnbqkbnr/pppp1ppp/8/3Pp3/8/8/PPP1PPPP/RNBQKBNR w KQkq e6 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'd5', toAlg: 'e6')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessPromotionTitle'),
            textContent: [AppLocalizations.get('chessPromotionDesc')],
            visualization: ChessRuleExample(
              initialFen: 'rnbqkbnr/1P6/8/8/8/8/8/RNBQKBNR w KQkq - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'b7', toAlg: 'b8')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessCheckTitle'),
            textContent: [AppLocalizations.get('chessCheckDesc')],
            visualization: ChessRuleExample(
              initialFen:
                  'rnb1kbnr/pppp1ppp/8/4p3/5PPq/8/PPPPP2P/RNBQKBNR w KQkq - 0 1',
              animationSteps: [],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessRookRule'),
            textContent: [AppLocalizations.get('chessRookMoveDesc')],
            visualization: ChessRuleExample(
              initialFen: '8/8/8/3R4/8/8/8/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'd5', toAlg: 'd8')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessBishopRule'),
            textContent: [AppLocalizations.get('chessBishopMoveDesc')],
            visualization: ChessRuleExample(
              initialFen: '8/8/8/3B4/8/8/8/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'd5', toAlg: 'h1')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessQueenRule'),
            textContent: [AppLocalizations.get('chessQueenMoveDesc')],
            visualization: ChessRuleExample(
              initialFen: '8/8/8/3Q4/8/8/8/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'd5', toAlg: 'h5')],
              size: 480,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('chessCheckmateTitle'),
            textContent: [AppLocalizations.get('chessCheckmateDesc')],
            visualization: ChessRuleExample(
              initialFen: '5k2/5P2/5K2/8/8/8/8/8 w - - 0 1',
              animationSteps: [ChessAnimationStep(fromAlg: 'f7', toAlg: 'f8')],
              size: 480,
            ),
          ),
        ];

      case 'backgammon':
        return [
          RuleItem(
            title: AppLocalizations.get('backgammonRulesHeader'),
            textContent: [AppLocalizations.get('backgammonGoal')],
            visualization: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [],
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonMoveHeader'),
            textContent: [
              AppLocalizations.get('backgammonMove1'),
              AppLocalizations.get('backgammonMove2'),
              AppLocalizations.get('backgammonMove3'),
              AppLocalizations.get('backgammonMove4'),
            ],
            visualization: BackgammonRuleExample(
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
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonHitHeader'),
            textContent: [AppLocalizations.get('backgammonHitRule')],
            visualization: BackgammonRuleExample(
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
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonBarHeader'),
            textContent: [AppLocalizations.get('backgammonBarRule')],
            visualization: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [],
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonBearOffHeader'),
            textContent: [AppLocalizations.get('backgammonBearOffRule')],
            visualization: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [],
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonDoublesTitle'),
            textContent: [AppLocalizations.get('backgammonDoublesDesc')],
            visualization: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [
                BackgammonAnimationStep(diceRoll: [3, 3], moves: []),
              ],
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonBlockadeTitle'),
            textContent: [AppLocalizations.get('backgammonBlockadeDesc')],
            visualization: BackgammonRuleExample(
              initialPoints: List.generate(28, (i) {
                if (i >= 6 && i <= 11)
                  return backgammon.PointState(count: 2, color: Colors.white);
                if (i == 15)
                  return backgammon.PointState(count: 1, color: Colors.black);
                return backgammon.PointState();
              }),
              animationSteps: [],
              width: 600,
            ),
          ),
          RuleItem(
            title: AppLocalizations.get('backgammonWinConditionsTitle'),
            textContent: [AppLocalizations.get('backgammonWinConditionsDesc')],
            visualization: BackgammonRuleExample(
              initialPoints: _getBackgammonInitialSetup(),
              animationSteps: [],
              width: 600,
            ),
          ),
        ];

      default:
        return [
          RuleItem(
            title: AppLocalizations.get('rulesNotFound'),
            textContent: [],
            visualization: const SizedBox(),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final rules = _getRuleItems(widget.gameKey);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.get('rulesFor')} ${AppLocalizations.get(widget.gameKey)}',
        ),
      ),
      body: isWide
          ? Row(
              children: [
                // Left Panel - Rules List
                SizedBox(
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.3),
                      border: Border(
                        right: BorderSide(color: Colors.white24, width: 1),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: rules.length,
                      itemBuilder: (context, index) {
                        final rule = rules[index];
                        final isSelected = _selectedRuleIndex == index;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: Colors.amber.shade700.withOpacity(
                            0.2,
                          ),
                          title: Text(
                            rule.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.amber.shade700
                                  : Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedRuleIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Right Panel - Rule Details and Visualization
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          rules[_selectedRuleIndex].title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Text Content
                        ...rules[_selectedRuleIndex].textContent.map(
                          (text) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Visualization
                        Center(child: rules[_selectedRuleIndex].visualization),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Top - Rules Tabs (horizontal scroll)
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withOpacity(0.3),
                    border: const Border(
                      bottom: BorderSide(color: Colors.white24, width: 1),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final isSelected = _selectedRuleIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRuleIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.amber.shade700.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected
                                    ? Colors.amber.shade700
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              rule.title,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.amber.shade700
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bottom - Rule Details
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rules[_selectedRuleIndex].title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...rules[_selectedRuleIndex].textContent.map(
                          (text) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(child: rules[_selectedRuleIndex].visualization),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class RuleItem {
  final String title;
  final List<String> textContent;
  final Widget visualization;

  RuleItem({
    required this.title,
    required this.textContent,
    required this.visualization,
  });
}
