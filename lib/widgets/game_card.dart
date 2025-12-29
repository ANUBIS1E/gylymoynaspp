import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart'; // Импорт локализации
import '../screens/game_setup_screen.dart';

class GameCard extends StatelessWidget {
  final String gameKey; // Инвариантный ключ игры (chess/checkers/...)
  final IconData iconData;

  const GameCard({Key? key, required this.gameKey, required this.iconData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizedName = AppLocalizations.get(gameKey);

    return Card(
      // Стиль карточки теперь берется из Theme в main.dart
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameSetupScreen(gameKey: gameKey),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15), // Соответствует CardTheme
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 64,
              color: Theme.of(context).primaryColor,
            ), // Иконка покрупнее
            const SizedBox(height: 12),
            Text(
              localizedName,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
