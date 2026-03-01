import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/income_provider.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IncomeProvider()..loadIncomes()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ── 3-Tone Palette ──
  static const Color deepNavy = Color(0xFF0A1128);
  static const Color darkGray = Color(0xFF1E2A3A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: deepNavy,
        colorScheme: ColorScheme.dark(
          primary: pureWhite,
          secondary: pureWhite,
          surface: darkGray,
          onPrimary: deepNavy,
          onSecondary: deepNavy,
          onSurface: pureWhite,
        ),
        textTheme: GoogleFonts.anuphanTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: deepNavy,
          foregroundColor: pureWhite,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.anuphan(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: pureWhite,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: pureWhite,
            foregroundColor: deepNavy,
            textStyle: GoogleFonts.anuphan(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
