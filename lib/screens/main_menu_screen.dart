import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_card.dart';
import '../utils/training_mode_provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  void _changeLanguage(String langCode) {
    setState(() {
      AppLocalizations.setLanguage(langCode);
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.get('exit')),
        content: Text(AppLocalizations.get('exitConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.get('no')),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(AppLocalizations.get('yes')),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton(String textKey, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade700.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
        elevation: 6,
        minimumSize: const Size(180, 62),
      ),
      onPressed: () {
        if (textKey == 'language') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.get('selectLanguage')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Русский'),
                    onTap: () {
                      _changeLanguage('ru');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('English'),
                    onTap: () {
                      _changeLanguage('en');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Қазақша'),
                    onTap: () {
                      _changeLanguage('kz');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (textKey == 'training') {
          // Включаем режим обучения и переходим на экран выбора игры
          TrainingMode().setEnabled(true);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.school, color: Colors.amber),
                  SizedBox(width: 10),
                  Text('Режим обучения'),
                ],
              ),
              content: Text(
                'Режим обучения активирован!\n\n'
                'В этом режиме вы сможете:\n'
                '• Получать подсказки от AI\n'
                '• Видеть объяснения ходов\n'
                '• Учиться стратегии\n\n'
                'Выберите игру для обучения.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    TrainingMode().setEnabled(false);
                    Navigator.pop(context);
                  },
                  child: Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/training');
                  },
                  child: Text('Продолжить'),
                ),
              ],
            ),
          );
        } else if (textKey == 'exit') {
          _showExitDialog();
        }
      },
      icon: Icon(icon, size: 30),
      label: Text(
        AppLocalizations.get(textKey),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Умная адаптивность под размер экрана
    int crossAxisCount;
    double maxGridWidth;
    double cardAspectRatio;

    if (screenWidth < 600) {
      // Маленькие экраны (телефоны в портретной ориентации)
      crossAxisCount = 2;
      maxGridWidth = screenWidth;
      cardAspectRatio = 1.1;
    } else if (screenWidth < 900) {
      // Средние экраны (телефоны в альбомной, планшеты в портретной)
      crossAxisCount = 3;
      maxGridWidth = 800;
      cardAspectRatio = 1.2;
    } else if (screenWidth < 1200) {
      // Большие экраны (планшеты в альбомной, маленькие десктопы)
      crossAxisCount = 4;
      maxGridWidth = 1000;
      cardAspectRatio = 1.3;
    } else {
      // Очень большие экраны (десктопы)
      crossAxisCount = 4;
      maxGridWidth = 1200;
      cardAspectRatio = 1.4;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade800, Colors.black87],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Верхняя панель ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStyledButton('language', Icons.language),
                    // Вы можете добавить сюда Text('GYLYM OYNA', ...), если хотите
                    Spacer(), // Пустое пространство
                  ],
                ),
              ),

              // --- Сетка с играми ---
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxGridWidth),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 25,
                          crossAxisSpacing: 25,
                          childAspectRatio: cardAspectRatio,
                          children: [
                            // Передаем правильные ключи
                            GameCard(
                              gameKey: 'chess',
                              iconData: Icons.shield_moon_outlined,
                            ),
                            GameCard(gameKey: 'checkers', iconData: Icons.circle),
                            GameCard(gameKey: 'togyz', iconData: Icons.grain),
                            GameCard(gameKey: 'backgammon', iconData: Icons.casino),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Нижняя панель ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStyledButton('exit', Icons.exit_to_app),
                    _buildStyledButton('training', Icons.school),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
