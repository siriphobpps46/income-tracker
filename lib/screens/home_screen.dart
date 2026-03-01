import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/income_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/add_income_dialog.dart';
import '../models/income_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ── Palette Accessors ──
  Color get background => Theme.of(context).scaffoldBackgroundColor;
  Color get onSurface => Theme.of(context).colorScheme.onSurface;
  Color get surface => Theme.of(context).colorScheme.surface;
  static const Color brandNavy = Color(0xFF0F172A);
  static const Color slateGray = Color(0xFF64748B);

  // ── Soft Status Colors ──
  static const Color softRed = Color(0xFFEF4444);
  static const Color softGreen = Color(0xFF10B981);
  static const Color softAmber = Color(0xFFF59E0B);
  static const Color softBlue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'INCOME TRACKER',
          style: GoogleFonts.anuphan(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 18,
            color: onSurface,
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: onSurface,
                  size: 22,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: onSurface, size: 22),
            onPressed: () => _showFilterOptions(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<IncomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: onSurface));
          }

          final filteredIncomes = provider.incomes.where((e) {
            if (_selectedIndex == 0) return !e.isPaid;
            return e.isPaid;
          }).toList();

          return Column(
            children: [
              _buildModernSummaryCard(provider),
              _buildActiveFilters(context, provider),
              _buildSectionHeader(filteredIncomes, provider),
              Expanded(
                child: filteredIncomes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => provider.loadIncomes(),
                        color: brandNavy,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                          itemCount: filteredIncomes.length,
                          itemBuilder: (context, index) {
                            return _buildIncomeTile(
                              context,
                              filteredIncomes[index],
                              provider,
                              index,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showIncomeForm(context);
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
      bottomNavigationBar: _buildModernDock(),
    );
  }

  // ═══════════════════════════════════════
  // Summary Card — Navy focal point with white text
  // ═══════════════════════════════════════
  Widget _buildModernSummaryCard(IncomeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.white : brandNavy;
    final cardTitleColor = isDark ? brandNavy : Colors.white;
    final cardSubtitleColor = isDark
        ? brandNavy.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ยอดรวมรายได้ทั้งหมด',
            style: GoogleFonts.anuphan(
              color: cardSubtitleColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '฿${NumberFormat('#,###.00').format(provider.totalUnpaid + provider.totalPaid)}',
            style: GoogleFonts.anuphan(
              color: cardTitleColor,
              fontWeight: FontWeight.w800,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildMiniStat(
                'ค้างรับ',
                provider.totalUnpaid,
                softRed,
                Icons.arrow_downward_rounded,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                'รับแล้ว',
                provider.totalPaid,
                softGreen,
                Icons.arrow_upward_rounded,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    double amount,
    Color iconColor,
    IconData icon,
    bool isDark,
  ) {
    final statBg = isDark
        ? brandNavy.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.1);
    final statBorder = isDark
        ? brandNavy.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.05);
    final statLabelColor = isDark
        ? brandNavy.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.5);
    final statAmountColor = isDark ? brandNavy : Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.anuphan(
                    color: statLabelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '฿${NumberFormat('#,###').format(amount)}',
              style: GoogleFonts.anuphan(
                color: statAmountColor,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Section Header
  // ═══════════════════════════════════════
  Widget _buildSectionHeader(List<IncomeEntry> items, IncomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            _selectedIndex == 0 ? 'รายการค้างรับ' : 'ประวัติการรับเงิน',
            style: GoogleFonts.anuphan(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const Spacer(),
          if (_selectedIndex == 0 && items.isNotEmpty)
            TextButton(
              onPressed: () {
                _showActionConfirmDialog(
                  context: context,
                  title: 'ยืนยันการรับเงินทั้งหมด',
                  message:
                      'คุณต้องการทำเครื่องหมายว่า "รับเงินแล้ว" สำหรับทุกรายการที่แสดงใช่หรือไม่?',
                  confirmLabel: 'ยืนยัน',
                  onConfirm: () {
                    final ids = items.map((e) => e.id!).toList();
                    provider.markSelectedAsPaid(ids);
                    _showSuccessSnackBar(
                      'ทำเครื่องหมายรับเงินแล้วทั้งหมดสำเร็จ',
                    );
                  },
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: softGreen,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'รับทั้งหมดแล้ว',
                style: GoogleFonts.anuphan(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (_selectedIndex == 1 && items.isNotEmpty)
            TextButton(
              onPressed: () {
                _showActionConfirmDialog(
                  context: context,
                  title: 'ค้างรับทั้งหมดใหม่',
                  message:
                      'คุณต้องการเปลี่ยนสถานะทุกรายการที่แสดงกลับเป็น "ค้างรับ" ใช่หรือไม่?',
                  confirmLabel: 'ยืนยัน',
                  confirmColor: softAmber,
                  onConfirm: () {
                    final ids = items.map((e) => e.id!).toList();
                    provider.markSelectedAsUnpaid(ids);
                    _showSuccessSnackBar(
                      'ยกเลิกการรับทั้งหมดสำเร็จ',
                      icon: Icons.undo_rounded,
                      color: softAmber,
                    );
                  },
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: softAmber,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'ยกเลิกการรับทั้งหมด',
                style: GoogleFonts.anuphan(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Active Filters
  // ═══════════════════════════════════════
  Widget _buildActiveFilters(BuildContext context, IncomeProvider provider) {
    if (provider.startDate == null) return const SizedBox.shrink();
    final df = DateFormat('dd MMM yyyy', 'th');
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: softAmber,
            ),
            const SizedBox(width: 10),
            Text(
              '${df.format(provider.startDate!)} – ${df.format(provider.endDate!)}',
              style: GoogleFonts.anuphan(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => provider.setFilter(null, null),
              child: Icon(
                Icons.cancel_rounded,
                size: 18,
                color: onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Income Tile — Pure white with subtle shadow
  // ═══════════════════════════════════════
  Widget _buildIncomeTile(
    BuildContext context,
    IncomeEntry entry,
    IncomeProvider provider,
    int index,
  ) {
    final statusColor = entry.isPaid ? softGreen : softAmber;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key('income_${entry.id}'),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Swipe left → Delete
            HapticFeedback.mediumImpact();
            bool? result;
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  'ยืนยันการลบ',
                  style: GoogleFonts.anuphan(
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                content: Text(
                  'คุณต้องการลบรายการนี้ใช่หรือไม่?',
                  style: GoogleFonts.anuphan(
                    color: onSurface.withValues(alpha: 0.7),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      result = false;
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'ยกเลิก',
                      style: GoogleFonts.anuphan(
                        color: onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      result = true;
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'ลบ',
                      style: GoogleFonts.anuphan(
                        color: softRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (result == true) {
              provider.deleteIncome(entry.id!);
              _showSuccessSnackBar(
                'ลบรายการสำเร็จ',
                icon: Icons.delete_rounded,
                color: softRed,
              );
            }
            return false; // don't auto-remove, provider handles it
          } else {
            // Swipe right → Toggle paid
            HapticFeedback.lightImpact();
            provider.togglePaidStatus(entry);
            _showSuccessSnackBar(
              entry.isPaid ? 'เปลี่ยนเป็นค้างรับสำเร็จ' : 'รับเงินแล้วสำเร็จ',
              icon: entry.isPaid
                  ? Icons.undo_rounded
                  : Icons.check_circle_rounded,
              color: entry.isPaid ? softAmber : softGreen,
            );
            return false;
          }
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: entry.isPaid ? softAmber : softGreen,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                entry.isPaid ? Icons.undo_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                entry.isPaid ? 'ยกเลิกการรับ' : 'รับเงินแล้ว',
                style: GoogleFonts.anuphan(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: softRed,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'ลบ',
                style: GoogleFonts.anuphan(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: statusColor, width: 5)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                title: Text(
                  '฿${NumberFormat('#,###.00').format(entry.amount)}',
                  style: GoogleFonts.anuphan(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: onSurface,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      entry.note,
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy', 'th').format(entry.date),
                      style: GoogleFonts.anuphan(
                        fontSize: 12,
                        color: onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: onSurface.withValues(alpha: 0.4),
                  ),
                  color: surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showIncomeForm(context, entry: entry);
                    } else if (val == 'paid') {
                      HapticFeedback.lightImpact();
                      _showActionConfirmDialog(
                        context: context,
                        title: entry.isPaid
                            ? 'ยกเลิกการรับเงิน'
                            : 'ยืนยันการรับเงิน',
                        message: entry.isPaid
                            ? 'ต้องการเปลี่ยนสถานะรายการนี้เป็น "ค้างรับ" ใช่หรือไม่?'
                            : 'ต้องการเปลี่ยนสถานะรายการนี้เป็น "รับเงินแล้ว" ใช่หรือไม่?',
                        confirmLabel: 'ตกลง',
                        confirmColor: entry.isPaid ? softAmber : softGreen,
                        onConfirm: () {
                          provider.togglePaidStatus(entry);
                          _showSuccessSnackBar(
                            entry.isPaid
                                ? 'เปลี่ยนเป็นค้างรับสำเร็จ'
                                : 'รับเงินแล้วสำเร็จ',
                            icon: entry.isPaid
                                ? Icons.undo_rounded
                                : Icons.check_circle_rounded,
                            color: entry.isPaid ? softAmber : softGreen,
                          );
                        },
                      );
                    } else if (val == 'delete') {
                      HapticFeedback.mediumImpact();
                      _showActionConfirmDialog(
                        context: context,
                        title: 'ยืนยันการลบ',
                        message: 'คุณต้องการลบรายการนี้ใช่หรือไม่?',
                        confirmLabel: 'ลบ',
                        confirmColor: softRed,
                        onConfirm: () {
                          provider.deleteIncome(entry.id!);
                          _showSuccessSnackBar(
                            'ลบรายการสำเร็จ',
                            icon: Icons.delete_rounded,
                            color: softRed,
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem(
                      'paid',
                      entry.isPaid
                          ? Icons.undo_rounded
                          : Icons.check_circle_rounded,
                      entry.isPaid ? 'ยกเลิกการรับ' : 'รับเงินแล้ว',
                      entry.isPaid ? softAmber : softGreen,
                    ),
                    _buildMenuItem(
                      'edit',
                      Icons.edit_rounded,
                      'แก้ไข',
                      softBlue,
                    ),
                    _buildMenuItem(
                      'delete',
                      Icons.delete_outline_rounded,
                      'ลบรายการ',
                      softRed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.anuphan(color: onSurface)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Success Toast (Top Overlay)
  // ═══════════════════════════════════════
  void _showSuccessSnackBar(
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color color = const Color(0xFF4CAF50),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _TopToast(
        message: message,
        icon: icon,
        color: color,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  // ═══════════════════════════════════════
  // Bottom Dock
  // ═══════════════════════════════════════
  Widget _buildModernDock() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: onSurface.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockItem(0, Icons.speed_rounded, 'หน้าหลัก'),
          const SizedBox(width: 50),
          _buildDockItem(1, Icons.assignment_rounded, 'ประวัติ'),
        ],
      ),
    );
  }

  Widget _buildDockItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : brandNavy)
                  : slateGray.withValues(alpha: 0.3),
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : brandNavy)
                    : slateGray.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Empty State
  // ═══════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีรายการในขณะนี้',
            style: GoogleFonts.anuphan(
              color: onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Action Confirmation Dialog
  // ═══════════════════════════════════════
  void _showActionConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: GoogleFonts.anuphan(
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.anuphan(color: onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.anuphan(
                color: onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(
              confirmLabel,
              style: GoogleFonts.anuphan(
                color: confirmColor ?? softBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: onSurface, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'กรองตามช่วงเวลา',
                    style: GoogleFonts.anuphan(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterItem(
              context,
              Icons.all_inclusive_rounded,
              'ทั้งหมด',
              null,
              null,
            ),
            _buildFilterItem(
              context,
              Icons.today_rounded,
              'วันนี้',
              todayStart,
              todayEnd,
            ),
            _buildFilterItem(
              context,
              Icons.calendar_view_week_rounded,
              'สัปดาห์นี้',
              weekStart,
              todayEnd,
            ),
            _buildFilterItem(
              context,
              Icons.calendar_month_rounded,
              'เดือนนี้',
              monthStart,
              monthEnd,
            ),
            _buildFilterItem(
              context,
              Icons.date_range_rounded,
              'เลือกช่วงเวลาเอง...',
              null,
              null,
              isCustom: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context,
    IconData icon,
    String label,
    DateTime? start,
    DateTime? end, {
    bool isCustom = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: onSurface.withValues(alpha: 0.7)),
      ),
      title: Text(
        label,
        style: GoogleFonts.anuphan(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.pop(context);
        if (isCustom) {
          _showDateRangePickerInternal(context);
        } else {
          Provider.of<IncomeProvider>(
            context,
            listen: false,
          ).setFilter(start, end);
        }
      },
    );
  }

  void _showDateRangePickerInternal(BuildContext context) {
    final provider = Provider.of<IncomeProvider>(context, listen: false);
    DateTime startDate = provider.startDate ?? DateTime.now();
    DateTime endDate = provider.endDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate({required bool isStart}) async {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final picked = await showDatePicker(
                context: context,
                initialDate: isStart ? startDate : endDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? Theme.of(context).colorScheme
                          : ColorScheme.light(
                              primary: brandNavy,
                              onPrimary: Colors.white,
                              surface: surface,
                              onSurface: brandNavy,
                            ),
                      dialogTheme: DialogThemeData(backgroundColor: surface),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setSheetState(() {
                  if (isStart) {
                    startDate = picked;
                    if (startDate.isAfter(endDate)) endDate = startDate;
                  } else {
                    endDate = picked;
                    if (endDate.isBefore(startDate)) startDate = endDate;
                  }
                });
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag Handle ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        color: onSurface,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'เลือกช่วงเวลา',
                        style: GoogleFonts.anuphan(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Start Date ──
                  Text(
                    'ตั้งแต่วันที่',
                    style: GoogleFonts.anuphan(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => pickDate(isStart: true),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: brandNavy,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            DateFormat('dd MMMM yyyy', 'th').format(startDate),
                            style: GoogleFonts.anuphan(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit_calendar_rounded,
                            size: 18,
                            color: onSurface.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── End Date ──
                  Text(
                    'ถึงวันที่',
                    style: GoogleFonts.anuphan(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => pickDate(isStart: false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: brandNavy,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            DateFormat('dd MMMM yyyy', 'th').format(endDate),
                            style: GoogleFonts.anuphan(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit_calendar_rounded,
                            size: 18,
                            color: onSurface.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.anuphan(
                              fontWeight: FontWeight.w700,
                              color: onSurface.withValues(alpha: 0.5),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final adjustedEnd = DateTime(
                              endDate.year,
                              endDate.month,
                              endDate.day,
                              23,
                              59,
                              59,
                            );
                            provider.setFilter(startDate, adjustedEnd);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                            shadowColor: brandNavy.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'ยืนยัน',
                            style: GoogleFonts.anuphan(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showIncomeForm(BuildContext context, {IncomeEntry? entry}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddIncomeDialog(entry: entry),
    );
  }
}

// ═══════════════════════════════════════════════
// Top Toast Widget
// ═══════════════════════════════════════════════
class _TopToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;

  const _TopToast({
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.anuphan(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
