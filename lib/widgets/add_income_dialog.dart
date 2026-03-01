import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/income_provider.dart';
import '../models/income_entry.dart';

class AddIncomeDialog extends StatefulWidget {
  final IncomeEntry? entry;
  const AddIncomeDialog({super.key, this.entry});

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // ── Palette Accessors ──
  Color get background => Theme.of(context).scaffoldBackgroundColor;
  Color get onSurface => Theme.of(context).colorScheme.onSurface;
  Color get surface => Theme.of(context).colorScheme.surface;
  static const Color brandNavy = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _amountController.text = widget.entry!.amount.toString();
      _noteController.text = widget.entry!.note;
      _selectedDate = widget.entry!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag Handle ──
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text(
                    widget.entry == null ? 'เพิ่มรายการใหม่' : 'แก้ไขรายการ',
                    style: GoogleFonts.anuphan(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildLabel('จำนวนเงิน (฿)'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    autofocus: widget.entry == null,
                    decoration: _inputDecoration('0.00'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.anuphan(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('บันทึกช่วยจำ'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    decoration: _inputDecoration('ระบุรายละเอียด...'),
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('วันที่'),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: onSurface.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              'th',
                            ).format(_selectedDate),
                            style: GoogleFonts.anuphan(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.anuphan(
                              fontWeight: FontWeight.w700,
                              color: onSurface.withValues(alpha: 0.6),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 4,
                            shadowColor:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : brandNavy.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'บันทึก',
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.anuphan(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: onSurface.withValues(alpha: 0.5),
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.anuphan(color: onSurface.withValues(alpha: 0.3)),
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: onSurface, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
    );
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final provider = Provider.of<IncomeProvider>(context, listen: false);
    final isNew = widget.entry == null;
    if (isNew) {
      provider.addIncome(
        amount,
        _noteController.text.isEmpty ? 'ค่าตอบแทน' : _noteController.text,
        _selectedDate,
      );
    } else {
      final updated = widget.entry!.copyWith(
        amount: amount,
        note: _noteController.text.isEmpty ? 'ค่าตอบแทน' : _noteController.text,
        date: _selectedDate,
      );
      provider.updateIncome(updated);
    }
    Navigator.pop(context);

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SaveToast(
        message: isNew ? 'เพิ่มรายการสำเร็จ' : 'แก้ไขรายการสำเร็จ',
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _SaveToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const _SaveToast({required this.message, required this.onDismiss});

  @override
  State<_SaveToast> createState() => _SaveToastState();
}

class _SaveToastState extends State<_SaveToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted)
        _ctrl.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(_ctrl),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
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
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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
