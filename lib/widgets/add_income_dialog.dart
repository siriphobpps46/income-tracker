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

  // ── 3-Tone Palette ──
  static const Color deepNavy = Color(0xFF0A1128);
  static const Color darkGray = Color(0xFF1E2A3A);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color iconCalendar = Color(0xFFFFD740);

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: darkGray,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.entry == null ? 'เพิ่มรายการใหม่' : 'แก้ไขรายการ',
              style: GoogleFonts.anuphan(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: pureWhite,
              ),
            ),
            const SizedBox(height: 28),

            _buildLabel('จำนวนเงิน (฿)'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: _inputDecoration('0.00'),
              keyboardType: TextInputType.number,
              style: GoogleFonts.anuphan(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: pureWhite,
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('บันทึกช่วยจำ'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: _inputDecoration('ระบุรายละเอียด...'),
              style: GoogleFonts.anuphan(fontSize: 14, color: pureWhite),
            ),
            const SizedBox(height: 20),

            _buildLabel('วันที่'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: deepNavy,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: pureWhite.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: iconCalendar,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: pureWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ยกเลิก',
                      style: GoogleFonts.anuphan(
                        fontWeight: FontWeight.w600,
                        color: pureWhite.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pureWhite,
                      foregroundColor: deepNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'บันทึก',
                      style: GoogleFonts.anuphan(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: pureWhite.withValues(alpha: 0.35),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.anuphan(color: pureWhite.withValues(alpha: 0.15)),
      filled: true,
      fillColor: deepNavy,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: pureWhite.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: pureWhite.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: pureWhite.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
