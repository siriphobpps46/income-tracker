import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/income_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IncomeProvider()..loadIncomes()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ── Light Luxury Palette ──
  static const Color background = Color(0xFFF8FAFC); // ขาวนวล Slate
  static const Color surface = Color(0xFFFFFFFF); // ขาวสะอาด
  static const Color primaryNavy = Color(
    0xFF0F172A,
  ); // กรมเข้ม (สำหรับตัวหนังสือและปุ่ม)
  static const Color slateGray = Color(
    0xFF64748B,
  ); // เทา Slate (สำหรับตัวหนังสือรอง)

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Income Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('th', '')],
          locale: const Locale('th', ''),
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: background,
            colorScheme: ColorScheme.light(
              primary: primaryNavy,
              secondary: primaryNavy,
              surface: surface,
              onPrimary: Colors.white,
              onSurface: primaryNavy,
            ),
            textTheme: GoogleFonts.anuphanTextTheme(
              ThemeData.light().textTheme,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: background,
              foregroundColor: primaryNavy,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.anuphan(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primaryNavy,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryNavy,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.anuphan(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                shadowColor: primaryNavy.withValues(alpha: 0.3),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: primaryNavy,
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              secondary: Colors.white,
              surface: const Color(0xFF1E293B), // Slate 800
              onPrimary: primaryNavy,
              onSurface: Colors.white,
            ),
            textTheme: GoogleFonts.anuphanTextTheme(ThemeData.dark().textTheme),
            appBarTheme: AppBarTheme(
              backgroundColor: primaryNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.anuphan(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryNavy,
                textStyle: GoogleFonts.anuphan(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
