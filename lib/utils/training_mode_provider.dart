import 'package:flutter/material.dart';

/// Провайдер для глобального управления режимом обучения
class TrainingModeProvider extends ChangeNotifier {
  bool _isTrainingMode = false;

  bool get isTrainingMode => _isTrainingMode;

  void setTrainingMode(bool enabled) {
    _isTrainingMode = enabled;
    notifyListeners();
  }

  void toggleTrainingMode() {
    _isTrainingMode = !_isTrainingMode;
    notifyListeners();
  }
}

/// Singleton для доступа из любого места приложения
class TrainingMode {
  static final TrainingMode _instance = TrainingMode._internal();
  factory TrainingMode() => _instance;
  TrainingMode._internal();

  bool _enabled = false;

  bool get isEnabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void toggle() {
    _enabled = !_enabled;
  }
}
