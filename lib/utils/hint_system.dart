import 'package:flutter/material.dart';
import 'training_mode_provider.dart';

/// Универсальная система подсказок для всех игр
class HintSystem {
  /// Проверяет включен ли режим обучения
  static bool isTrainingModeEnabled() {
    return TrainingMode().isEnabled;
  }
  /// Показывает подсказку с объяснением на экране
  static void showHint(
    BuildContext context, {
    required String title,
    required String explanation,
    String? moveSuggestion,
    VoidCallback? onApplyHint,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moveSuggestion != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        moveSuggestion,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            Text(
              explanation,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Понятно'),
          ),
          if (onApplyHint != null)
            ElevatedButton.icon(
              icon: Icon(Icons.check, size: 18),
              label: Text('Применить'),
              onPressed: () {
                Navigator.pop(context);
                onApplyHint();
              },
            ),
        ],
      ),
    );
  }

  /// Показывает индикатор загрузки подсказки
  static void showHintLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI анализирует позицию...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Показывает подсказку с выделением клеток на доске
  static Widget buildHintHighlight({
    required bool showHint,
    required int position,
    required double size,
    required Offset offset,
  }) {
    if (!showHint) return SizedBox.shrink();

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.star,
            color: Colors.amber,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }

  /// Показывает кнопку запроса подсказки
  static Widget buildHintButton({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: Colors.amber.shade700,
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.lightbulb, color: Colors.black87),
      tooltip: 'Получить подсказку',
    );
  }

  /// Показывает постоянную панель с последней подсказкой
  static Widget buildHintPanel({
    required String? currentHint,
    required VoidCallback onDismiss,
  }) {
    if (currentHint == null) return SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.amber.shade50,
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentHint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: onDismiss,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Форматирует ход для отображения в подсказке (шахматы)
  static String formatChessMove(String move) {
    return 'Рекомендуемый ход: $move';
  }

  /// Форматирует ход для отображения в подсказке (шашки)
  static String formatCheckersMove(int from, int to) {
    final fromRow = 8 - (from ~/ 8);
    final fromCol = String.fromCharCode(97 + (from % 8));
    final toRow = 8 - (to ~/ 8);
    final toCol = String.fromCharCode(97 + (to % 8));
    return 'Рекомендуемый ход: $fromCol$fromRow → $toCol$toRow';
  }

  /// Форматирует ход для отображения в подсказке (Тогыз Кумалак)
  static String formatTogyzMove(int pitNumber) {
    return 'Рекомендуемый ход: лунка №$pitNumber';
  }

  /// Показывает обучающее сообщение
  static void showTutorialMessage(
    BuildContext context, {
    required String title,
    required String message,
    String? nextStepHint,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontSize: 15, height: 1.5)),
            if (nextStepHint != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Следующий шаг: $nextStepHint',
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Продолжить'),
          ),
        ],
      ),
    );
  }
}

/// Модель подсказки
class GameHint {
  final String moveSuggestion;
  final String explanation;
  final dynamic moveData; // Данные хода (зависят от игры)

  GameHint({
    required this.moveSuggestion,
    required this.explanation,
    this.moveData,
  });
}
