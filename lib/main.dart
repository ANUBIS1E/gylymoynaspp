import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';   // Правильный импорт
import 'screens/main_menu_screen.dart'; // Правильный импорт
import 'screens/training_screen_new.dart'; // Импорт экрана Training

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.amber.shade700; // Золотистый
    final darkBg = Colors.blueGrey.shade800; // Фон из редизайна

    return MaterialApp(
      title: 'Gylym Oyna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: accentColor,
        scaffoldBackgroundColor: darkBg, // Темно-сине-серый фон

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black.withOpacity(0.2),
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          iconTheme: IconThemeData(color: Colors.white70),
        ),

        textTheme: TextTheme(
           headlineMedium: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 5, color: Colors.black54, offset: Offset(2,2))]),
           bodyLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white),
           bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white70),
           labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ).apply(
            bodyColor: Colors.white.withOpacity(0.9),
            displayColor: Colors.white,
        ),

        cardTheme: CardThemeData(
            color: Colors.brown.shade300.withOpacity(0.1),
            elevation: 8.0,
            shadowColor: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
        ),

         elevatedButtonTheme: ElevatedButtonThemeData(
           style: ElevatedButton.styleFrom(
             backgroundColor: accentColor,
             foregroundColor: Colors.black87,
             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
             textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
             elevation: 5,
           )
         ),
         
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
               foregroundColor: accentColor,
               side: BorderSide(color: accentColor.withOpacity(0.7), width: 1.5),
               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
               textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
         ),

        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) return accentColor.withOpacity(0.3);
                return Colors.black.withOpacity(0.2);
              },
            ),
             foregroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) return Colors.white;
                return Colors.white70;
              },
            ),
             side: MaterialStateProperty.all(BorderSide(color: accentColor.withOpacity(0.4))),
             shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
             textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14)),
          )
        ),

        dialogTheme: DialogThemeData(
           backgroundColor: Colors.brown.shade700,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
           titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
           contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
        ),

        textButtonTheme: TextButtonThemeData(
           style: TextButton.styleFrom(
              foregroundColor: accentColor,
               textStyle: const TextStyle(fontWeight: FontWeight.bold),
           )
        )
      ),
      
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => MainMenuScreen(),
        '/training': (context) => TrainingScreenNew(), // Добавили маршрут
      },
    );
  }
}