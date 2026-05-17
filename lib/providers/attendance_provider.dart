import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_subject.dart';

class AttendanceProvider extends ChangeNotifier {
  static const _key = 'attendance_data';
  final _uuid = const Uuid();
  List<AttendanceSubject> _subjects = [];

  List<AttendanceSubject> get subjects => _subjects;

  AttendanceProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _subjects = list.map((e) => AttendanceSubject.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_subjects.map((s) => s.toJson()).toList()));
  }

  Future<void> addSubject(String name) async {
    _subjects.add(AttendanceSubject(id: _uuid.v4(), name: name));
    notifyListeners();
    await _save();
  }

  Future<void> deleteSubject(String id) async {
    _subjects.removeWhere((s) => s.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> markAttended(String id) async {
    final idx = _subjects.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _subjects[idx].attendedClasses++;
      _subjects[idx].totalClasses++;
      notifyListeners();
      await _save();
    }
  }

  Future<void> markAbsent(String id) async {
    final idx = _subjects.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _subjects[idx].totalClasses++;
      notifyListeners();
      await _save();
    }
  }

  Future<void> updateCounts(String id, int attended, int total) async {
    final idx = _subjects.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _subjects[idx].attendedClasses = attended;
      _subjects[idx].totalClasses = total;
      notifyListeners();
      await _save();
    }
  }
}
