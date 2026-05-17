import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TodoProvider extends ChangeNotifier {
  static const _key = 'todo_data';
  final _uuid = const Uuid();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get pending => _tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));
  List<Task> get completed => _tasks.where((t) => t.isCompleted).toList();

  TodoProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _tasks = list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> addTask(String title, {String description = '', int priority = 1, DateTime? dueDate}) async {
    _tasks.insert(0, Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    await _save();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      notifyListeners();
      await _save();
    }
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
    await _save();
  }
}
