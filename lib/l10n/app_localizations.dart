import 'package:flutter/material.dart'; // Нужен для Color

class AppLocalizations {
  static const Map<String, String> _ru = {
    // Main Menu
    'language': 'Язык',
    'training': 'Обучение',
    'brightness': 'Яркость',
    'selectLanguage': 'Выберите язык',
    'chess': 'Шахматы',
    'checkers': 'Шашки',
    'togyz': 'Тогыз Кумалак',
    'backgammon': 'Нарды',
    // Setup Screen
    'startGame': 'Начать игру',
    'gameSettings': 'Настройки игры',
    'selectMode': 'Выберите режим',
    'playerVsPlayer': 'Игрок vs Игрок',
    'playerVsAi': 'Игрок vs Компьютер',
    'selectDifficulty': 'Выберите сложность',
    'level': 'Уровень',
    'beginner': 'Новичок',
    'easy': 'Легко',
    'medium': 'Средне',
    'hard': 'Сложно',
    'expert': 'Эксперт',
    'selectSide': 'Выберите сторону',
    'white': 'Белые',
    'black': 'Черные',
    'gameRules': 'Правила игры',
    'rulesFor': 'Правила для',
    // Game Screen
    'player1': 'Игрок 1',
    'player2': 'Игрок 2',
    'computer': 'Компьютер',
    'whitePieces': '(Белые)',
    'blackPieces': '(Черные)',
    'captured': 'Захвачено:',
    'inKazan': 'В казане:',
    'score': 'Счёт:',
    'onBar': 'На баре:',
    'undoMove': 'Отменить ход',
    'resign': 'Сдаться',
    'gameFinished': 'Игра окончена!',
    'whiteWins': 'Победили белые!',
    'blackWins': 'Победили черные!',
    'draw': 'Ничья!',
    'exitToMenu': 'Выйти в меню',
    'playAgain': 'Начать заново',
    'whiteTurn': 'Ход белых',
    'blackTurn': 'Ход черных',
    'rollDice': 'Бросить кубики',
    'exit': 'Выход',
    'exitConfirm': 'Вы уверены, что хотите выйти?',
    'yes': 'Да',
    'no': 'Нет',
    'close': 'Закрыть',
    'exitToMainMenu': 'В главное меню',
    'selectTime': 'Выберите время',
    'noTimer': 'Без таймера',
    'moveHistory': 'История ходов',
    'minutes': 'мин',
    // Training Screen
    'underDevelopment': 'Раздел в разработке',
    'trainingDescription':
        'Здесь будут обучающие материалы и тренировки против ИИ с подсказками.',
    'training_selectGame': 'Выберите игру для обучения',
    'training_selectLesson': 'Выберите урок',
    'training_startTraining': 'Начать обучение',
    'training_aiHints': 'Подсказки ИИ',
    'training_showHints': 'Показать подсказки',
    // Chess Training
    'training_chess_opening': 'Открытие центра',
    'training_chess_kingDefense': 'Защита короля',
    'training_chess_development': 'Развитие фигур',
    'training_chess_fork': 'Тактические удары: Вилка',
    'training_chess_pin': 'Тактические удары: Связка',
    'training_chess_endgame': 'Эндшпиль: Король и пешка',
    // Checkers Training
    'training_checkers_firstMoves': 'Первые ходы',
    'training_checkers_capturing': 'Обязательное взятие',
    'training_checkers_promotion': 'Прорыв в дамки',
    'training_checkers_kingPlay': 'Игра дамкой',
    'training_checkers_blocking': 'Запирание и блокировка',
    // Togyz Training
    'training_togyz_sowing': 'Правила посева',
    'training_togyz_capturing': 'Захват кумалаков',
    'training_togyz_tuzdyk': 'Создание туздыка',
    'training_togyz_centerControl': 'Контроль центра',
    'training_togyz_endgame': 'Эндшпиль',
    // Backgammon Training
    'training_backgammon_movement': 'Основы движения',
    'training_backgammon_primes': 'Стратегия заборов',
    'training_backgammon_hitting': 'Блоты и удары',
    'training_backgammon_enteringBar': 'Вход с бара',
    'training_backgammon_bearOff': 'Вывод шашек',
    'training_backgammon_doubles': 'Тактика дублей',
    // Rules - Common
    'rulesNotFound': 'Правила не найдены.',
    // Rules - Checkers
    'checkersBasicRules': 'Основные правила (Русские шашки)',
    'checkersGoal':
        'Цель игры: Срубить все шашки противника или лишить его возможности хода (\'запереть\').',
    'checkersInitialSetup': 'Начальная расстановка',
    'checkersInitialDesc': 'По 12 шашек на темных полях первых трех рядов.',
    'checkersMovesHeader': 'Ходы',
    'checkersMove1': '1. Ходят только по темным полям.',
    'checkersMove2':
        '2. Простая шашка ходит по диагонали только вперед на 1 свободное поле.',
    'checkersSimpleMoveTitle': 'Простой ход (Нажмите для анимации)',
    'checkersSimpleMoveDesc':
        'Белая шашка (c4) может пойти на d5 или b5 (показан ход на d5).',
    'checkersCaptureHeader': 'Бой',
    'checkersCapture1': '1. Бить обязательно (вперед и назад)!',
    'checkersCapture2':
        '2. Шашка перепрыгивает через шашку противника на следующее свободное поле.',
    'checkersCapture3':
        '3. Если после боя можно бить еще, игрок обязан продолжить.',
    'checkersCaptureExampleTitle': 'Пример боя (Нажмите)',
    'checkersCaptureExampleDesc':
        'Белая шашка (c3) бьет черную (d4) и становится на e5.',
    'checkersMultiCaptureTitle': 'Мульти-бой (Нажмите 2 раза)',
    'checkersMultiCaptureDesc':
        'Белая шашка бьет первую черную, затем вторую за один ход.',
    'checkersKingHeader': 'Дамка',
    'checkersKing1': '1. Шашка, достигшая последнего ряда, становится дамкой.',
    'checkersKing2':
        '2. Дамка ходит и бьет по диагонали на любое число свободных полей.',
    'checkersKingPromotionTitle': 'Превращение в дамку (Нажмите)',
    'checkersKingPromotionDesc':
        'Белая шашка (b7) доходит до последнего ряда (a8) и становится дамкой (визуализация превращения пока не добавлена).',
    'checkersMandatoryCaptureTitle': 'Обязательное взятие',
    'checkersMandatoryCaptureDesc':
        'Если есть возможность бить шашку противника, взятие обязательно. При нескольких вариантах - игрок выбирает.',
    'checkersKingLongCaptureTitle': 'Дальнее взятие дамкой',
    'checkersKingLongCaptureDesc':
        'Дамка бьет на расстоянии - перепрыгивает через шашку противника и приземляется на любое свободное поле за ней.',
    // Rules - Togyz Kumalak
    'togyzRulesHeader': 'Правила Тогыз Кумалак',
    'togyzGoal': 'Цель: Набрать в своем казане 82 или больше кумалаков.',
    'togyzInitialSetupTitle': 'Начальная расстановка',
    'togyzInitialDesc': 'По 9 кумалаков в каждой из 18 лунок (отау).',
    'togyzMoveHeader': 'Ход ("Посев")',
    'togyzMove1': '1. Выберите свою лунку (с кумалаками).',
    'togyzMove2': '2. Возьмите ВСЕ кумалаки (если их > 1, один остается).',
    'togyzMove3':
        '3. Разложите их по одному против часовой стрелки, начиная со СЛЕДУЮЩЕЙ лунки.',
    'togyzSimpleMoveTitle': 'Пример простого хода (Нажмите)',
    'togyzSimpleMoveDesc':
        'Ход из первой лунки (3 кумалака). Один остается, по одному кладутся в лунки 2 и 3.',
    'togyzCaptureHeader': 'Взятие',
    'togyzCaptureRule':
        'Если последний кумалак попадает в лунку противника и там становится ЧЕТНОЕ число, заберите все из нее в свой казан.',
    'togyzCaptureExampleTitle': 'Пример взятия (Нажмите)',
    'togyzCaptureExampleDesc':
        'Ход из лунки 7 (2 кумалака). Последний попадает в лунку 10 (там было 3, стало 4). Все 4 забираются в казан белых.',
    'togyzTuzdykHeader': 'Туздык',
    'togyzTuzdykRule':
        'Если последний кумалак попадает в лунку противника, где было 2 (стало 3), можно объявить ее туздыком (кроме 9-й и симметричной). Кумалаки из туздыка идут в ваш казан.',
    'togyzTuzdykExampleTitle': 'Пример создания Туздыка (Нажмите)',
    'togyzTuzdykExampleDesc':
        'Условно: Белый игрок ходом из 6-й лунки (4 кумалака) делает так, что 3-й кумалак попадает в лунку 2 черных (индекс 10), где было 2. Становится 3. Белый объявляет туздык.',
    'togyzWinConditionTitle': 'Условия победы',
    'togyzWinConditionDesc':
        'Игра заканчивается, когда один игрок набирает 82+ кумалака в казане, или когда у противника не остается возможных ходов.',
    'togyzStrategyTitle': 'Стратегические советы',
    'togyzStrategyDesc':
        'Защищайте свои лунки с 2 кумалаками, чтобы противник не сделал туздык. Старайтесь создать свой туздык в лунке с большим трафиком.',
    // Дополнительные правила Тогыз Кумалак
    'togyzAutoCaptureTitle': 'Автозахват туздыком',
    'togyzAutoCaptureDesc':
        'Когда кумалак попадает в туздык противника, он автоматически идет в казан владельца туздыка.',
    'togyzTuzdykRestrictionsTitle': 'Ограничения на создание туздыка',
    'togyzTuzdykRestrictionsDesc':
        '1. Только на стороне противника\n2. Только когда там ровно 3 кумалака\n3. Нельзя в 9-й лунке\n4. Нельзя в симметричной лунке (если у противника уже есть туздык)\n5. Только один туздык на игрока',
    'togyzEmptyPitRuleTitle': 'Нельзя ходить из пустой лунки',
    'togyzEmptyPitRuleDesc':
        'Вы можете ходить только из лунок, где есть хотя бы один кумалак.',
    'togyzAtsyrauTitle': 'Атсырау (Конец игры)',
    'togyzAtsyrauDesc':
        'Когда один игрок не может сделать ход, игра заканчивается. Все оставшиеся кумалаки на его стороне достаются противнику.',
    'togyzNoCaptureSameTitle': 'Нельзя захватить свою лунку',
    'togyzNoCaptureSameDesc':
        'Захват работает только когда последний кумалак попадает на сторону ПРОТИВНИКА. Свои лунки захватить нельзя.',
    'togyzContinuingMoveTitle': 'Цепочка раздачи',
    'togyzContinuingMoveDesc':
        'Если в лунке много кумалаков, они раскладываются по кругу против часовой стрелки, проходя все 18 лунок (пропуская только исходную).',
    'togyzTuzdykOnlyOnceTitle': 'Туздык создается один раз',
    'togyzTuzdykOnceDesc':
        'Каждый игрок может создать только ОДИН туздык за всю игру. После создания туздык остается до конца партии.',
    'togyzOneRemainsTitle': 'Один кумалак всегда остается',
    'togyzOneRemainsDesc':
        'При раздаче из лунки, где больше одного кумалака, ОДИН всегда остается в исходной лунке. Только если кумалак один - он уходит полностью.',
    'togyzNo9thPitTitle': 'Запрет туздыка на 9-й лунке',
    'togyzNo9thPitDesc':
        '9-я лунка (крайняя справа) - особая. В ней НЕЛЬЗЯ создать туздык. Это правило защищает самую важную стратегическую позицию.',
    'togyzDrawTitle': 'Ничья',
    'togyzDrawDesc':
        'Если игра заканчивается с равным счетом 81-81 (что крайне редко), объявляется ничья. В этом случае победителя нет.',
    'togyzScoreCountTitle': 'Подсчет очков',
    'togyzScoreCountDesc':
        'Всего 162 кумалака в игре. Победитель должен набрать 82+. Следите за казаном - число показывает ваш текущий счет.',
    // Rules - Chess
    'chessRulesHeader': 'Правила Шахмат',
    'chessGoal': 'Цель игры: Поставить мат королю противника.',
    'chessInitialSetupTitle': 'Начальная расстановка',
    'chessMovesHeader': 'Ходы Фигур',
    'chessPawnRule':
        'Пешка (♙/♟︎): Вперед на 1 (или 2 с нач. позиции). Бьет по диагонали.',
    'chessPawnMoveTitle': 'Ход пешки (Нажмите)',
    'chessPawnMoveDesc': 'Начальный ход пешки на 2 поля.',
    'chessPawnCaptureTitle': 'Взятие пешкой (Нажмите)',
    'chessPawnCaptureDesc': 'Белая пешка e3 бьет черную d4.',
    'chessKnightRule': 'Конь (♘/♞): Ходит буквой "Г". Перепрыгивает фигуры.',
    'chessKnightMoveTitle': 'Ход коня (Нажмите)',
    'chessKnightMoveDesc':
        'Конь ходит на 2 поля в одном направлении и 1 в перпендикулярном.',
    'chessBishopRule': 'Слон (♗/♝): Ходит по диагонали.',
    'chessRookRule': 'Ладья (♖/♜): Ходит по вертикали/горизонтали.',
    'chessQueenRule': 'Ферзь (♕/♛): Ходит как ладья + слон.',
    'chessKingRule': 'Король (♔/♚): Ходит на 1 поле в любую сторону.',
    'chessCastlingTitle': 'Рокировка (Нажмите)',
    'chessCastlingDesc':
        'Короткая рокировка белых (0-0). Король и ладья ходят одновременно (анимация показывает только короля).',
    'chessEnPassantTitle': 'Взятие на проходе',
    'chessEnPassantDesc':
        'Если пешка противника делает ход на 2 клетки и встает рядом с вашей пешкой, вы можете взять её "на проходе".',
    'chessPromotionTitle': 'Превращение пешки',
    'chessPromotionDesc':
        'Когда пешка достигает последней горизонтали, она превращается в ферзя, ладью, слона или коня.',
    'chessCheckTitle': 'Шах, мат и пат',
    'chessCheckDesc':
        'Шах - король под атакой. Мат - король под шахом, нет спасения. Пат - нет ходов, король не под шахом (ничья).',
    'chessRookMoveDesc':
        'Ладья ходит по прямым линиям - вертикально или горизонтально на любое количество клеток.',
    'chessBishopMoveDesc':
        'Слон ходит по диагоналям на любое количество клеток. Каждый слон всю игру остается на своем цвете.',
    'chessQueenMoveDesc':
        'Ферзь - самая сильная фигура. Сочетает ходы ладьи и слона - по прямым и диагоналям.',
    'chessCheckmateTitle': 'Мат королю',
    'chessCheckmateDesc':
        'Мат - король под атакой и не может спастись. Игра окончена, атакующая сторона побеждает.',
    // Rules - Backgammon
    'backgammonRulesHeader': 'Правила Нард (Длинные)',
    'backgammonGoal': 'Цель: Первым вывести все 15 шашек с доски.',
    'backgammonInitialSetupTitle': 'Начальная расстановка',
    'backgammonMoveHeader': 'Ход',
    'backgammonMove1': '1. Бросьте кубики.',
    'backgammonMove2':
        '2. Передвиньте шашки на число пунктов, выпавшее на кубиках. Дубль играется 4 раза.',
    'backgammonMove3':
        '3. Можно походить одной шашкой на сумму или двумя шашками на каждое значение.',
    'backgammonMove4': '4. Нельзя ставить на пункт, занятый противником.',
    'backgammonMoveExampleTitle': 'Пример хода (Нажмите)',
    'backgammonMoveExampleDesc':
        'Белые выбросили 5-2. Они ходят двумя шашками с пункта 19 (индекс 18) на 24 (индекс 23) и 21 (индекс 20).',
    'backgammonHitHeader': 'Битьё шашки',
    'backgammonHitRule':
        'Если вы ставите шашку на пункт, где стоит ОДНА шашка противника (блот), она считается сбитой и отправляется на бар.',
    'backgammonHitExampleTitle': 'Пример битья (Нажмите)',
    'backgammonHitExampleDesc':
        'Белые выбросили 3. Шашка с пункта 1 (индекс 0) идет на пункт 4 (индекс 3), сбивая черную шашку на бар.',
    'backgammonBarHeader': 'Вход с бара',
    'backgammonBarRule':
        'Сбитые шашки должны сначала войти в игру в \'доме\' противника (пункты 1-6 для белых, 19-24 для черных).',
    'backgammonBearOffHeader': 'Вывод из дома',
    'backgammonBearOffRule':
        'Выводить шашки можно, только когда все 15 шашек находятся в вашем доме (пункты 19-24 для белых, 1-6 для черных).',
    'backgammonDoublesTitle': 'Дубли (парные кости)',
    'backgammonDoublesDesc':
        'Если выпал дубль (две одинаковые кости), вы ходите 4 раза на это значение. Например, 3-3 = четыре хода по 3.',
    'backgammonBlockadeTitle': 'Блокада и защита',
    'backgammonBlockadeDesc':
        'Занимайте пункты двумя или более шашками - они безопасны. Шесть подряд пунктов создают "прайм" - непреодолимую стену.',
    'backgammonWinConditionsTitle': 'Условия победы',
    'backgammonWinConditionsDesc':
        'Обычная победа - вывели все шашки. Гаммон (x2) - противник не вывел ни одной. Бэкгаммон (x3) - противник не вывел ни одной и у него есть шашки в вашем доме или на баре.',
  };

  static const Map<String, String> _en = {
    'language': 'Language',
    'training': 'Training',
    'selectLanguage': 'Select Language',
    'chess': 'Chess',
    'checkers': 'Checkers',
    'togyz': 'Togyz Kumalak',
    'backgammon': 'Backgammon',
    'startGame': 'Start Game',
    'gameSettings': 'Game Settings',
    'selectMode': 'Select Mode',
    'playerVsPlayer': 'Player vs Player',
    'playerVsAi': 'Player vs AI',
    'selectDifficulty': 'Select Difficulty',
    'level': 'Level',
    'beginner': 'Beginner',
    'easy': 'Easy',
    'medium': 'Medium',
    'hard': 'Hard',
    'expert': 'Expert',
    'selectSide': 'Select Side',
    'white': 'White',
    'black': 'Black',
    'gameRules': 'Game Rules',
    'rulesFor': 'Rules for',
    'player1': 'Player 1',
    'player2': 'Player 2',
    'computer': 'Computer',
    'whitePieces': '(White)',
    'blackPieces': '(Black)',
    'captured': 'Captured:',
    'inKazan': 'In Kazan:',
    'score': 'Score:',
    'onBar': 'On Bar:',
    'undoMove': 'Undo Move',
    'resign': 'Resign',
    'gameFinished': 'Game Finished!',
    'whiteWins': 'White Wins!',
    'blackWins': 'Black Wins!',
    'draw': 'Draw!',
    'exitToMenu': 'Exit to Menu',
    'playAgain': 'Play Again',
    'whiteTurn': 'White\'s Turn',
    'blackTurn': 'Black\'s Turn',
    'rollDice': 'Roll Dice',
    'exit': 'Exit',
    'exitConfirm': 'Are you sure you want to exit?',
    'yes': 'Yes',
    'no': 'No',
    'close': 'Close',
    'exitToMainMenu': 'Main Menu',
    'selectTime': 'Select Time',
    'noTimer': 'No Timer',
    'moveHistory': 'Move History',
    'minutes': 'min',
    // Training Screen
    'underDevelopment': 'Under Development',
    'trainingDescription':
        'Training materials and practice against AI with hints will be available here.',
    'training_selectGame': 'Select a game to train',
    'training_selectLesson': 'Select a lesson',
    'training_startTraining': 'Start Training',
    'training_aiHints': 'AI Hints',
    'training_showHints': 'Show Hints',
    // Chess Training
    'training_chess_opening': 'Center Opening',
    'training_chess_kingDefense': 'King Defense',
    'training_chess_development': 'Piece Development',
    'training_chess_fork': 'Tactical Strikes: Fork',
    'training_chess_pin': 'Tactical Strikes: Pin',
    'training_chess_endgame': 'Endgame: King and Pawn',
    // Checkers Training
    'training_checkers_firstMoves': 'First Moves',
    'training_checkers_capturing': 'Mandatory Capture',
    'training_checkers_promotion': 'Breaking Through to King',
    'training_checkers_kingPlay': 'Playing with King',
    'training_checkers_blocking': 'Trapping and Blocking',
    // Togyz Training
    'training_togyz_sowing': 'Sowing Rules',
    'training_togyz_capturing': 'Capturing Kumalaks',
    'training_togyz_tuzdyk': 'Creating Tuzdyk',
    'training_togyz_centerControl': 'Center Control',
    'training_togyz_endgame': 'Endgame',
    // Backgammon Training
    'training_backgammon_movement': 'Movement Basics',
    'training_backgammon_primes': 'Prime Strategy',
    'training_backgammon_hitting': 'Blots and Hitting',
    'training_backgammon_enteringBar': 'Entering from Bar',
    'training_backgammon_bearOff': 'Bearing Off',
    'training_backgammon_doubles': 'Doubles Tactics',
    // Rules - Common
    'rulesNotFound': 'Rules not found.',
    // Rules - Checkers
    'checkersBasicRules': 'Basic Rules (Russian Checkers)',
    'checkersGoal':
        'Goal: Capture all opponent\'s pieces or block them (no legal moves).',
    'checkersInitialSetup': 'Initial Setup',
    'checkersInitialDesc':
        '12 pieces each on dark squares of the first three rows.',
    'checkersMovesHeader': 'Moves',
    'checkersMove1': '1. Only move on dark squares.',
    'checkersMove2': '2. Regular piece moves diagonally forward 1 square.',
    'checkersSimpleMoveTitle': 'Simple Move (Click to animate)',
    'checkersSimpleMoveDesc':
        'White piece (c4) can move to d5 or b5 (shown move to d5).',
    'checkersCaptureHeader': 'Capture',
    'checkersCapture1': '1. Capturing is mandatory (forward and backward)!',
    'checkersCapture2':
        '2. Piece jumps over opponent\'s piece to the next empty square.',
    'checkersCapture3':
        '3. If after capture another capture is possible, player must continue.',
    'checkersCaptureExampleTitle': 'Capture Example (Click)',
    'checkersCaptureExampleDesc':
        'White piece (c3) captures black (d4) and lands on e5.',
    'checkersMultiCaptureTitle': 'Multi-capture (Click 2 times)',
    'checkersMultiCaptureDesc':
        'White piece captures first black, then second in one move.',
    'checkersKingHeader': 'King',
    'checkersKing1': '1. Piece reaching the last row becomes a king.',
    'checkersKing2':
        '2. King moves and captures diagonally any number of free squares.',
    'checkersKingPromotionTitle': 'Promotion to King (Click)',
    'checkersKingPromotionDesc':
        'White piece (b7) reaches last row (a8) and becomes a king (promotion visualization not yet added).',
    'checkersMandatoryCaptureTitle': 'Mandatory Capture',
    'checkersMandatoryCaptureDesc':
        'If you can capture an opponent\'s piece, you must. If multiple captures are possible - player chooses.',
    'checkersKingLongCaptureTitle': 'Long-range King Capture',
    'checkersKingLongCaptureDesc':
        'King captures at distance - jumps over opponent\'s piece and lands on any free square beyond it.',
    // Rules - Togyz Kumalak
    'togyzRulesHeader': 'Togyz Kumalak Rules',
    'togyzGoal': 'Goal: Collect 82 or more kumalaks in your kazan.',
    'togyzInitialSetupTitle': 'Initial Setup',
    'togyzInitialDesc': '9 kumalaks in each of 18 pits (otau).',
    'togyzMoveHeader': 'Move ("Sowing")',
    'togyzMove1': '1. Select your pit (with kumalaks).',
    'togyzMove2': '2. Take ALL kumalaks (if > 1, one remains).',
    'togyzMove3':
        '3. Distribute them one by one counter-clockwise, starting from the NEXT pit.',
    'togyzSimpleMoveTitle': 'Simple Move Example (Click)',
    'togyzSimpleMoveDesc':
        'Move from first pit (3 kumalaks). One remains, one each goes to pits 2 and 3.',
    'togyzCaptureHeader': 'Capture',
    'togyzCaptureRule':
        'If the last kumalak lands in opponent\'s pit making it EVEN, take all from it to your kazan.',
    'togyzCaptureExampleTitle': 'Capture Example (Click)',
    'togyzCaptureExampleDesc':
        'Move from pit 7 (2 kumalaks). Last one lands in pit 10 (was 3, becomes 4). All 4 go to white\'s kazan.',
    'togyzTuzdykHeader': 'Tuzdyk',
    'togyzTuzdykRule':
        'If last kumalak lands in opponent\'s pit where there were 2 (becomes 3), can declare it tuzdyk (except 9th and symmetric). Kumalaks from tuzdyk go to your kazan.',
    'togyzTuzdykExampleTitle': 'Tuzdyk Creation Example (Click)',
    'togyzTuzdykExampleDesc':
        'Conditionally: White player moves from 6th pit (4 kumalaks) so 3rd kumalak lands in black\'s pit 2 (index 10), where there were 2. Becomes 3. White declares tuzdyk.',
    'togyzWinConditionTitle': 'Win Conditions',
    'togyzWinConditionDesc':
        'Game ends when a player collects 82+ kumalaks in their kazan, or when opponent has no legal moves left.',
    'togyzStrategyTitle': 'Strategic Tips',
    'togyzStrategyDesc':
        'Protect your pits with 2 kumalaks to prevent opponent tuzdyk. Try to create your tuzdyk in a high-traffic pit.',
    // Additional Togyz Kumalak rules
    'togyzAutoCaptureTitle': 'Auto-capture by Tuzdyk',
    'togyzAutoCaptureDesc':
        'When a kumalak lands in opponent\'s tuzdyk, it automatically goes to the tuzdyk owner\'s kazan.',
    'togyzTuzdykRestrictionsTitle': 'Tuzdyk Creation Restrictions',
    'togyzTuzdykRestrictionsDesc':
        '1. Only on opponent\'s side\n2. Only when exactly 3 kumalaks\n3. Not in the 9th pit\n4. Not in symmetric pit (if opponent has tuzdyk there)\n5. Only one tuzdyk per player',
    'togyzEmptyPitRuleTitle': 'Cannot move from empty pit',
    'togyzEmptyPitRuleDesc':
        'You can only move from pits that have at least one kumalak.',
    'togyzAtsyrauTitle': 'Atsyrau (End Game)',
    'togyzAtsyrauDesc':
        'When one player cannot make a move, the game ends. All remaining kumalaks on their side go to the opponent.',
    'togyzNoCaptureSameTitle': 'Cannot capture your own pit',
    'togyzNoCaptureSameDesc':
        'Capture only works when the last kumalak lands on OPPONENT\'S side. You cannot capture your own pits.',
    'togyzContinuingMoveTitle': 'Distribution Chain',
    'togyzContinuingMoveDesc':
        'If a pit has many kumalaks, they are distributed counter-clockwise around all 18 pits (skipping only the starting pit).',
    'togyzTuzdykOnlyOnceTitle': 'Tuzdyk created once',
    'togyzTuzdykOnceDesc':
        'Each player can create only ONE tuzdyk per game. Once created, tuzdyk remains until the end of the match.',
    'togyzOneRemainsTitle': 'One kumalak always remains',
    'togyzOneRemainsDesc':
        'When distributing from a pit with more than one kumalak, ONE always stays in the original pit. Only if there is one kumalak - it leaves completely.',
    'togyzNo9thPitTitle': 'No tuzdyk on 9th pit',
    'togyzNo9thPitDesc':
        'The 9th pit (far right) is special. You CANNOT create a tuzdyk there. This rule protects the most important strategic position.',
    'togyzDrawTitle': 'Draw',
    'togyzDrawDesc':
        'If the game ends with equal score 81-81 (which is extremely rare), a draw is declared. In this case there is no winner.',
    'togyzScoreCountTitle': 'Score Counting',
    'togyzScoreCountDesc':
        'Total 162 kumalaks in the game. Winner must collect 82+. Watch your kazan - the number shows your current score.',
    // Rules - Chess
    'chessRulesHeader': 'Chess Rules',
    'chessGoal': 'Goal: Checkmate the opponent\'s king.',
    'chessInitialSetupTitle': 'Initial Setup',
    'chessMovesHeader': 'Piece Moves',
    'chessPawnRule':
        'Pawn (♙/♟︎): Forward 1 (or 2 from start). Captures diagonally.',
    'chessPawnMoveTitle': 'Pawn Move (Click)',
    'chessPawnMoveDesc': 'Initial pawn move 2 squares.',
    'chessPawnCaptureTitle': 'Pawn Capture (Click)',
    'chessPawnCaptureDesc': 'White pawn e3 captures black d4.',
    'chessKnightRule': 'Knight (♘/♞): Moves in "L" shape. Jumps over pieces.',
    'chessKnightMoveTitle': 'Knight Move (Click)',
    'chessKnightMoveDesc':
        'Knight moves 2 squares in one direction and 1 perpendicular.',
    'chessBishopRule': 'Bishop (♗/♝): Moves diagonally.',
    'chessRookRule': 'Rook (♖/♜): Moves vertically/horizontally.',
    'chessQueenRule': 'Queen (♕/♛): Moves like rook + bishop.',
    'chessKingRule': 'King (♔/♚): Moves 1 square in any direction.',
    'chessCastlingTitle': 'Castling (Click)',
    'chessCastlingDesc':
        'White short castle (0-0). King and rook move simultaneously (animation shows only king).',
    'chessEnPassantTitle': 'En Passant',
    'chessEnPassantDesc':
        'If opponent\'s pawn moves 2 squares and lands beside your pawn, you can capture it "en passant".',
    'chessPromotionTitle': 'Pawn Promotion',
    'chessPromotionDesc':
        'When a pawn reaches the last rank, it promotes to a queen, rook, bishop, or knight.',
    'chessCheckTitle': 'Check, Checkmate & Stalemate',
    'chessCheckDesc':
        'Check - king is attacked. Checkmate - king is in check with no escape. Stalemate - no legal moves, king not in check (draw).',
    'chessRookMoveDesc':
        'Rook moves in straight lines - vertically or horizontally for any number of squares.',
    'chessBishopMoveDesc':
        'Bishop moves diagonally for any number of squares. Each bishop stays on its color throughout the game.',
    'chessQueenMoveDesc':
        'Queen - the most powerful piece. Combines rook and bishop moves - straight and diagonal.',
    'chessCheckmateTitle': 'Checkmate',
    'chessCheckmateDesc':
        'Checkmate - king is under attack and cannot escape. Game over, attacking side wins.',
    // Rules - Backgammon
    'backgammonRulesHeader': 'Backgammon Rules (Long)',
    'backgammonGoal': 'Goal: First to bear off all 15 checkers.',
    'backgammonInitialSetupTitle': 'Initial Setup',
    'backgammonMoveHeader': 'Move',
    'backgammonMove1': '1. Roll the dice.',
    'backgammonMove2':
        '2. Move checkers by the number shown. Doubles are played 4 times.',
    'backgammonMove3':
        '3. Can move one checker by sum or two checkers by each value.',
    'backgammonMove4': '4. Cannot land on point occupied by opponent.',
    'backgammonMoveExampleTitle': 'Move Example (Click)',
    'backgammonMoveExampleDesc':
        'White rolled 5-2. They move two checkers from point 19 (index 18) to 24 (index 23) and 21 (index 20).',
    'backgammonHitHeader': 'Hitting',
    'backgammonHitRule':
        'If you land on a point with ONE opponent checker (blot), it\'s hit and goes to the bar.',
    'backgammonHitExampleTitle': 'Hit Example (Click)',
    'backgammonHitExampleDesc':
        'White rolled 3. Checker from point 1 (index 0) moves to point 4 (index 3), hitting black checker to bar.',
    'backgammonBarHeader': 'Entering from Bar',
    'backgammonBarRule':
        'Hit checkers must first enter in opponent\'s home (points 1-6 for white, 19-24 for black).',
    'backgammonBearOffHeader': 'Bearing Off',
    'backgammonBearOffRule':
        'Can bear off only when all 15 checkers are in your home (points 19-24 for white, 1-6 for black).',
    'backgammonDoublesTitle': 'Doubles (Matching Dice)',
    'backgammonDoublesDesc':
        'If you roll doubles (same on both dice), you move 4 times that value. For example, 3-3 = four moves of 3.',
    'backgammonBlockadeTitle': 'Blockade and Defense',
    'backgammonBlockadeDesc':
        'Occupy points with two or more checkers - they\'re safe. Six consecutive points create a "prime" - an impassable wall.',
    'backgammonWinConditionsTitle': 'Win Conditions',
    'backgammonWinConditionsDesc':
        'Regular win - bore off all checkers. Gammon (x2) - opponent bore off none. Backgammon (x3) - opponent bore off none and has checkers in your home or on bar.',
  };

  static const Map<String, String> _kz = {
    'language': 'Тіл',
    'training': 'Оқыту',
    'selectLanguage': 'Тілді таңдаңыз',
    'chess': 'Шахмат',
    'checkers': 'Дойбы',
    'togyz': 'Тоғызқұмалақ',
    'backgammon': 'Нарды',
    'startGame': 'Ойынды бастау',
    'gameSettings': 'Ойын баптаулары',
    'selectMode': 'Режимді таңдаңыз',
    'playerVsPlayer': 'Ойыншы vs Ойыншы',
    'playerVsAi': 'Ойыншы vs Компьютер',
    'selectDifficulty': 'Қиындықты таңдаңыз',
    'level': 'Деңгей',
    'beginner': 'Жаңадан бастаушы',
    'easy': 'Оңай',
    'medium': 'Орташа',
    'hard': 'Қиын',
    'expert': 'Сарапшы',
    'selectSide': 'Тарапты таңдаңыз',
    'white': 'Ақ',
    'black': 'Қара',
    'gameRules': 'Ойын ережелері',
    'rulesFor': 'Ережелер:',
    'player1': '1-ойыншы',
    'player2': '2-ойыншы',
    'computer': 'Компьютер',
    'whitePieces': '(Ақтар)',
    'blackPieces': '(Қаралар)',
    'captured': 'Ұсталды:',
    'inKazan': 'Қазанда:',
    'score': 'Есеп:',
    'onBar': 'Барда:',
    'undoMove': 'Кері қайтару',
    'resign': 'Берілу',
    'gameFinished': 'Ойын аяқталды!',
    'whiteWins': 'Ақтар жеңді!',
    'blackWins': 'Қаралар жеңді!',
    'draw': 'Тең ойын!',
    'exitToMenu': 'Мәзірге шығу',
    'playAgain': 'Қайта бастау',
    'whiteTurn': 'Ақтардың жүрісі',
    'blackTurn': 'Қаралардың жүрісі',
    'rollDice': 'Сүйек лақтыру',
    'exit': 'Шығу',
    'exitConfirm': 'Шығуға сенімдісіз бе?',
    'yes': 'Иә',
    'no': 'Жоқ',
    'close': 'Жабу',
    'exitToMainMenu': 'Басты мәзірге',
    'selectTime': 'Уақытты таңдаңыз',
    'noTimer': 'Таймерсіз',
    'moveHistory': 'Жүрістер тарихы',
    'minutes': 'мин',
    // Training Screen
    'underDevelopment': 'Бөлім әзірленуде',
    'trainingDescription':
        'Мұнда оқу материалдары және AI-мен жаттығулар болады.',
    'training_selectGame': 'Оқыту үшін ойын таңдаңыз',
    'training_selectLesson': 'Сабақ таңдаңыз',
    'training_startTraining': 'Оқытуды бастау',
    'training_aiHints': 'AI кеңестері',
    'training_showHints': 'Кеңестерді көрсету',
    // Chess Training
    'training_chess_opening': 'Орталықты ашу',
    'training_chess_kingDefense': 'Патшаны қорғау',
    'training_chess_development': 'Фигураларды дамыту',
    'training_chess_fork': 'Тактикалық соққылар: Айыр',
    'training_chess_pin': 'Тактикалық соққылар: Байлау',
    'training_chess_endgame': 'Эндшпиль: Патша және пешка',
    // Checkers Training
    'training_checkers_firstMoves': 'Алғашқы жүрістер',
    'training_checkers_capturing': 'Міндетті алу',
    'training_checkers_promotion': 'Дамаға өту',
    'training_checkers_kingPlay': 'Дамамен ойнау',
    'training_checkers_blocking': 'Қоршау және блоктау',
    // Togyz Training
    'training_togyz_sowing': 'Себу ережелері',
    'training_togyz_capturing': 'Құмалақтарды алу',
    'training_togyz_tuzdyk': 'Тұздық құру',
    'training_togyz_centerControl': 'Орталықты бақылау',
    'training_togyz_endgame': 'Эндшпиль',
    // Backgammon Training
    'training_backgammon_movement': 'Жылжу негіздері',
    'training_backgammon_primes': 'Қоршау стратегиясы',
    'training_backgammon_hitting': 'Блоттар және ұру',
    'training_backgammon_enteringBar': 'Бардан кіру',
    'training_backgammon_bearOff': 'Тастарды шығару',
    'training_backgammon_doubles': 'Дубль тактикасы',
    // Rules - Common
    'rulesNotFound': 'Ережелер табылмады.',
    // Rules - Checkers
    'checkersBasicRules': 'Негізгі ережелер (Орыс дойбысы)',
    'checkersGoal':
        'Мақсат: Қарсыластың барлық тастарын алу немесе жүру мүмкіндігін жою.',
    'checkersInitialSetup': 'Бастапқы орналасу',
    'checkersInitialDesc':
        'Алғашқы үш қатардың қара торларында әрқайсысында 12 тас.',
    'checkersMovesHeader': 'Жүрістер',
    'checkersMove1': '1. Тек қара торларда жүру.',
    'checkersMove2':
        '2. Қарапайым тас диагональ бойынша тек алға 1 бос торға жүреді.',
    'checkersSimpleMoveTitle': 'Қарапайым жүріс (Анимация үшін басыңыз)',
    'checkersSimpleMoveDesc':
        'Ақ тас (c4) d5 немесе b5 жүре алады (d5-ке жүріс көрсетілген).',
    'checkersCaptureHeader': 'Алу',
    'checkersCapture1': '1. Алу міндетті (алға және артқа)!',
    'checkersCapture2':
        '2. Тас қарсыластың тасынан секіріп, келесі бос торға түседі.',
    'checkersCapture3':
        '3. Алғаннан кейін тағы алу мүмкін болса, ойыншы жалғастыруы керек.',
    'checkersCaptureExampleTitle': 'Алу мысалы (Басыңыз)',
    'checkersCaptureExampleDesc': 'Ақ тас (c3) қараны (d4) алып, e5-ке түседі.',
    'checkersMultiCaptureTitle': 'Көп алу (2 рет басыңыз)',
    'checkersMultiCaptureDesc':
        'Ақ тас бірінші қараны, содан кейін екіншісін бір жүріспен алады.',
    'checkersKingHeader': 'Дама',
    'checkersKing1': '1. Соңғы қатарға жеткен тас дамаға айналады.',
    'checkersKing2':
        '2. Дама диагональ бойынша кез келген санда бос торға жүреді және алады.',
    'checkersKingPromotionTitle': 'Дамаға айналу (Басыңыз)',
    'checkersKingPromotionDesc':
        'Ақ тас (b7) соңғы қатарға (a8) жетіп, дамаға айналады (визуализация әлі қосылмаған).',
    'checkersMandatoryCaptureTitle': 'Міндетті алу',
    'checkersMandatoryCaptureDesc':
        'Қарсылас тасын алуға мүмкіндік болса, алу міндетті. Бірнеше нұсқа болса - ойыншы таңдайды.',
    'checkersKingLongCaptureTitle': 'Дамамен алыстан алу',
    'checkersKingLongCaptureDesc':
        'Дама қашықтықта алады - қарсылас тасынан секіріп, артындағы кез келген бос торға түседі.',
    // Rules - Togyz Kumalak
    'togyzRulesHeader': 'Тоғызқұмалақ ережелері',
    'togyzGoal': 'Мақсат: Қазанда 82 немесе одан көп құмалақ жинау.',
    'togyzInitialSetupTitle': 'Бастапқы орналасу',
    'togyzInitialDesc': '18 отаудың әрқайсысында 9 құмалақ.',
    'togyzMoveHeader': 'Жүріс ("Себу")',
    'togyzMove1': '1. Өз отауыңызды (құмалақтары бар) таңдаңыз.',
    'togyzMove2':
        '2. БАРЛЫҚ құмалақтарды алыңыз (егер > 1 болса, біреуі қалады).',
    'togyzMove3':
        '3. Оларды бір-бірден сағат тіліне қарсы бағытта, КЕЛЕСІ отаудан бастап таратыңыз.',
    'togyzSimpleMoveTitle': 'Қарапайым жүріс мысалы (Басыңыз)',
    'togyzSimpleMoveDesc':
        'Бірінші отаудан жүріс (3 құмалақ). Біреуі қалады, әрқайсысы 2 және 3 отауларға салынады.',
    'togyzCaptureHeader': 'Алу',
    'togyzCaptureRule':
        'Егер соңғы құмалақ қарсыластың отауына түсіп, ЖҰП сан жасаса, барлығын өз қазаныңызға алыңыз.',
    'togyzCaptureExampleTitle': 'Алу мысалы (Басыңыз)',
    'togyzCaptureExampleDesc':
        '7-отаудан жүріс (2 құмалақ). Соңғысы 10-отауға түседі (3 болды, 4 болды). Барлық 4-еуі ақтардың қазанына түседі.',
    'togyzTuzdykHeader': 'Тұздық',
    'togyzTuzdykRule':
        'Егер соңғы құмалақ қарсыластың отауына түсіп, онда 2 болса (3 болады), оны тұздық деп жариялауға болады (9-шы және симметриялы қоспағанда). Тұздықтан құмалақтар сіздің қазаныңызға барады.',
    'togyzTuzdykExampleTitle': 'Тұздық құру мысалы (Басыңыз)',
    'togyzTuzdykExampleDesc':
        'Шартты түрде: Ақ ойыншы 6-отаудан жүріс жасап (4 құмалақ), 3-ші құмалақ қаралардың 2-отауына (10 индекс) түседі, онда 2 болды. 3 болады. Ақ тұздық жариялайды.',
    'togyzWinConditionTitle': 'Жеңіс шарттары',
    'togyzWinConditionDesc':
        'Ойын аяқталады, егер ойыншы өз қазанында 82+ құмалақ жинаса, немесе қарсыласта заңды жүрістер қалмаса.',
    'togyzStrategyTitle': 'Стратегиялық кеңестер',
    'togyzStrategyDesc':
        '2 құмалағы бар отауларыңызды қорғаңыз, қарсылас тұздық жасамау үшін. Қозғалыс көп отауда өз тұздығыңызды жасауға тырысыңыз.',
    // Қосымша Тоғызқұмалақ ережелері
    'togyzAutoCaptureTitle': 'Тұздықпен автоматты алу',
    'togyzAutoCaptureDesc':
        'Құмалақ қарсыластың тұздығына түскенде, ол автоматты түрде тұздық иесінің қазанына барады.',
    'togyzTuzdykRestrictionsTitle': 'Тұздық жасаудағы шектеулер',
    'togyzTuzdykRestrictionsDesc':
        '1. Тек қарсылас тарапында\n2. Тек дәл 3 құмалақ болғанда\n3. 9-шы отауда болмайды\n4. Симметриялық отауда болмайды (қарсыласта тұздық болса)\n5. Ойыншыға тек бір тұздық',
    'togyzEmptyPitRuleTitle': 'Бос отаудан жүруге болмайды',
    'togyzEmptyPitRuleDesc':
        'Тек кем дегенде бір құмалағы бар отаулардан жүруге болады.',
    'togyzAtsyrauTitle': 'Атсырау (Ойын соңы)',
    'togyzAtsyrauDesc':
        'Бір ойыншы жүре алмаса, ойын аяқталады. Оның тарапындағы барлық қалған құмалақтар қарсыласқа тиеді.',
    'togyzNoCaptureSameTitle': 'Өз отауыңызды алуға болмайды',
    'togyzNoCaptureSameDesc':
        'Алу тек соңғы құмалақ ҚАРСЫЛАСТЫҢ тарапына түскенде жұмыс істейді. Өз отауларыңызды алуға болмайды.',
    'togyzContinuingMoveTitle': 'Үлестіру тізбегі',
    'togyzContinuingMoveDesc':
        'Отауда көп құмалақ болса, олар барлық 18 отауды айнала сағат тіліне қарсы бөлінеді (тек бастапқы отауды аттап өтіп).',
    'togyzTuzdykOnlyOnceTitle': 'Тұздық бір рет жасалады',
    'togyzTuzdykOnceDesc':
        'Әр ойыншы ойын басына тек БІР тұздық жасай алады. Жасалғаннан кейін тұздық партия соңына дейін қалады.',
    'togyzOneRemainsTitle': 'Бір құмалақ әрқашан қалады',
    'togyzOneRemainsDesc':
        'Бірден көп құмалағы бар отаудан үлестіргенде, БІР құмалақ әрқашан бастапқы отауда қалады. Тек бір құмалақ болса ғана - ол толығымен кетеді.',
    'togyzNo9thPitTitle': '9-шы отауда тұздық жоқ',
    'togyzNo9thPitDesc':
        '9-шы отау (оң жақтағы) ерекше. Онда тұздық жасауға БОЛМАЙДЫ. Бұл ереже ең маңызды стратегиялық позицияны қорғайды.',
    'togyzDrawTitle': 'Тең',
    'togyzDrawDesc':
        'Егер ойын 81-81 тең есеппен аяқталса (өте сирек), тең деп жарияланады. Бұл жағдайда жеңімпаз жоқ.',
    'togyzScoreCountTitle': 'Ұпай санау',
    'togyzScoreCountDesc':
        'Ойында барлығы 162 құмалақ. Жеңімпаз 82+ жинауы керек. Қазаныңызды қадағалаңыз - сан ағымдағы ұпайыңызды көрсетеді.',
    // Rules - Chess
    'chessRulesHeader': 'Шахмат ережелері',
    'chessGoal': 'Мақсат: Қарсыластың патшасына мат қою.',
    'chessInitialSetupTitle': 'Бастапқы орналасу',
    'chessMovesHeader': 'Фигуралардың жүрістері',
    'chessPawnRule':
        'Пешка (♙/♟︎): Алға 1 (немесе бастапқы позициядан 2). Диагональ бойынша алады.',
    'chessPawnMoveTitle': 'Пешка жүрісі (Басыңыз)',
    'chessPawnMoveDesc': 'Пешканың бастапқы жүрісі 2 тор.',
    'chessPawnCaptureTitle': 'Пешкамен алу (Басыңыз)',
    'chessPawnCaptureDesc': 'Ақ пешка e3 қара d4-ті алады.',
    'chessKnightRule': 'Ат (♘/♞): "Г" әрпімен жүреді. Фигураларды аттап өтеді.',
    'chessKnightMoveTitle': 'Ат жүрісі (Басыңыз)',
    'chessKnightMoveDesc':
        'Ат бір бағытта 2 тор және перпендикулярда 1 тор жүреді.',
    'chessBishopRule': 'Піл (♗/♝): Диагональ бойынша жүреді.',
    'chessRookRule': 'Мұнара (♖/♜): Вертикаль/горизонталь бойынша жүреді.',
    'chessQueenRule': 'Ферзь (♕/♛): Мұнара + піл сияқты жүреді.',
    'chessKingRule': 'Патша (♔/♚): Кез келген бағытта 1 торға жүреді.',
    'chessCastlingTitle': 'Рокировка (Басыңыз)',
    'chessCastlingDesc':
        'Ақтардың қысқа рокировкасы (0-0). Патша мен мұнара бір уақытта жүреді (анимация тек патшаны көрсетеді).',
    'chessEnPassantTitle': 'Өту арқылы алу',
    'chessEnPassantDesc':
        'Егер қарсыластың сарбазы 2 торға жүріп, сіздің сарбазыңыздың қасында тұрса, оны "өту арқылы" алуға болады.',
    'chessPromotionTitle': 'Сарбаз түрлендіру',
    'chessPromotionDesc':
        'Сарбаз соңғы қатарға жеткенде, ол ферзьге, мұнараға, пілге немесе аттқа айналады.',
    'chessCheckTitle': 'Шах, мат және пат',
    'chessCheckDesc':
        'Шах - патша шабуыл астында. Мат - патша шах астында, құтқару жоқ. Пат - жүрістер жоқ, патша шах астында емес (тең).',
    'chessRookMoveDesc':
        'Мұнара түзу сызықтар бойынша жүреді - вертикаль немесе горизонталь бойынша кез келген торлар санына.',
    'chessBishopMoveDesc':
        'Піл диагональ бойынша кез келген торлар санына жүреді. Әрбір піл бүкіл ойын бойы өз түсінде қалады.',
    'chessQueenMoveDesc':
        'Ферзь - ең күшті фигура. Мұнара мен піл жүрістерін біріктіреді - түзу және диагональ бойынша.',
    'chessCheckmateTitle': 'Патшаға мат',
    'chessCheckmateDesc':
        'Мат - патша шабуыл астында және құтыла алмайды. Ойын аяқталды, шабуылдаушы жақ жеңеді.',
    // Rules - Backgammon
    'backgammonRulesHeader': 'Нарды ережелері (Ұзын)',
    'backgammonGoal': 'Мақсат: Барлық 15 тасты тақтадан шығару.',
    'backgammonInitialSetupTitle': 'Бастапқы орналасу',
    'backgammonMoveHeader': 'Жүріс',
    'backgammonMove1': '1. Сүйектерді лақтырыңыз.',
    'backgammonMove2':
        '2. Тастарды шыққан сандарға сәйкес жылжытыңыз. Дубль 4 рет ойналады.',
    'backgammonMove3':
        '3. Бір тасты қосындыға немесе екі тасты әр мәнге жылжытуға болады.',
    'backgammonMove4': '4. Қарсылас алған нүктеге қоюға болмайды.',
    'backgammonMoveExampleTitle': 'Жүріс мысалы (Басыңыз)',
    'backgammonMoveExampleDesc':
        'Ақтар 5-2 лақтырды. Олар екі тасты 19 нүктеден (18 индекс) 24-ке (23 индекс) және 21-ге (20 индекс) жылжытады.',
    'backgammonHitHeader': 'Тасты ұру',
    'backgammonHitRule':
        'Егер сіз БІР қарсылас тасы бар нүктеге түссеңіз (блот), ол ұрылып, барға кетеді.',
    'backgammonHitExampleTitle': 'Ұру мысалы (Басыңыз)',
    'backgammonHitExampleDesc':
        'Ақтар 3 лақтырды. 1 нүктеден (0 индекс) тас 4 нүктеге (3 индекс) барып, қара тасты барға ұрады.',
    'backgammonBarHeader': 'Бардан кіру',
    'backgammonBarRule':
        'Ұрылған тастар алдымен қарсыластың "үйіне" кіруі керек (ақтар үшін 1-6 нүктелер, қаралар үшін 19-24).',
    'backgammonBearOffHeader': 'Үйден шығару',
    'backgammonBearOffRule':
        'Тастарды шығаруға тек барлық 15 тас сіздің "үйіңізде" болғанда ғана болады (ақтар үшін 19-24 нүктелер, қаралар үшін 1-6).',
    'backgammonDoublesTitle': 'Дубль (бірдей сүйектер)',
    'backgammonDoublesDesc':
        'Дубль түссе (екі сүйекте бірдей сан), сол мәнге 4 рет жүресіз. Мысалы, 3-3 = төрт жүріс 3-ке.',
    'backgammonBlockadeTitle': 'Блокада және қорғаныс',
    'backgammonBlockadeDesc':
        'Нүктелерді екі немесе одан көп таспен алыңыз - олар қауіпсіз. Алты қатарынан нүкте "прайм" жасайды - өтуге болмайтын қабырға.',
    'backgammonWinConditionsTitle': 'Жеңіс шарттары',
    'backgammonWinConditionsDesc':
        'Қарапайым жеңіс - барлық тастарды шығарды. Гаммон (x2) - қарсылас ешбірін шығармады. Бэкгаммон (x3) - қарсылас ешбірін шығармады және оның үйіңізде немесе барда тастары бар.',
  };

  static String _currentLanguage = 'ru';

  static void setLanguage(String langCode) {
    if (['ru', 'en', 'kz'].contains(langCode)) {
      _currentLanguage = langCode;
    }
  }

  static String get currentLanguage => _currentLanguage;

  static String get(String key) {
    Map<String, String> map;
    switch (_currentLanguage) {
      case 'en':
        map = _en;
        break;
      case 'kz':
        map = _kz;
        break;
      case 'ru':
      default:
        map = _ru;
        break;
    }
    return map[key] ?? key;
  }
}
