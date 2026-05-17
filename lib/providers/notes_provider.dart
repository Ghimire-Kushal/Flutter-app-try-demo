import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  static const _key = 'notes_data';
  final _uuid = const Uuid();
  List<Note> _notes = [];

  List<Note> get notes => _notes;
  List<Note> get pinnedNotes => _notes.where((n) => n.isPinned).toList();
  List<Note> get unpinnedNotes => _notes.where((n) => !n.isPinned).toList();

  NotesProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _notes = list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
      _sort();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  void _sort() {
    _notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  Future<void> addNote(String title, String content, {String colorHex = '#FFFFFF'}) async {
    final now = DateTime.now();
    _notes.insert(0, Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      colorHex: colorHex,
    ));
    _sort();
    notifyListeners();
    await _save();
  }

  Future<void> updateNote(Note note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      note.updatedAt = DateTime.now();
      _notes[idx] = note;
      _sort();
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> togglePin(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notes[idx].isPinned = !_notes[idx].isPinned;
      _sort();
      notifyListeners();
      await _save();
    }
  }

  List<Note> search(String query) {
    final q = query.toLowerCase();
    return _notes.where((n) =>
        n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q)).toList();
  }
}
