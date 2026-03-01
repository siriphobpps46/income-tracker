import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // ── 3-Tone Palette ──
  static const Color deepNavy = Color(0xFF0A1128);
  static const Color darkGray = Color(0xFF1E2A3A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo ──
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: darkGray,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: pureWhite.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 72,
                  color: pureWhite,
                ),
              ),
              const SizedBox(height: 48),

              Text(
                'INCOME TRACKER',
                style: GoogleFonts.anuphan(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: pureWhite,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ระบบบันทึกค่าตอบแทนรายวัน\nจัดการยอดง่าย ดูสรุปได้ทุกเมื่อ',
                textAlign: TextAlign.center,
                style: GoogleFonts.anuphan(
                  fontSize: 15,
                  color: pureWhite.withValues(alpha: 0.4),
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 3),

              // ── CTA ──
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
                    backgroundColor: pureWhite,
                    foregroundColor: deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'เริ่มใช้งาน',
                        style: GoogleFonts.anuphan(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
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
