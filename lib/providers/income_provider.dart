import 'package:flutter/material.dart';
import '../models/income_entry.dart';
import '../services/database_helper.dart';

class IncomeProvider with ChangeNotifier {
  List<IncomeEntry> _incomes = [];
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  List<IncomeEntry> get incomes => _incomes;
  bool get isLoading => _isLoading;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  double get totalUnpaid {
    return _incomes
        .where((e) => !e.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalPaid {
    return _incomes
        .where((e) => e.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> loadIncomes() async {
    _isLoading = true;
    notifyListeners();

    _incomes = await DatabaseHelper().getIncomes(
      start: _startDate,
      end: _endDate,
    );

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadIncomes();
  }

  Future<void> addIncome(double amount, String note, DateTime date) async {
    final entry = IncomeEntry(amount: amount, note: note, date: date);
    await DatabaseHelper().insertIncome(entry);
    await loadIncomes();
  }

  Future<void> markSelectedAsPaid(List<int> ids) async {
    await DatabaseHelper().markAsPaid(ids);
    await loadIncomes();
  }

  Future<void> deleteIncome(int id) async {
    await DatabaseHelper().deleteIncome(id);
    await loadIncomes();
  }

  Future<void> updateIncome(IncomeEntry entry) async {
    await DatabaseHelper().updateIncome(entry);
    await loadIncomes();
  }

  Future<void> togglePaidStatus(IncomeEntry entry) async {
    final updated = entry.copyWith(isPaid: !entry.isPaid);
    await DatabaseHelper().updateIncome(updated);
    await loadIncomes();
  }
}
