import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'game_setup_screen.dart';
import '../data/training_lessons_data.dart';

class TrainingScreenNew extends StatefulWidget {
  const TrainingScreenNew({Key? key}) : super(key: key);

  @override
  State<TrainingScreenNew> createState() => _TrainingScreenNewState();
}

class _TrainingScreenNewState extends State<TrainingScreenNew> {
  String? _selectedGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.get('training'))),
      body: _selectedGame == null ? _buildGameSelection() : _buildLessonsList(),
    );
  }

  Widget _buildGameSelection() {
    final games = ['chess', 'checkers', 'togyz', 'backgammon'];
    final icons = [
      Icons.shield_moon_outlined,
      Icons.circle,
      Icons.grain,
      Icons.casino,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey.shade800, Colors.black87],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.get('training_selectGame'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ...List.generate(games.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade700.withOpacity(
                        0.8,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedGame = games[index];
                      });
                    },
                    icon: Icon(icons[index], size: 30),
                    label: Text(
                      AppLocalizations.get(games[index]),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonsList() {
    final lessons = _selectedGame == null
        ? const <TrainingLesson>[]
        : getTrainingLessons(AppLocalizations.currentLanguage, _selectedGame!);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey.shade800, Colors.black87],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: const Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedGame = null;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${AppLocalizations.get('training_selectLesson')}: ${AppLocalizations.get(_selectedGame!)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lessons List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.blueGrey.shade800.withOpacity(0.5),
                  child: InkWell(
                    onTap: () {
                      _showLessonDetails(lesson);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lesson.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              _buildDifficultyBadge(lesson.difficulty),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lesson.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${lesson.aiHints.length} ${AppLocalizations.get('training_aiHints')}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(TrainingDifficulty difficulty) {
    late Color color;
    late String label;
    switch (difficulty) {
      case TrainingDifficulty.easy:
        color = Colors.green;
        label = AppLocalizations.get('easy');
        break;
      case TrainingDifficulty.medium:
        color = Colors.orange;
        label = AppLocalizations.get('medium');
        break;
      case TrainingDifficulty.hard:
        color = Colors.red;
        label = AppLocalizations.get('hard');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLessonDetails(TrainingLesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey.shade900,
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lesson.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lesson.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.get('training_aiHints'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...lesson.aiHints.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GameSetupScreen(gameKey: _selectedGame!),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  AppLocalizations.get('training_startTraining'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.get('close'),
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}
