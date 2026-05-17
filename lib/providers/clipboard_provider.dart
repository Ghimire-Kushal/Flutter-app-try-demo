import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/clipboard_item.dart';

class ClipboardProvider extends ChangeNotifier {
  static const _key = 'clipboard_data';
  final _uuid = const Uuid();
  List<ClipboardItem> _items = [];

  List<ClipboardItem> get items => _items;
  List<ClipboardItem> get pinned => _items.where((i) => i.isPinned).toList();
  List<ClipboardItem> get unpinned => _items.where((i) => !i.isPinned).toList();

  ClipboardProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _items = list.map((e) => ClipboardItem.fromJson(e as Map<String, dynamic>)).toList();
      _sort();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_items.map((i) => i.toJson()).toList()));
  }

  void _sort() {
    _items.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> addItem(String text) async {
    if (text.trim().isEmpty) return;
    if (_items.any((i) => i.text == text)) return;
    _items.insert(0, ClipboardItem(
      id: _uuid.v4(),
      text: text,
      createdAt: DateTime.now(),
    ));
    _sort();
    notifyListeners();
    await _save();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> togglePin(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx].isPinned = !_items[idx].isPinned;
      _sort();
      notifyListeners();
      await _save();
    }
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> clearAll() async {
    _items.removeWhere((i) => !i.isPinned);
    notifyListeners();
    await _save();
  }
}
