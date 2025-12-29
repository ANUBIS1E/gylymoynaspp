import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess; // Import for chess Color enum
import '../l10n/app_localizations.dart'; // Import localization
import 'game_screen.dart';
import 'rules_screen_new.dart';

// Enums for game settings
enum GameMode { pvp, pve }

enum AiDifficulty {
  level1,  // Новичок - очень слабый
  level2,  // Новичок
  level3,  // Легкий
  level4,  // Легко-средний
  level5,  // Средний
  level6,  // Средне-сильный
  level7,  // Сильный
  level8,  // Очень сильный
  level9,  // Эксперт
  level10  // Гроссмейстер
}

enum GameDuration {
  noTimer,
  min3,
  min5,
  min10,
  min15,
} // Added game duration with no timer option

class GameSetupScreen extends StatefulWidget {
  final String gameKey;

  const GameSetupScreen({Key? key, required this.gameKey}) : super(key: key);

  @override
  _GameSetupScreenState createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  GameMode _selectedMode = GameMode.pvp;
  AiDifficulty _selectedDifficulty = AiDifficulty.level5;
  chess.Color _selectedColor = chess.Color.WHITE; // Default for Chess PvE
  bool _checkersPlayAsWhite = true; // Default for Checkers PvE
  GameDuration _selectedDuration = GameDuration.min5; // Default 5 minutes

  @override
  Widget build(BuildContext context) {
    final String gameName = AppLocalizations.get(widget.gameKey);
    final bool isChess = widget.gameKey == 'chess';
    final bool isCheckers = widget.gameKey == 'checkers';
    final screenWidth = MediaQuery.of(context).size.width;

    // Адаптивная ширина контента
    final maxWidth = screenWidth > 800 ? 600.0 : screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.get('gameSettings')}: $gameName',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // --- Select Game Mode ---
              Text(
                AppLocalizations.get('selectMode'),
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 20),
              SegmentedButton<GameMode>(
                segments: [
                  ButtonSegment(
                    value: GameMode.pvp,
                    label: Text(AppLocalizations.get('playerVsPlayer')),
                  ),
                  ButtonSegment(
                    value: GameMode.pve,
                    label: Text(AppLocalizations.get('playerVsAi')),
                  ),
                ],
                selected: {_selectedMode},
                onSelectionChanged: (Set<GameMode> newSelection) {
                  setState(() {
                    _selectedMode = newSelection.first;
                  });
                },
              ),

              // --- AI Settings (only if PvE selected) ---
              if (_selectedMode == GameMode.pve) ...[
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.get('selectDifficulty'),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 20),
                // Слайдер для выбора уровня сложности от 1 до 10
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppLocalizations.get('level')}: ${_getDifficultyLevel(_selectedDifficulty)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _getDifficultyName(_selectedDifficulty),
                            style: TextStyle(
                              fontSize: 18,
                              color: _getDifficultyColor(_selectedDifficulty),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _getDifficultyLevel(_selectedDifficulty).toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '${_getDifficultyLevel(_selectedDifficulty)}',
                        onChanged: (double value) {
                          setState(() {
                            _selectedDifficulty = _getDifficultyFromLevel(value.toInt());
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text('5', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text('10', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- Select Side (Only for Chess PvE) ---
                if (isChess) ...[
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.get('selectSide'),
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<chess.Color>(
                    segments: [
                      ButtonSegment(
                        value: chess.Color.WHITE,
                        label: Text(AppLocalizations.get('white')),
                      ),
                      ButtonSegment(
                        value: chess.Color.BLACK,
                        label: Text(AppLocalizations.get('black')),
                      ),
                    ],
                    selected: {_selectedColor},
                    onSelectionChanged: (Set<chess.Color> newSelection) {
                      setState(() {
                        _selectedColor = newSelection.first;
                      });
                    },
                  ),
                ] else if (isCheckers) ...[
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.get('selectSide'),
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(AppLocalizations.get('white')),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(AppLocalizations.get('black')),
                      ),
                    ],
                    selected: {_checkersPlayAsWhite},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _checkersPlayAsWhite = newSelection.first;
                      });
                    },
                  ),
                ],
              ],

              // --- Select Timer Duration ---
              const SizedBox(height: 40),
              Text(
                AppLocalizations.get('selectTime'),
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(AppLocalizations.get('noTimer')),
                    selected: _selectedDuration == GameDuration.noTimer,
                    onSelected: (selected) {
                      if (selected)
                        setState(() {
                          _selectedDuration = GameDuration.noTimer;
                        });
                    },
                  ),
                  ChoiceChip(
                    label: Text('3 ${AppLocalizations.get('minutes')}'),
                    selected: _selectedDuration == GameDuration.min3,
                    onSelected: (selected) {
                      if (selected)
                        setState(() {
                          _selectedDuration = GameDuration.min3;
                        });
                    },
                  ),
                  ChoiceChip(
                    label: Text('5 ${AppLocalizations.get('minutes')}'),
                    selected: _selectedDuration == GameDuration.min5,
                    onSelected: (selected) {
                      if (selected)
                        setState(() {
                          _selectedDuration = GameDuration.min5;
                        });
                    },
                  ),
                  ChoiceChip(
                    label: Text('10 ${AppLocalizations.get('minutes')}'),
                    selected: _selectedDuration == GameDuration.min10,
                    onSelected: (selected) {
                      if (selected)
                        setState(() {
                          _selectedDuration = GameDuration.min10;
                        });
                    },
                  ),
                  ChoiceChip(
                    label: Text('15 ${AppLocalizations.get('minutes')}'),
                    selected: _selectedDuration == GameDuration.min15,
                    onSelected: (selected) {
                      if (selected)
                        setState(() {
                          _selectedDuration = GameDuration.min15;
                        });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // --- Start Game Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  int durationInSeconds;
                  switch (_selectedDuration) {
                    case GameDuration.noTimer:
                      durationInSeconds = -1;
                      break; // -1 означает без таймера
                    case GameDuration.min3:
                      durationInSeconds = 180;
                      break;
                    case GameDuration.min5:
                      durationInSeconds = 300;
                      break;
                    case GameDuration.min10:
                      durationInSeconds = 600;
                      break;
                    case GameDuration.min15:
                      durationInSeconds = 900;
                      break;
                  }
                  Navigator.pushReplacement(
                    // Use pushReplacement to remove setup screen from stack
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        gameKey: widget.gameKey,
                        mode: _selectedMode,
                        difficulty: _selectedMode == GameMode.pve
                            ? _selectedDifficulty
                            : null,
                        chessPlayerColor:
                            (_selectedMode == GameMode.pve && isChess)
                            ? _selectedColor
                            : null,
                        checkersPlayAsWhite:
                            (_selectedMode == GameMode.pve && isCheckers)
                            ? _checkersPlayAsWhite
                            : null,
                        gameDurationSeconds: durationInSeconds,
                      ),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.get('startGame'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // --- Rules Button ---
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ), // Slightly dimmer border
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RulesScreenNew(gameKey: widget.gameKey),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.get('gameRules'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                  ), // Slightly dimmer text
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // Вспомогательные методы для работы с уровнями сложности
  int _getDifficultyLevel(AiDifficulty difficulty) {
    switch (difficulty) {
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
    }
  }

  AiDifficulty _getDifficultyFromLevel(int level) {
    switch (level) {
      case 1: return AiDifficulty.level1;
      case 2: return AiDifficulty.level2;
      case 3: return AiDifficulty.level3;
      case 4: return AiDifficulty.level4;
      case 5: return AiDifficulty.level5;
      case 6: return AiDifficulty.level6;
      case 7: return AiDifficulty.level7;
      case 8: return AiDifficulty.level8;
      case 9: return AiDifficulty.level9;
      case 10: return AiDifficulty.level10;
      default: return AiDifficulty.level5;
    }
  }

  String _getDifficultyName(AiDifficulty difficulty) {
    final level = _getDifficultyLevel(difficulty);
    if (level <= 2) return AppLocalizations.get('beginner');
    if (level <= 4) return AppLocalizations.get('easy');
    if (level <= 6) return AppLocalizations.get('medium');
    if (level <= 8) return AppLocalizations.get('hard');
    return AppLocalizations.get('expert');
  }

  Color _getDifficultyColor(AiDifficulty difficulty) {
    final level = _getDifficultyLevel(difficulty);
    if (level <= 2) return Colors.green;
    if (level <= 4) return Colors.lightGreen;
    if (level <= 6) return Colors.orange;
    if (level <= 8) return Colors.deepOrange;
    return Colors.red;
  }
}
