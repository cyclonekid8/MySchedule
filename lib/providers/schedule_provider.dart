import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/note.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Activity> _activities = [];
  List<Note> _notes = [];
  DateTime _selectedDay = DateTime.now();
  final _uuid = const Uuid();

  List<Activity> get activities => _activities;
  List<Note> get notes => _notes;
  DateTime get selectedDay => _selectedDay;

  List<Activity> get activitiesForSelectedDay {
    return _activities.where((a) {
      final same = _isSameDay(a.startTime, _selectedDay);
      if (same) return true;
      if (a.repeat == RepeatType.daily) return true;
      if (a.repeat == RepeatType.weekly &&
          a.startTime.weekday == _selectedDay.weekday) return true;
      if (a.repeat == RepeatType.monthly &&
          a.startTime.day == _selectedDay.day) return true;
      return false;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void addActivity(Activity activity) {
    _activities.add(activity);
    _save();
    notifyListeners();
  }

  void updateActivity(Activity activity) {
    final idx = _activities.indexWhere((a) => a.id == activity.id);
    if (idx != -1) {
      _activities[idx] = activity;
      _save();
      notifyListeners();
    }
  }

  void toggleDone(String id) {
    final idx = _activities.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _activities[idx] = _activities[idx].copyWith(
        isDone: !_activities[idx].isDone,
      );
      _save();
      notifyListeners();
    }
  }

  void deleteActivity(String id) {
    _activities.removeWhere((a) => a.id == id);
    _save();
    notifyListeners();
  }

  String generateId() => _uuid.v4();

  // Notes
  void addNote(Note note) {
    _notes.insert(0, note);
    _save();
    notifyListeners();
  }

  void updateNote(Note note) {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      _save();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _save();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final actJson = prefs.getString('activities');
    final noteJson = prefs.getString('notes');
    if (actJson != null) {
      final list = jsonDecode(actJson) as List;
      _activities = list.map((e) => Activity.fromJson(e)).toList();
    }
    if (noteJson != null) {
      final list = jsonDecode(noteJson) as List;
      _notes = list.map((e) => Note.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('activities', jsonEncode(_activities.map((a) => a.toJson()).toList()));
    prefs.setString('notes', jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }
}
