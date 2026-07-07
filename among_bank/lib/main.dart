import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/app_state.dart';
import 'screens/splash_screen.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const AmongBankApp(),
    ),
  );
}

class AmongBankApp extends StatelessWidget {
  const AmongBankApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Among Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          primary: kGold, secondary: kGoldDark, surface: kCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg, foregroundColor: Colors.white, elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: kCard2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGold, width: 1.5)),
          labelStyle: const TextStyle(color: Colors.white38),
          hintStyle: const TextStyle(color: Colors.white24),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
