import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/income_provider.dart';
import '../widgets/add_income_dialog.dart';
import '../models/income_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ── 3-Tone Palette ──
  static const Color deepNavy = Color(0xFF0A1128);
  static const Color darkGray = Color(0xFF1E2A3A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ── Icon-only vivid colors ──
  static const Color iconPending = Color(0xFFFF6B6B); // สด - ค้างรับ
  static const Color iconReceived = Color(0xFF69F0AE); // สด - ได้รับแล้ว
  static const Color iconCalendar = Color(0xFFFFD740); // สด - ปฏิทิน
  static const Color iconEdit = Color(0xFF42A5F5); // สด - แก้ไข

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      appBar: AppBar(
        backgroundColor: deepNavy,
        title: Text(
          'INCOME TRACKER',
          style: GoogleFonts.anuphan(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 18,
            color: pureWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: iconCalendar,
              size: 20,
            ),
            onPressed: () => _selectDateRange(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<IncomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: pureWhite),
            );
          }

          final filteredIncomes = provider.incomes.where((e) {
            if (_selectedIndex == 0) return !e.isPaid;
            return e.isPaid;
          }).toList();

          return Column(
            children: [
              _buildSummaryCard(provider),
              _buildActiveFilters(context, provider),
              _buildSectionHeader(filteredIncomes, provider),
              Expanded(
                child: filteredIncomes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        itemCount: filteredIncomes.length,
                        itemBuilder: (context, index) {
                          return _buildIncomeTile(
                            context,
                            filteredIncomes[index],
                            provider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: pureWhite,
        foregroundColor: deepNavy,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      bottomNavigationBar: _buildDock(),
    );
  }

  // ═══════════════════════════════════════
  // Summary Card
  // ═══════════════════════════════════════
  Widget _buildSummaryCard(IncomeProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkGray,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pureWhite.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ยอดรวมทั้งหมด',
            style: GoogleFonts.anuphan(
              color: pureWhite.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '฿${NumberFormat('#,###.00').format(provider.totalUnpaid + provider.totalPaid)}',
            style: GoogleFonts.anuphan(
              color: pureWhite,
              fontWeight: FontWeight.w800,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat(
                'ค้างรับ',
                provider.totalUnpaid,
                iconPending,
                Icons.arrow_downward_rounded,
              ),
              const SizedBox(width: 12),
              _buildMiniStat(
                'ได้รับแล้ว',
                provider.totalPaid,
                iconReceived,
                Icons.arrow_upward_rounded,
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
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: deepNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: pureWhite.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.anuphan(
                      color: pureWhite.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '฿${NumberFormat('#,###').format(amount)}',
                    style: GoogleFonts.anuphan(
                      color: pureWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Text(
            _selectedIndex == 0 ? 'รายการค้างรับ' : 'ประวัติการรับเงิน',
            style: GoogleFonts.anuphan(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: pureWhite.withValues(alpha: 0.35),
            ),
          ),
          const Spacer(),
          if (_selectedIndex == 0 && items.isNotEmpty)
            GestureDetector(
              onTap: () {
                final ids = items.map((e) => e.id!).toList();
                provider.markSelectedAsPaid(ids);
              },
              child: Text(
                'รับทั้งหมดแล้ว',
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: pureWhite.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Filters
  // ═══════════════════════════════════════
  Widget _buildActiveFilters(BuildContext context, IncomeProvider provider) {
    if (provider.startDate == null) return const SizedBox.shrink();
    final df = DateFormat('dd MMM yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: pureWhite.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range_rounded, size: 16, color: iconCalendar),
            const SizedBox(width: 8),
            Text(
              '${df.format(provider.startDate!)} – ${df.format(provider.endDate!)}',
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: pureWhite.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => provider.setFilter(null, null),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: pureWhite.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Income Tile
  // ═══════════════════════════════════════
  Widget _buildIncomeTile(
    BuildContext context,
    IncomeEntry entry,
    IncomeProvider provider,
  ) {
    final Color statusIconColor = entry.isPaid ? iconReceived : iconPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: darkGray,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pureWhite.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Icon(
          entry.isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
          color: statusIconColor,
          size: 28,
        ),
        title: Text(
          '฿${NumberFormat('#,###.00').format(entry.amount)}',
          style: GoogleFonts.anuphan(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: pureWhite,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              entry.note,
              style: GoogleFonts.anuphan(
                fontSize: 12,
                color: pureWhite.withValues(alpha: 0.4),
              ),
            ),
            Text(
              DateFormat('dd MMM yyyy').format(entry.date),
              style: GoogleFonts.anuphan(
                fontSize: 11,
                color: pureWhite.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz_rounded,
            color: pureWhite.withValues(alpha: 0.25),
          ),
          color: darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (val) {
            if (val == 'edit') {
              showDialog(
                context: context,
                builder: (_) => AddIncomeDialog(entry: entry),
              );
            } else if (val == 'paid') {
              provider.togglePaidStatus(entry);
            } else if (val == 'delete') {
              _confirmDelete(context, entry, provider);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'paid',
              child: Row(
                children: [
                  Icon(
                    entry.isPaid ? Icons.undo_rounded : Icons.verified_rounded,
                    size: 18,
                    color: entry.isPaid ? iconCalendar : iconReceived,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.isPaid ? 'ยกเลิกการรับ' : 'รับเงินแล้ว',
                    style: GoogleFonts.anuphan(color: pureWhite),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, size: 18, color: iconEdit),
                  const SizedBox(width: 12),
                  Text('แก้ไข', style: GoogleFonts.anuphan(color: pureWhite)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: iconPending,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ลบรายการ',
                    style: GoogleFonts.anuphan(color: iconPending),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Bottom Dock
  // ═══════════════════════════════════════
  Widget _buildDock() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: darkGray,
        border: Border(
          top: BorderSide(color: pureWhite.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockItem(0, Icons.grid_view_rounded, 'หน้าหลัก'),
          const SizedBox(width: 50),
          _buildDockItem(1, Icons.history_rounded, 'ประวัติ'),
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
              color: isSelected ? pureWhite : pureWhite.withValues(alpha: 0.2),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.anuphan(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? pureWhite
                    : pureWhite.withValues(alpha: 0.2),
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
            Icons.inbox_rounded,
            size: 56,
            color: pureWhite.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีรายการในขณะนี้',
            style: GoogleFonts.anuphan(
              color: pureWhite.withValues(alpha: 0.25),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Confirm Delete
  // ═══════════════════════════════════════
  void _confirmDelete(
    BuildContext context,
    IncomeEntry entry,
    IncomeProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'ยืนยันการลบ',
          style: GoogleFonts.anuphan(
            fontWeight: FontWeight.w700,
            color: pureWhite,
          ),
        ),
        content: Text(
          'คุณต้องการลบรายการนี้ใช่หรือไม่?',
          style: GoogleFonts.anuphan(color: pureWhite.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.anuphan(
                color: pureWhite.withValues(alpha: 0.4),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deleteIncome(entry.id!);
              Navigator.pop(context);
            },
            child: Text(
              'ลบ',
              style: GoogleFonts.anuphan(
                color: iconPending,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Date Range Picker
  // ═══════════════════════════════════════
  Future<void> _selectDateRange(BuildContext context) async {
    final provider = Provider.of<IncomeProvider>(context, listen: false);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: provider.startDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
    );
    if (picked != null) provider.setFilter(picked.start, picked.end);
  }

  void _showAddDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddIncomeDialog());
  }
}
