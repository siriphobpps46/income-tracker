import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // ── Palette Accessors ──
  Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color primaryNavy(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  Color slateGray(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
      const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo with soft elevation ──
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: primaryNavy(context),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryNavy(context).withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 48),

              Text(
                'INCOME TRACKER',
                style: GoogleFonts.anuphan(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: primaryNavy(context),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ระบบบันทึกค่าตอบแทนรายวัน\nจัดการยอดง่าย ดูสรุปได้ทุกเมื่อ',
                textAlign: TextAlign.center,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  color: slateGray(context),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 3),

              // ── CTA Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy(context),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 4,
                    shadowColor:
                        (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.5)
                        : primaryNavy(context).withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'เริ่มใช้งาน',
                        style: GoogleFonts.anuphan(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
