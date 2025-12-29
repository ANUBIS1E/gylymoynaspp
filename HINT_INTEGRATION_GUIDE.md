# Руководство по интеграции системы подсказок

## Обзор

Система подсказок (`HintSystem`) предоставляет универсальный интерфейс для показа AI-подсказок во всех играх с объяснениями ходов.

**ВАЖНО:** Подсказки доступны только в режиме обучения! Пользователь должен нажать кнопку "Training" в главном меню, чтобы активировать режим обучения.

## Файлы системы подсказок

- `lib/utils/hint_system.dart` - Основная система подсказок
- `lib/utils/training_mode_provider.dart` - Управление режимом обучения
- `lib/games/checkers_ai.dart` - AI с методом `suggestMoveWithExplanation()`
- `lib/games/togyz_kumalak_ai.dart` - AI с методом `suggestMoveWithExplanation()`
- `lib/games/chess_ai_stockfish_new.dart` - Stockfish AI для шахмат

## Как работает режим обучения

1. Пользователь нажимает кнопку "Training" в главном меню
2. Показывается диалог с описанием режима обучения
3. `TrainingMode().setEnabled(true)` активирует режим
4. Пользователь выбирает игру для обучения
5. В игре появляется кнопка подсказок (💡)
6. При выходе из игры режим обучения остается активным до выхода в главное меню

## Как интегрировать подсказки в игровой виджет

### 1. Добавьте состояние для подсказок в State класс

```dart
class _GameBoardWidgetState extends State<GameBoardWidget> {
  bool _isLoadingHint = false;
  String? _currentHintText;
  int? _hintMoveFrom;
  int? _hintMoveTo;

  // ... остальной код
}
```

### 2. Добавьте метод для запроса подсказки

#### Для шашек:

```dart
Future<void> _requestHint() async {
  if (_isLoadingHint) return;

  setState(() {
    _isLoadingHint = true;
    _currentHintText = null;
  });

  try {
    final ai = CheckersAI();
    final hint = ai.suggestMoveWithExplanation(
      widget.game,
      3, // depth
      widget.playerColor,
    );

    if (hint != null && mounted) {
      setState(() {
        _hintMoveFrom = hint.move.from;
        _hintMoveTo = hint.move.to;
        _currentHintText = hint.explanation;
      });

      HintSystem.showHint(
        context,
        title: 'Рекомендация AI',
        explanation: hint.explanation,
        moveSuggestion: HintSystem.formatCheckersMove(hint.move.from, hint.move.to),
        onApplyHint: () {
          // Автоматически сделать ход
          widget.game.tryMove(hint.move.from, hint.move.to);
          setState(() {
            _hintMoveFrom = null;
            _hintMoveTo = null;
          });
        },
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoadingHint = false);
    }
  }
}
```

#### Для Тогыз Кумалак:

```dart
Future<void> _requestHint() async {
  if (_isLoadingHint) return;

  setState(() => _isLoadingHint = true);

  try {
    final ai = TogyzKumalakAI();
    final hint = ai.suggestMoveWithExplanation(
      widget.game,
      3, // depth
      widget.playerColor,
    );

    if (hint != null && mounted) {
      HintSystem.showHint(
        context,
        title: 'Рекомендация AI',
        explanation: hint.explanation,
        moveSuggestion: HintSystem.formatTogyzMove(hint.pitNumber),
        onApplyHint: () {
          widget.game.makeMove(hint.move);
          setState(() {});
        },
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoadingHint = false);
    }
  }
}
```

#### Для шахмат:

```dart
Future<void> _requestHint() async {
  if (_isLoadingHint) return;

  setState(() => _isLoadingHint = true);

  try {
    final bestMove = _ai.findBestMove(widget.game, _getAiDifficulty());

    if (bestMove != null && mounted) {
      // Анализируем ход
      final moves = widget.game.game.moves({'verbose': true});
      final moveDetails = moves.firstWhere(
        (m) => m['san'] == bestMove,
        orElse: () => null,
      );

      String explanation = 'Этот ход улучшает вашу позицию';
      if (moveDetails != null && moveDetails['captured'] != null) {
        explanation = 'Этот ход захватывает фигуру противника';
      }

      HintSystem.showHint(
        context,
        title: 'Рекомендация AI',
        explanation: explanation,
        moveSuggestion: HintSystem.formatChessMove(bestMove),
        onApplyHint: () {
          widget.game.makeMoveSAN(bestMove);
          setState(() {});
        },
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoadingHint = false);
    }
  }
}
```

### 3. Добавьте кнопку подсказки в build()

**ВАЖНО:** Кнопка подсказки показывается только если включен режим обучения!

```dart
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Ваша игровая доска
      _buildGameBoard(),

      // Кнопка подсказки (только в режиме обучения и для хода игрока)
      if (HintSystem.isTrainingModeEnabled() && _isPlayerTurn())
        Positioned(
          bottom: 20,
          right: 20,
          child: HintSystem.buildHintButton(
            onPressed: _requestHint,
            isLoading: _isLoadingHint,
          ),
        ),

      // Панель с текущей подсказкой
      if (HintSystem.isTrainingModeEnabled())
        HintSystem.buildHintPanel(
          currentHint: _currentHintText,
          onDismiss: () => setState(() => _currentHintText = null),
        ),
    ],
  );
}
```

### 4. (Опционально) Добавьте визуальное выделение подсказанного хода

Для шашек и шахмат можно выделить клетки:

```dart
// В методе _buildSquare() или аналогичном:
Widget _buildSquare(int index) {
  final isHintFrom = _hintMoveFrom == index;
  final isHintTo = _hintMoveTo == index;

  return Container(
    decoration: BoxDecoration(
      color: _getSquareColor(index),
      border: (isHintFrom || isHintTo)
          ? Border.all(color: Colors.amber, width: 3)
          : null,
      boxShadow: (isHintFrom || isHintTo)
          ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10)]
          : null,
    ),
    child: _buildPiece(index),
  );
}
```

## Улучшения AI

### Шашки (checkers_ai.dart)

**Добавлено:**
- Alpha-beta pruning для быстрого поиска
- Позиционные веса для оценки доски
- Приоритет взятиям и продвижению к дамке
- Оценка контроля центра и защиты фигур
- Метод `suggestMoveWithExplanation()` с анализом хода

**Улучшения оценки:**
- Дамки: 3.0 очка (было 1.5)
- Позиционная оценка для продвижения
- Контроль центральных клеток
- Защищенные фигуры

### Тогыз Кумалак (togyz_kumalak_ai.dart)

**Добавлено:**
- Стратегические веса для разных аспектов игры
- Оценка угроз создания тудзика
- Потенциал захвата кумалаков
- Контроль лунок и распределение
- Штраф за пустые лунки
- Alpha-beta pruning
- Метод `suggestMoveWithExplanation()` с детальным анализом

**Стратегические веса:**
- Тудзик: 15.0 (критически важно!)
- Угроза тудзика: 8.0
- Потенциал захвата: 3.0
- Контроль лунок: 0.5
- Штраф за пустую лунку: 0.3

### Шахматы (chess_ai.dart + chess_ai_stockfish_new.dart)

**Два варианта AI:**
1. **Быстрый AI** (`chess_ai.dart`) - для оффлайн режима
   - Piece-square tables
   - MVV-LVA move ordering
   - Depth 1-3

2. **Stockfish AI** (`chess_ai_stockfish_new.dart`) - профессиональный
   - Skill Level 0-20
   - 10 уровней сложности
   - Работает на всех платформах

## Примеры использования

### Показать подсказку с автоприменением

```dart
HintSystem.showHint(
  context,
  title: 'Лучший ход',
  explanation: 'Этот ход захватывает 5 кумалаков в ваш казан',
  moveSuggestion: 'Рекомендуемый ход: лунка №7',
  onApplyHint: () {
    // Автоматически сделать ход
    game.makeMove(moveIndex);
  },
);
```

### Показать обучающее сообщение

```dart
HintSystem.showTutorialMessage(
  context,
  title: 'Правило тудзика',
  message: 'Когда последний кумалак падает в лунку противника и там становится ровно 3 кумалака, вы можете объявить эту лунку тудзиком.',
  nextStepHint: 'Попробуйте создать тудзик сейчас!',
);
```

### Показать загрузку

```dart
HintSystem.showHintLoading(context);
// ... вычисление хода AI ...
Navigator.pop(context); // закрыть индикатор загрузки
```

## Тестирование

1. Запустите игру в режиме PvP
2. Нажмите кнопку подсказки (💡)
3. Проверьте что:
   - Показывается анализ хода
   - Объяснение понятно
   - Кнопка "Применить" работает
   - Выделение хода на доске (если реализовано)

## Будущие улучшения

- [ ] Множественные варианты ходов (топ-3)
- [ ] Визуализация последствий хода
- [ ] История подсказок в игре
- [ ] Настройка частоты подсказок (для обучения)
- [ ] Система достижений за игру без подсказок
