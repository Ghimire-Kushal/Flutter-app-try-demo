import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

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
      _tasks =
          list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      // Reschedule all future reminders on cold start
      for (final task in _tasks) {
        if (!task.isCompleted &&
            task.reminderTime != null &&
            task.reminderTime!.isAfter(DateTime.now())) {
          _scheduleReminder(task);
        }
      }
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }

  void _scheduleReminder(Task task) {
    if (task.reminderTime == null) return;
    NotificationService().scheduleReminder(
      id: NotificationService().idFromTaskId(task.id),
      taskTitle: task.title,
      scheduledTime: task.reminderTime!,
    );
  }

  void _cancelReminder(String taskId) {
    NotificationService()
        .cancel(NotificationService().idFromTaskId(taskId));
  }

  Future<void> addTask(
    String title, {
    String description = '',
    int priority = 1,
    DateTime? dueDate,
    DateTime? reminderTime,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, task);
    if (reminderTime != null) _scheduleReminder(task);
    notifyListeners();
    await _save();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
    // Cancel reminder when task is completed
    if (_tasks[idx].isCompleted) _cancelReminder(id);
    notifyListeners();
    await _save();
  }

  Future<void> deleteTask(String id) async {
    _cancelReminder(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;
    _cancelReminder(task.id);
    _tasks[idx] = task;
    if (!task.isCompleted && task.reminderTime != null) {
      _scheduleReminder(task);
    }
    notifyListeners();
    await _save();
  }

  Future<void> clearCompleted() async {
    for (final t in _tasks.where((t) => t.isCompleted)) {
      _cancelReminder(t.id);
    }
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
    await _save();
  }
}
