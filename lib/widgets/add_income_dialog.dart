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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  border: Border.all(color: onSurface.withValues(alpha: 0.05)),
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
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
    if (widget.entry == null) {
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
  }
}
