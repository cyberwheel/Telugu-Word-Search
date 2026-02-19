import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  runApp(
    const ProviderScope(
      child: TeluguPuzzleApp(),
    ),
  );
}

class TeluguPuzzleApp extends StatelessWidget {
  const TeluguPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.ramabhadraTextTheme().copyWith(
          bodyLarge: const TextStyle(height: 1.5),
          bodyMedium: const TextStyle(height: 1.5),
          bodySmall: const TextStyle(height: 1.5),
          headlineLarge: const TextStyle(height: 1.5),
          headlineMedium: const TextStyle(height: 1.5),
          headlineSmall: const TextStyle(height: 1.5),
          titleLarge: const TextStyle(height: 1.5),
          titleMedium: const TextStyle(height: 1.5),
          titleSmall: const TextStyle(height: 1.5),
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}
