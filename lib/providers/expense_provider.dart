import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  static const _key = 'expense_data';
  final _uuid = const Uuid();
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _expenses = list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_expenses.map((e) => e.toJson()).toList()));
  }

  Future<void> addExpense(String title, double amount, ExpenseCategory category, {String note = '', DateTime? date}) async {
    _expenses.insert(0, Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
    ));
    notifyListeners();
    await _save();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  List<Expense> getByMonth(int year, int month) {
    return _expenses.where((e) => e.date.year == year && e.date.month == month).toList();
  }

  double totalByMonth(int year, int month) {
    return getByMonth(year, month).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalToday {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> categoryTotals(int year, int month) {
    final map = <ExpenseCategory, double>{};
    for (final e in getByMonth(year, month)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
