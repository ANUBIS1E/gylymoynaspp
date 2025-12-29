enum TrainingDifficulty { easy, medium, hard }

class TrainingLesson {
  final String title;
  final String description;
  final TrainingDifficulty difficulty;
  final List<String> aiHints;

  const TrainingLesson({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.aiHints,
  });
}

const String _fallbackTrainingLanguage = 'ru';

const Map<String, List<Map<String, Object>>> _trainingLessonsData = {
  'chess': [
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Открытие центра',
        'en': 'Center Opening',
        'kz': 'Орталықты ашу',
      },
      'description': {
        'ru': 'Научитесь контролировать центр доски в дебюте',
        'en': 'Learn how to control the center squares during the opening.',
        'kz': 'Дебют кезінде тақтаның ортасын қалай бақылауды үйреніңіз.',
      },
      'hints': [
        {
          'ru': 'Начинайте с ходов e2-e4 или d2-d4, чтобы занять центр',
          'en': 'Start with pawn moves e2-e4 or d2-d4 to claim the center.',
          'kz': 'Ортаны иелену үшін e2-e4 немесе d2-d4 пешкесін жүріңіз.',
        },
        {
          'ru': 'Контроль клеток e4, e5, d4 и d5 дает больше пространства',
          'en': 'Controlling e4, e5, d4 and d5 gives you extra space.',
          'kz': 'e4, e5, d4, d5 ұяшықтарын бақылау кеңістікті арттырады.',
        },
        {
          'ru': 'Развивайте коня на f3 или c3, чтобы поддержать пешки',
          'en': 'Develop a knight to f3 or c3 to support the center pawns.',
          'kz':
              'Орталық пешкелерді қолдау үшін атты f3 немесе c3-ке шығарыңыз.',
        },
        {
          'ru': 'Не делайте подряд слишком много пешечных ходов',
          'en': 'Avoid pushing too many pawns in a row—activate pieces.',
          'kz':
              'Қатарынан тым көп пешке жүріс жасамаңыз, фигураларды ойнаға қосыңыз.',
        },
        {
          'ru': 'После пары пешечных ходов выводите легкие фигуры',
          'en': 'After a couple of pawn moves start developing minor pieces.',
          'kz':
              'Екі-үш пешке жүрістен кейін жеңіл фигураларды дамыта бастаңыз.',
        },
      ],
    },
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Защита короля',
        'en': 'King Defense',
        'kz': 'Патшаны қорғау',
      },
      'description': {
        'ru': 'Поймите важность рокировки и укрепления короля',
        'en': 'Understand why castling keeps your king safe.',
        'kz': 'Рокировка патшаны қалай қорғайтынын түсініңіз.',
      },
      'hints': [
        {
          'ru': 'Делайте рокировку между 5 и 10 ходами для безопасности',
          'en': 'Castle between moves 5 and 10 to secure the king.',
          'kz': 'Қауіпсіздік үшін 5–10 жүріс аралығында рокировка жасаңыз.',
        },
        {
          'ru': 'Не трогайте пешки f, g и h без необходимости до рокировки',
          'en': 'Avoid moving the f, g and h pawns before castling.',
          'kz': 'Рокировкаға дейін f, g, h пешкелерін себепсіз жылжытпаңыз.',
        },
        {
          'ru': 'Король в углу доски труднее для атаки',
          'en': 'A king tucked into the corner is harder to attack.',
          'kz': 'Бұрыштағы патшаға шабуыл жасау қиынырақ.',
        },
        {
          'ru': 'После рокировки держите рядом 1-2 защитных фигуры',
          'en': 'Keep one or two pieces near the king after castling.',
          'kz': 'Рокировкадан кейін патшаның жанында 1-2 фигура болсын.',
        },
        {
          'ru': 'Не открывайте вертикали, ведущие к вашему королю',
          'en': 'Do not open files that point straight toward your king.',
          'kz': 'Патшаңызға бағытталған вертикальдарды ашпаңыз.',
        },
      ],
    },
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Развитие фигур',
        'en': 'Piece Development',
        'kz': 'Фигураларды дамыту',
      },
      'description': {
        'ru': 'Следуйте базовым принципам развития в дебюте',
        'en': 'Follow proper development principles in the opening.',
        'kz': 'Дебютте даму қағидаларын сақтаңыз.',
      },
      'hints': [
        {
          'ru': 'Выводите коней раньше слонов — они менее подвижны',
          'en': 'Develop knights before bishops—they are less flexible.',
          'kz':
              'Аттарды слондардан бұрын дамытыңыз – олардың қозғалысы шектеулі.',
        },
        {
          'ru': 'Размещайте коней на f3 и c3 (или f6 и c6 за черных)',
          'en': 'Place knights on f3 and c3 (or f6 and c6 for Black).',
          'kz': 'Аттарды f3 және c3-ке (қара үшін f6 және c6) қойыңыз.',
        },
        {
          'ru': 'Слоны особенно сильны на длинных диагоналях',
          'en': 'Bishops work best on long diagonals.',
          'kz': 'Слондар ұзын диагональдарда тиімді.',
        },
        {
          'ru': 'Не выводите ферзя слишком рано, иначе его будут гонять',
          'en': 'Do not bring the queen out too early—it will be chased.',
          'kz': 'Ферзьді тым ерте шығармаңыз, оны қуу оңай.',
        },
        {
          'ru': 'Соединяйте ладьи, когда задний ряд очищен',
          'en': 'Connect your rooks once the back rank is cleared.',
          'kz': 'Артқы қатар босаса, ладьяларды байланыстырыңыз.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Тактические удары: Вилка',
        'en': 'Tactical Strikes: Fork',
        'kz': 'Тактикалық соққылар: Айыр',
      },
      'description': {
        'ru': 'Атакуйте две фигуры одновременно',
        'en': 'Attack two pieces at the same time.',
        'kz': 'Бір мезетте екі фигураға шабуыл жасаңыз.',
      },
      'hints': [
        {
          'ru': 'Конь идеально подходит для вилок, он атакует восемь полей',
          'en':
              'Knights are ideal for forks because they attack eight squares.',
          'kz': 'Айыр жасау үшін ат ыңғайлы, ол сегіз ұяшықты шабуылдайды.',
        },
        {
          'ru': 'Ищите вилки на короля и ферзя или ладью',
          'en': 'Look for forks on the king and the queen or rook.',
          'kz': 'Патша мен ферзьді немесе ладьяны бір уақытта айыруды іздеңіз.',
        },
        {
          'ru': 'Пешки тоже могут делать вилки по диагонали',
          'en': 'Pawns can also fork along diagonals.',
          'kz': 'Пешкелер диагональ бойынша айыр жасай алады.',
        },
        {
          'ru': 'Вилка опасна, когда соперник не защищает обе цели',
          'en': 'A fork hurts when the opponent cannot defend both targets.',
          'kz': 'Қарсылас екі нысанды қорғай алмаса, айыр өте қауіпті.',
        },
        {
          'ru': 'Всегда проверяйте, не уязвимы ли ваши фигуры для вилок',
          'en': 'Always check that your own pieces are not forkable.',
          'kz': 'Өз фигураларыңыздың айыр астында қалмасын тексеріңіз.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Тактические удары: Связка',
        'en': 'Tactical Strikes: Pin',
        'kz': 'Тактикалық соққылар: Байлау',
      },
      'description': {
        'ru': 'Используйте связанные фигуры в свою пользу',
        'en': 'Use pinned pieces to your advantage.',
        'kz': 'Байланған фигураларды өз пайдаңызға қолданыңыз.',
      },
      'hints': [
        {
          'ru': 'Связка лишает фигуру хода, иначе откроется более ценная',
          'en':
              'A pin freezes a piece because moving it exposes a valuable piece.',
          'kz':
              'Байлау фигураны қозғалтпайды, өйткені артында бағалы фигура тұр.',
        },
        {
          'ru': 'Слоны и ладьи создают сильные связки на линиях',
          'en': 'Bishops and rooks create strong pins on diagonals and files.',
          'kz':
              'Слондар мен ладьялар диагональдар мен вертикальдарда жақсы байлайды.',
        },
        {
          'ru': 'Связанная фигура — легкая цель для пешек',
          'en': 'A pinned piece becomes an easy target for pawns.',
          'kz': 'Байланған фигура пешкелер үшін оңай олжа.',
        },
        {
          'ru': 'Не двигайте связанную фигуру, если за ней ваш король',
          'en': "Don't move a pinned piece if it would expose your king.",
          'kz': 'Патшаны ашып алсаңыз, байланған фигураны қозғалтпаңыз.',
        },
        {
          'ru': 'Ищите способы связывать фигуры соперника',
          'en': "Look for ways to pin your opponent's pieces.",
          'kz': 'Қарсылас фигураларын байлаудың жолдарын іздеңіз.',
        },
      ],
    },
    {
      'difficulty': 'hard',
      'title': {
        'ru': 'Эндшпиль: Король и пешка',
        'en': 'Endgame: King and Pawn',
        'kz': 'Эндшпиль: Патша және пешка',
      },
      'description': {
        'ru': 'Освойте базовые окончания с пешками',
        'en': 'Master the basics of king and pawn endgames.',
        'kz': 'Патша мен пешка эндшпилінің негіздерін меңгеріңіз.',
      },
      'hints': [
        {
          'ru': 'В эндшпиле король становится активной фигурой',
          'en': 'In the endgame the king becomes a strong attacker.',
          'kz': 'Эндшпильде патша белсенді шабуылшыға айналады.',
        },
        {
          'ru': 'Ведите короля перед пешкой, поддерживая продвижение',
          'en': 'Walk the king in front of the pawn to support promotion.',
          'kz': 'Пешканы жүргізу үшін патшаны оның алдына қойыңыз.',
        },
        {
          'ru': 'Помните правило квадрата — тогда пешку не догонят',
          'en': 'Remember the square rule to know if a pawn promotes.',
          'kz': 'Шаршы ережесін біліңіз — пешка жетеді ме, соны есептеңіз.',
        },
        {
          'ru': 'Используйте оппозицию, чтобы оттеснить короля соперника',
          'en': 'Use opposition to push the enemy king away.',
          'kz': 'Қарсылас патшасын ығыстыру үшін оппозиция қолданыңыз.',
        },
        {
          'ru': 'Превращайте пешку в ферзя как можно быстрее',
          'en': 'Promote your pawn to a queen as soon as possible.',
          'kz': 'Пешканы мүмкіндігінше тез ферзьге айналдырыңыз.',
        },
      ],
    },
  ],
  'checkers': [
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Первые ходы',
        'en': 'First Moves',
        'kz': 'Алғашқы жүрістер',
      },
      'description': {
        'ru': 'Как грамотно начать партию в шашки',
        'en': 'Learn how to start a draughts game correctly.',
        'kz': 'Шашкі партиясын дұрыс бастау тәсілдері.',
      },
      'hints': [
        {
          'ru': 'Занимайте поля c3, d4, e3 и f4, чтобы контролировать центр',
          'en': 'Occupy c3, d4, e3 and f4 to control the center.',
          'kz': 'Ортаны бақылау үшін c3, d4, e3, f4 ұяшықтарын алыңыз.',
        },
        {
          'ru': 'Не спешите выводить крайние шашки',
          'en': 'Do not rush to move the edge pieces.',
          'kz': 'Қапталдағы шашкаларды асықпай шығарыңыз.',
        },
        {
          'ru': 'Контроль центра дает больше свободы маневра',
          'en': 'Center control gives you more mobility.',
          'kz': 'Ортаны бақылау қозғалысты арттырады.',
        },
        {
          'ru': 'Стройте цепочку из своих шашек для взаимной защиты',
          'en': 'Build a chain of connected checkers for mutual defense.',
          'kz': 'Шашкаларды бір-бірімен байланыстырып, қорғанысты күшейтіңіз.',
        },
        {
          'ru': 'Следите, чтобы шашки не оставались без прикрытия',
          'en': 'Never leave a checker without cover.',
          'kz': 'Шашканы қорғаныссыз қалдырмаңыз.',
        },
      ],
    },
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Обязательное взятие',
        'en': 'Mandatory Capture',
        'kz': 'Міндетті алу',
      },
      'description': {
        'ru': 'Стратегия ударов, которые нужно делать обязательно',
        'en': 'Strategy for compulsory captures.',
        'kz': 'Міндетті соққылардың стратегиясы.',
      },
      'hints': [
        {
          'ru': 'Если можете бить — обязаны сделать удар',
          'en': 'If a capture exists you are obliged to take it.',
          'kz': 'Алушартты бар болса, міндетті түрде соғыңыз.',
        },
        {
          'ru': 'Просчитывайте длинные цепочки взятий заранее',
          'en': 'Calculate long capture sequences beforehand.',
          'kz': 'Ұзақ соққы тізбектерін алдын ала есептеңіз.',
        },
        {
          'ru': 'Оппонент может жертвовать шашку ради ловушки',
          'en': 'Opponents may sacrifice to set a trap.',
          'kz': 'Қарсылас қақпан құру үшін шашканы бере алады.',
        },
        {
          'ru': 'Выбирайте комбинацию, которая выгоднее вам',
          'en': 'Choose the capture line that benefits you most.',
          'kz': 'Өзіңізге пайдалы соққы комбинациясын таңдаңыз.',
        },
        {
          'ru': 'Помните: простые шашки могут бить и назад',
          'en': 'Remember that men can capture backward too.',
          'kz': 'Жай шашқа артқа да соға алады.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Прорыв в дамки',
        'en': 'Queens Row Breakthrough',
        'kz': 'Дама қатарына өту',
      },
      'description': {
        'ru': 'Как провести шашку в дамочную линию',
        'en': 'How to promote a checker efficiently.',
        'kz': 'Шашканы дамалық қатарға жеткізу.',
      },
      'hints': [
        {
          'ru': 'Стремитесь первыми получить дамку — это преимущество',
          'en': 'Gaining the first king gives a big advantage.',
          'kz': 'Даманы бірінші болып алу — үлкен артықшылық.',
        },
        {
          'ru': 'Проводите шашки по краям, там меньше угроз',
          'en': 'Advance along the edges where there is less danger.',
          'kz': 'Қауіп аз болатын қапталмен жүріңіз.',
        },
        {
          'ru': 'Иногда стоит пожертвовать шашку ради прорыва',
          'en': 'Sometimes sacrificing a checker opens the path.',
          'kz': 'Кейде шашканы құрбан ету жол ашады.',
        },
        {
          'ru': 'Будьте готовы к попытке соперника заблокировать ход',
          'en': 'Be ready for your opponent to block your route.',
          'kz': 'Қарсылас жолыңызды бөгегісі келеді.',
        },
        {
          'ru': 'Получив дамку, играйте аккуратно, чтобы её не потерять',
          'en': 'After promoting, play carefully to keep the king safe.',
          'kz': 'Дама алған соң сақ болыңыз.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Игра дамкой',
        'en': 'Playing with a King',
        'kz': 'Дамамен ойнау',
      },
      'description': {
        'ru': 'Тактика использования дамки',
        'en': 'Tactics for using a king piece.',
        'kz': 'Даманы қолдану тактикасы.',
      },
      'hints': [
        {
          'ru': 'Дамка ходит и бьет по диагонали на любое расстояние',
          'en': 'A king moves and captures any distance diagonally.',
          'kz': 'Дама диагональ бойынша кез келген қашықтыққа жүріп, соғады.',
        },
        {
          'ru': 'Контролируйте длинные диагонали одной дамкой',
          'en': 'Use it to control the long diagonals.',
          'kz': 'Ұзын диагональдарды бақылаңыз.',
        },
        {
          'ru': 'Дамка опасна даже с безопасной дистанции',
          'en': 'A king can attack safely from afar.',
          'kz': 'Дама алыстан қауіпсіз шабуыл жасай алады.',
        },
        {
          'ru': 'Одна дамка часто сильнее нескольких простых шашек',
          'en': 'A lone king often beats multiple men.',
          'kz': 'Жалғыз дама бірнеше жай шашканы жеңе алады.',
        },
        {
          'ru': 'Не позволяйте сопернику устроить многоходовую ловушку',
          'en': "Don't fall into multi-capture traps with your king.",
          'kz': 'Даманы көп сатылы қақпанға түсірмеңіз.',
        },
      ],
    },
    {
      'difficulty': 'hard',
      'title': {
        'ru': 'Запирание и блокировка',
        'en': 'Locking and Blocking',
        'kz': 'Қоршау және блоктау',
      },
      'description': {
        'ru': 'Как запереть шашки соперника',
        'en': "Learn how to lock your opponent's pieces.",
        'kz': 'Қарсылас шашкаларын қоршау тәсілдерін біліңіз.',
      },
      'hints': [
        {
          'ru': 'Запирание означает отсутствие ходов у соперника',
          'en': 'A lock means the opponent has no legal moves.',
          'kz': 'Қарсылас жүріс жасай алмаса, ол қоршауда.',
        },
        {
          'ru': 'Стройте стену из своих шашек, чтобы перекрыть пути',
          'en': 'Build a wall of checkers to block the paths.',
          'kz': 'Жолыңызды жабу үшін шашкалардан қабырға жасаңыз.',
        },
        {
          'ru': 'Занимайте ключевые поля и не давайте выйти из ловушки',
          'en': 'Take key squares so the opponent cannot escape.',
          'kz': 'Маңызды ұяшықтарды алып, қарсыласты шығармаңыз.',
        },
        {
          'ru': 'Запирание — альтернативный путь к победе',
          'en': 'Locking is an alternate path to victory.',
          'kz': 'Қоршау — жеңіске жетудің басқа жолы.',
        },
        {
          'ru': 'Следите, чтобы соперник не запер вас в ответ',
          'en': 'Make sure you are not the one being locked.',
          'kz': 'Өзіңіз қоршауда қалмаңыз.',
        },
      ],
    },
  ],
  'togyz': [
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Правила посева',
        'en': 'Sowing Rules',
        'kz': 'Себу ережелері',
      },
      'description': {
        'ru': 'Базовая механика игры',
        'en': 'The basic mechanics of sowing stones.',
        'kz': 'Себудің негізгі механикасы.',
      },
      'hints': [
        {
          'ru':
              'Берите все кумалаки из выбранной лунки (если один, просто перенесите его)',
          'en':
              'Pick up every kumalak from the pit (if there was only one, just move it).',
          'kz':
              'Таңдалған отаудан барлық құмалақты алыңыз (бір ғана құмалақ болса, оны жай көшіріңіз).',
        },
        {
          'ru': 'Раскладывайте кумалаки по одному против часовой стрелки',
          'en': 'Distribute the stones one by one counterclockwise.',
          'kz': 'Құмалақтарды сағат тіліне қарсы таратыңыз.',
        },
        {
          'ru': 'Начинайте со следующей лунки, а не с той, что выбрали',
          'en': 'Start sowing from the next pit, not the current one.',
          'kz': 'Себуді келесі отаудан бастаңыз.',
        },
        {
          'ru': 'Считайте кумалаки, чтобы знать, где упадет последний',
          'en': 'Count stones to know where the last one lands.',
          'kz': 'Соңғы құмалақ қайда түсетінін білу үшін санап отырыңыз.',
        },
        {
          'ru': 'Последний кумалак определяет, что произойдет с лункой',
          'en': 'The last kumalak determines what happens to the pit.',
          'kz': 'Соңғы құмалақ отауда не болатынын анықтайды.',
        },
      ],
    },
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Захват кумалаков',
        'en': 'Capturing Kumalaks',
        'kz': 'Құмалақтарды алу',
      },
      'description': {
        'ru': 'Как забирать кумалаки в казан',
        'en': 'How to collect stones into your kazan.',
        'kz': 'Құмалақтарды қазанға қалай жинау керек.',
      },
      'hints': [
        {
          'ru': 'Захват происходит, когда последний камень делает число четным',
          'en': 'A capture happens when the last stone makes the pit even.',
          'kz': 'Соңғы құмалақ жұп сан жасағанда, отаудағы тас алынады.',
        },
        {
          'ru': 'Брать можно только из лунок соперника',
          'en': 'You only capture from the opponent’s pits.',
          'kz': 'Құмалақ тек қарсылас отауынан алынады.',
        },
        {
          'ru': 'Все кумалаки из этой лунки идут в ваш казан',
          'en': 'All stones from that pit go into your kazan.',
          'kz': 'Отаудан шыққан барлық құмалақ сіздің қазаныңызға түседі.',
        },
        {
          'ru': 'Планируйте ходы, чтобы создавать четные числа у соперника',
          'en': 'Plan moves to create even counts in opponent pits.',
          'kz': 'Қарсылас отауларында жұп сан жасауға тырысыңыз.',
        },
        {
          'ru': 'Избегайте четных чисел в своих лунках',
          'en': 'Avoid leaving even numbers in your own pits.',
          'kz': 'Өз отауларыңызда жұп сан қалдырмаңыз.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Создание туздыка',
        'en': 'Creating a Tuzdyk',
        'kz': 'Тұздық жасау',
      },
      'description': {
        'ru': 'Постоянный источник преимущества',
        'en': 'A permanent source of advantage.',
        'kz': 'Тұрақты артықшылық көзі.',
      },
      'hints': [
        {
          'ru': 'Туздык появляется, когда последний камень образует число три',
          'en':
              'A tuzdyk appears when the last stone makes three in an opponent pit.',
          'kz':
              'Соңғы құмалақ қарсылас отауында үш санын жасаса, тұздық пайда болады.',
        },
        {
          'ru': 'За игру можно создать только один туздык',
          'en': 'You may create only one tuzdyk per game.',
          'kz': 'Ойын барысында бір ғана тұздық жасауға болады.',
        },
        {
          'ru': 'Нельзя ставить туздык в девятой лунке и симметричной ей',
          'en': 'You cannot create a tuzdyk on the ninth pit or its mirror.',
          'kz': 'Тұздық тоғызыншы отауда және оның симметриясында жасалмайды.',
        },
        {
          'ru': 'Все кумалаки из туздыка автоматически идут вам',
          'en': 'All stones from a tuzdyk automatically go to you.',
          'kz': 'Тұздықтан түскен барлық құмалақ өзіңізге жазылады.',
        },
        {
          'ru': 'Лучшие туздыки получаются в центральных лунках 4-6',
          'en': 'Central pits (4-6) usually make the best tuzdyk.',
          'kz': 'Ең тиімді тұздықтар көбіне 4-6 отауларында жасалады.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Контроль центра',
        'en': 'Center Control',
        'kz': 'Орталықты бақылау',
      },
      'description': {
        'ru': 'Тактика контроля центральных лунок',
        'en': 'Tactics for controlling the central pits.',
        'kz': 'Орталық отауларды бақылау тактикасы.',
      },
      'hints': [
        {
          'ru': 'Лунки 4, 5 и 6 самые важные на доске',
          'en': 'Pits 4, 5 and 6 are the most important.',
          'kz': '4, 5 және 6-отаулар басты рөл атқарады.',
        },
        {
          'ru': 'Держите больше кумалак в центре для гибкости',
          'en': 'Keep extra stones in the center for flexibility.',
          'kz': 'Икемді болу үшін орталықта көбірек құмалақ ұстаңыз.',
        },
        {
          'ru': 'Из центра удобно атаковать любую часть доски',
          'en': 'From the center you can reach any part of the board.',
          'kz': 'Орталықтан тақтаның кез келген бөлігіне жетуге болады.',
        },
        {
          'ru': 'Не опустошайте центр без необходимости',
          'en': 'Do not empty the center unless necessary.',
          'kz': 'Қажет болмаса, орталықты босатпаңыз.',
        },
        {
          'ru': 'Атакуйте центральные лунки соперника, чтобы ограничить его',
          'en': 'Attack the opponent’s central pits to limit their plans.',
          'kz': 'Қарсыластың орталық отауларын шабуылдап, әрекетін шектеңіз.',
        },
      ],
    },
    {
      'difficulty': 'hard',
      'title': {'ru': 'Эндшпиль', 'en': 'Endgame', 'kz': 'Эндшпиль'},
      'description': {
        'ru': 'Стратегия в конце игры',
        'en': 'Strategy for the final stage of the game.',
        'kz': 'Ойынның соңғы бөлігіне арналған стратегия.',
      },
      'hints': [
        {
          'ru': 'Цель — набрать минимум 82 кумалака в казане',
          'en': 'Aim to collect at least 82 stones in your kazan.',
          'kz': 'Мақсат — қазанда кемінде 82 құмалақ жинау.',
        },
        {
          'ru': 'Каждый кумалак важен, берегите преимущество',
          'en': 'Every stone matters late in the game.',
          'kz': 'Ойын соңында әр құмалақ маңызды.',
        },
        {
          'ru': 'Блокируйте ходы соперника, заставляя отдавать кумалаки',
          'en': 'Block the opponent to force them to give you stones.',
          'kz': 'Қарсылас жүрістерін шектеп, құмалақ беруге мәжбүрлеңіз.',
        },
        {
          'ru': 'Если у вас уже 82, не рискуйте и защищайте казан',
          'en': 'If you already have 82, protect the lead and avoid risks.',
          'kz': '82 құмалақ жинасаңыз, артықшылықты сақтаңыз.',
        },
        {
          'ru': 'Иногда выгодно пасовать, чтобы соперник тратил ходы',
          'en': 'Sometimes passing is useful to make the opponent move.',
          'kz':
              'Кейде қарсыласты жүріс жасауға мәжбүрлеу үшін пас берген дұрыс.',
        },
      ],
    },
  ],
  'backgammon': [
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Основы движения',
        'en': 'Movement Basics',
        'kz': 'Жүріс негіздері',
      },
      'description': {
        'ru': 'Как ходить шашками',
        'en': 'How to move your checkers.',
        'kz': 'Шашкаларды қалай жылжыту керек.',
      },
      'hints': [
        {
          'ru': 'Бросьте два кубика и двигайтесь на выпавшие значения',
          'en': 'Roll two dice and move according to the numbers.',
          'kz': 'Екі сүйекті лақтырып, түскен сандарға сәйкес жүріңіз.',
        },
        {
          'ru': 'Можно ходить одной шашкой на сумму или двумя по отдельности',
          'en': 'Use one checker for the total or split the dice between two.',
          'kz': 'Сандарды бір шашкаға немесе екі шашкаға бөліп жүріңіз.',
        },
        {
          'ru': 'Дубли играются четыре раза и дают мощный ход',
          'en': 'Doubles are played four times and are very powerful.',
          'kz': 'Дубль төрт рет ойналады және өте күшті жүріс береді.',
        },
        {
          'ru': 'Двигайтесь по часовой стрелке к своему дому',
          'en': 'Move clockwise toward your home board.',
          'kz': 'Шашкаларды сағат тілімен өз үйіңізге қарай жүргізіңіз.',
        },
        {
          'ru': 'Нельзя ставить шашку на пункт, занятый соперником',
          'en': 'You cannot land on a point occupied by two enemy checkers.',
          'kz': 'Қарсыластың екі шашкасы тұрған пунктке түсуге болмайды.',
        },
      ],
    },
    {
      'difficulty': 'easy',
      'title': {
        'ru': 'Стратегия заборов',
        'en': 'Prime Strategy',
        'kz': 'Қоршау стратегиясы',
      },
      'description': {
        'ru': 'Блокировка шашек соперника',
        'en': 'Blocking your opponent’s checkers.',
        'kz': 'Қарсылас шашкаларын бөгеп тастау.',
      },
      'hints': [
        {
          'ru': 'Забор — несколько подряд занятых пунктов',
          'en': 'A prime is several consecutive blocked points.',
          'kz': 'Қоршау — қатар тұрған бірнеше жабық пункт.',
        },
        {
          'ru': 'Цепочка из шести пунктов полностью блокирует шашку',
          'en': 'A chain of six points completely locks a checker.',
          'kz': 'Алты пункттен тұратын қатар қарсыласты толық бөгейді.',
        },
        {
          'ru': 'Стройте заборы в своем доме для максимального эффекта',
          'en': 'Build primes inside your home board for maximum effect.',
          'kz': 'Ең тиімдісі – қоршауды өз үйіңізде салу.',
        },
        {
          'ru': 'Заборы замедляют продвижение соперника',
          'en': 'Primes slow the opponent down.',
          'kz': 'Қоршаулар қарсыластың жылдамдығын төмендетеді.',
        },
        {
          'ru': 'Не оставляйте больших разрывов в своем заборе',
          'en': 'Avoid leaving large gaps inside your prime.',
          'kz': 'Қоршауда үлкен бос орын қалдырмаңыз.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Блоты и удары',
        'en': 'Blots and Hitting',
        'kz': 'Блоттар және соғу',
      },
      'description': {
        'ru': 'Одиночные шашки и их захват',
        'en': 'Single checkers and how to hit them.',
        'kz': 'Жеке тұрған шашкалар мен оларды соғу.',
      },
      'hints': [
        {
          'ru': 'Блот — одиночная шашка, которую можно сбить',
          'en': 'A blot is a single checker that can be hit.',
          'kz': 'Блот — жалғыз тұрған шашка, оны соғуға болады.',
        },
        {
          'ru': 'Сбитая шашка уходит на бар и должна войти заново',
          'en': 'A hit checker goes to the bar and must re-enter.',
          'kz': 'Соғылған шашка барға барады және қайта кіруі керек.',
        },
        {
          'ru': 'Избегайте оставлять блоты на открытых пунктах',
          'en': 'Avoid leaving blots on exposed points.',
          'kz': 'Ашық пункттерде блот қалдырмаңыз.',
        },
        {
          'ru': 'Ищите возможности сбивать блоты соперника',
          'en': 'Look for chances to hit enemy blots.',
          'kz': 'Қарсыластың блоттарын соғу мүмкіндігін іздеңіз.',
        },
        {
          'ru': 'Пока шашка на баре, другие не могут ходить',
          'en': 'While a checker is on the bar you must re-enter it first.',
          'kz': 'Бардағы шашка ойынға қайтпайынша, басқа шашкалар жүрмейді.',
        },
      ],
    },
    {
      'difficulty': 'medium',
      'title': {
        'ru': 'Вход с бара',
        'en': 'Entering from the Bar',
        'kz': 'Бардан кіру',
      },
      'description': {
        'ru': 'Как вернуть сбитые шашки',
        'en': 'How to return hit checkers to the board.',
        'kz': 'Соғылған шашкаларды тақтаға қайта әкелу.',
      },
      'hints': [
        {
          'ru': 'Шашка входит в дом соперника (1-6 для белых)',
          'en':
              'A checker re-enters in the opponent’s home (points 1-6 for White).',
          'kz': 'Шашка қарсылас үйіне (ақ үшін 1-6 пункт) кіреді.',
        },
        {
          'ru': 'Нужно выбросить число, соответствующее свободному пункту',
          'en': 'You need the exact number of an open point to re-enter.',
          'kz': 'Қайта кіру үшін бос пункттің нақты санын лақтырыңыз.',
        },
        {
          'ru': 'Пока шашка на баре, другие ходить не могут',
          'en': 'Other checkers cannot move while you have one on the bar.',
          'kz': 'Бардағы шашка қайтпайынша, басқа шашкалар жүрмейді.',
        },
        {
          'ru': 'Если все пункты заняты, ход пропускается',
          'en': 'If every entry point is blocked, you lose the turn.',
          'kz': 'Барлық пункттер жабық болса, жүрісті өткізіп аласыз.',
        },
        {
          'ru': 'Защищайте свой дом, чтобы сопернику было сложно войти',
          'en': 'Protect your home board to keep the opponent out.',
          'kz': 'Қарсыластың кіруін қиындату үшін өз үйіңізді қорғаңыз.',
        },
      ],
    },
    {
      'difficulty': 'hard',
      'title': {
        'ru': 'Вывод шашек',
        'en': 'Bearing Off',
        'kz': 'Шашкаларды шығару',
      },
      'description': {
        'ru': 'Финальная стадия игры',
        'en': 'The final stage of the game.',
        'kz': 'Ойынның соңғы бөлігі.',
      },
      'hints': [
        {
          'ru': 'Выводить можно, когда все 15 шашек в вашем доме',
          'en': 'Bear off only after all 15 checkers are in your home.',
          'kz': '15 шашканың бәрі үйде тұрғанда ғана шығара аласыз.',
        },
        {
          'ru': 'Используйте значение кубика, чтобы снять шашку с пункта',
          'en': 'Use the die roll to remove a checker from the matching point.',
          'kz': 'Кубиктегі санға сәйкес пункттен шашканы шығарыңыз.',
        },
        {
          'ru': 'Если пункт пуст, снимите шашку с более высокого номера',
          'en': 'If that point is empty, take from a higher-numbered point.',
          'kz': 'Пункт бос болса, үлкенірек нөмірден шығарыңыз.',
        },
        {
          'ru': 'Цель — первым вывести все 15 шашек',
          'en': 'The goal is to bear off all 15 checkers first.',
          'kz': 'Мақсат — 15 шашканы бірінші болып шығару.',
        },
        {
          'ru': 'Используйте каждое выпавшее очко максимально эффективно',
          'en': 'Make every roll count during the race.',
          'kz': 'Жарыс кезінде әр лақтыруды тиімді пайдаланыңыз.',
        },
      ],
    },
    {
      'difficulty': 'hard',
      'title': {
        'ru': 'Тактика дублей',
        'en': 'Doubles Tactics',
        'kz': 'Дубль тактикасы',
      },
      'description': {
        'ru': 'Как эффективно использовать дубли',
        'en': 'How to get the most from doubles.',
        'kz': 'Дубльдерді тиімді пайдалану жолдары.',
      },
      'hints': [
        {
          'ru': 'Дубль дает четыре хода и считается мощным ресурсом',
          'en': 'A double gives four moves and is a huge resource.',
          'kz': 'Дубль төрт жүріс береді және өте қуатты ресурс.',
        },
        {
          'ru': 'Дубль 6-6 перемещает шашки на 24 пункта',
          'en': 'A 6-6 double can move checkers 24 points.',
          'kz': '6-6 дублі шашканы 24 пунктке жылжытады.',
        },
        {
          'ru': 'Используйте дубли для быстрого прорыва или вывода',
          'en': 'Use doubles for fast breakthroughs or bearing off.',
          'kz': 'Дубльдерді жылдам прорыв пен шығаруға қолданыңыз.',
        },
        {
          'ru': 'В начале игры дубль помогает занять ключевые пункты',
          'en': 'Early doubles help secure key points.',
          'kz': 'Ойын басында дубль маңызды пункттерді алуға көмектеседі.',
        },
        {
          'ru': 'В конце партии дубль ускоряет вывод шашек',
          'en': 'Late in the game a double speeds up bearing off.',
          'kz': 'Ойын соңында дубль шашкаларды тез шығаруға мүмкіндік береді.',
        },
      ],
    },
  ],
};

List<TrainingLesson> getTrainingLessons(String language, String gameKey) {
  final lessonsData = _trainingLessonsData[gameKey];
  if (lessonsData == null) {
    return const [];
  }
  return lessonsData
      .map(
        (lesson) => TrainingLesson(
          title: _localizedTrainingText(
            lesson['title'] as Map<String, String>,
            language,
          ),
          description: _localizedTrainingText(
            lesson['description'] as Map<String, String>,
            language,
          ),
          difficulty: _difficultyFromString(lesson['difficulty'] as String),
          aiHints: (lesson['hints'] as List<Map<String, String>>)
              .map((hint) => _localizedTrainingText(hint, language))
              .toList(growable: false),
        ),
      )
      .toList(growable: false);
}

String _localizedTrainingText(Map<String, String> values, String language) {
  return values[language] ?? values[_fallbackTrainingLanguage] ?? '';
}

TrainingDifficulty _difficultyFromString(String value) {
  switch (value) {
    case 'easy':
      return TrainingDifficulty.easy;
    case 'medium':
      return TrainingDifficulty.medium;
    case 'hard':
    default:
      return TrainingDifficulty.hard;
  }
}
