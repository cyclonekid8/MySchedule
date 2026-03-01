import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/note.dart';
import '../services/notification_service.dart';

class CustomCategory {
  final String id;
  final String name;
  final Color color;
  final String emoji;

  CustomCategory({
    required this.id,
    required this.name,
    required this.color,
    this.emoji = '⭐',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value,
    'emoji': emoji,
  };

  factory CustomCategory.fromJson(Map<String, dynamic> json) => CustomCategory(
    id: json['id'],
    name: json['name'],
    color: Color(json['color']),
    emoji: json['emoji'] ?? '⭐',
  );
}

class ScheduleProvider extends ChangeNotifier {
  List<Activity> _activities = [];
  List<Note> _notes = [];
  List<CustomCategory> _customCategories = [];
  DateTime _selectedDay = DateTime.now();
  final _uuid = const Uuid();
  final bool _skipNotifications;
  BuildContext? _context;

  ScheduleProvider({bool skipNotifications = false})
      : _skipNotifications = skipNotifications;

  NotificationService? get _notifService =>
      _skipNotifications ? null : NotificationService();

  void setContext(BuildContext context) {
    _context = context;
    // Set up snackbar callback for notification service
    _notifService?.setUserFeedbackCallback((message) {
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
      }
    });
  }

  List<Activity> get activities => _activities;
  List<Note> get notes => _notes;
  List<CustomCategory> get customCategories => _customCategories;
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

  // ── Custom Categories ──────────────────────────────────────────

  Future<void> addCustomCategory(CustomCategory category) async {
    _customCategories.add(category);
    await _save();
    notifyListeners();
  }

  Future<void> removeCustomCategory(String id) async {
    _customCategories.removeWhere((c) => c.id == id);
    await _save();
    notifyListeners();
  }

  // ── Activities ─────────────────────────────────────────────────

  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);
    await _notifService?.scheduleActivityReminder(activity);
    await _save();
    notifyListeners();
  }

  Future<void> updateActivity(Activity activity) async {
    final idx = _activities.indexWhere((a) => a.id == activity.id);
    if (idx != -1) {
      final oldActivity = _activities[idx];
      _activities[idx] = activity;
      
      // If activity has reminders and time changed, update the scheduled notification
      if (activity.hasReminder) {
        // Cancel old reminder first
        await _notifService?.cancelActivityReminder(activity.id);
        // Schedule new reminder with updated time
        await _notifService?.scheduleActivityReminder(activity);
      } else if (oldActivity.hasReminder && !activity.hasReminder) {
        // Reminder was disabled, cancel it
        await _notifService?.cancelActivityReminder(activity.id);
      }
      
      await _save();
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

  Future<void> deleteActivity(String id) async {
    await _notifService?.cancelActivityReminder(id);
    _activities.removeWhere((a) => a.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _notifService?.cancelAll();
    _activities = [];
    _notes = [];
    _customCategories = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activities');
    await prefs.remove('notes');
    await prefs.remove('custom_categories');
    notifyListeners();
  }

  String generateId() => _uuid.v4();

  // ── Notes ──────────────────────────────────────────────────────

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

  // ── Persistence ────────────────────────────────────────────────

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actJson = prefs.getString('activities');
      final noteJson = prefs.getString('notes');
      final catJson = prefs.getString('custom_categories');
      if (actJson != null) {
        try {
          final list = jsonDecode(actJson) as List;
          _activities = list.map((e) => Activity.fromJson(e)).toList();
        } catch (e) {
          _activities = [];
        }
      }
      if (noteJson != null) {
        try {
          final list = jsonDecode(noteJson) as List;
          _notes = list.map((e) => Note.fromJson(e)).toList();
        } catch (e) {
          _notes = [];
        }
      }
      if (catJson != null) {
        try {
          final list = jsonDecode(catJson) as List;
          _customCategories = list.map((e) => CustomCategory.fromJson(e)).toList();
        } catch (e) {
          _customCategories = [];
        }
      }
    } catch (e) {
      _activities = [];
      _notes = [];
      _customCategories = [];
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('activities',
        jsonEncode(_activities.map((a) => a.toJson()).toList()));
    prefs.setString(
        'notes', jsonEncode(_notes.map((n) => n.toJson()).toList()));
    prefs.setString('custom_categories',
        jsonEncode(_customCategories.map((c) => c.toJson()).toList()));
  }
}
