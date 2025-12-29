import 'package:flutter/material.dart';

/// Глобальный провайдер для управления яркостью приложения
class BrightnessProvider extends ChangeNotifier {
  static final BrightnessProvider _instance = BrightnessProvider._internal();
  factory BrightnessProvider() => _instance;
  BrightnessProvider._internal();

  double _brightness = 1.0; // От 0.0 до 1.0

  double get brightness => _brightness;

  void setBrightness(double value) {
    _brightness = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Получить цвет с примененной яркостью
  Color applyBrightness(Color color) {
    if (_brightness >= 1.0) return color;

    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = hsl.lightness * _brightness;
    return hsl.withLightness(adjustedLightness.clamp(0.0, 1.0)).toColor();
  }
}
