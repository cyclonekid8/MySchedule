import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/models/activity.dart';
import 'package:myschedule/models/note.dart';
import 'package:myschedule/providers/schedule_provider.dart';

void main() {
  group('ScheduleProvider', () {
    late ScheduleProvider provider;
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = ScheduleProvider();
      await provider.load();
    });

    Activity makeActivity({
      String id = 'act-1',
      String title = 'Test Activity',
      DateTime? start,
      DateTime? end,
      Category category = Category.work,
      RepeatType repeat = RepeatType.none,
    }) {
      final s = start ?? DateTime(today.year, today.month, today.day, 9, 0);
      final e = end ?? s.add(const Duration(hours: 1));
      return Activity(
        id: id,
        title: title,
        startTime: s,
        endTime: e,
        category: category,
      );
    }

    Note makeNote({
      String id = 'note-1',
      String title = 'Test Note',
      String body = 'Test body',
    }) {
      final now = DateTime.now();
      return Note(id: id, title: title, body: body, createdAt: now, updatedAt: now);
    }

    // ── Activity tests ──────────────────────────────────────────────

    test('starts with empty activities', () {
      expect(provider.activities, isEmpty);
    });

    test('adds activity correctly', () async {
      await provider.addActivity(makeActivity());
      expect(provider.activities.length, 1);
      expect(provider.activities.first.title, 'Test Activity');
    });

    test('adds multiple activities', () async {
      await provider.addActivity(makeActivity(id: 'act-1', title: 'First'));
      await provider.addActivity(makeActivity(id: 'act-2', title: 'Second'));
      expect(provider.activities.length, 2);
    });

    test('updates activity correctly', () async {
      await provider.addActivity(makeActivity());
      final updated = provider.activities.first.copyWith(title: 'Updated Title');
      await provider.updateActivity(updated);
      expect(provider.activities.first.title, 'Updated Title');
      expect(provider.activities.length, 1);
    });

    test('deletes activity correctly', () async {
      await provider.addActivity(makeActivity(id: 'act-1'));
      await provider.addActivity(makeActivity(id: 'act-2', title: 'Second'));
      await provider.deleteActivity('act-1');
      expect(provider.activities.length, 1);
      expect(provider.activities.first.id, 'act-2');
    });

    test('toggleDone marks activity as done', () async {
      await provider.addActivity(makeActivity());
      expect(provider.activities.first.isDone, false);
      provider.toggleDone('act-1');
      expect(provider.activities.first.isDone, true);
    });

    test('toggleDone marks activity as not done again', () async {
      await provider.addActivity(makeActivity());
      provider.toggleDone('act-1');
      provider.toggleDone('act-1');
      expect(provider.activities.first.isDone, false);
    });

    test('activitiesForSelectedDay returns correct activities', () async {
      await provider.addActivity(makeActivity(id: 'today', start: DateTime(today.year, today.month, today.day, 9, 0)));
      await provider.addActivity(makeActivity(id: 'tomorrow', start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0)));
      provider.selectDay(today);
      expect(provider.activitiesForSelectedDay.length, 1);
      expect(provider.activitiesForSelectedDay.first.id, 'today');
    });

    test('daily repeat shows on every day', () async {
      await provider.addActivity(makeActivity(repeat: RepeatType.daily));
      provider.selectDay(tomorrow);
      expect(provider.activitiesForSelectedDay.length, 1);
    });

    test('weekly repeat shows on same weekday', () async {
      final monday = DateTime(2026, 2, 23, 9, 0); // a Monday
      final nextMonday = monday.add(const Duration(days: 7));
      await provider.addActivity(makeActivity(start: monday, repeat: RepeatType.weekly));
      provider.selectDay(nextMonday);
      expect(provider.activitiesForSelectedDay.length, 1);
    });

    test('weekly repeat does not show on different weekday', () async {
      final monday = DateTime(2026, 2, 23, 9, 0);
      final tuesday = monday.add(const Duration(days: 1));
      await provider.addActivity(makeActivity(start: monday, repeat: RepeatType.weekly));
      provider.selectDay(tuesday);
      expect(provider.activitiesForSelectedDay, isEmpty);
    });

    test('activitiesForSelectedDay sorted by start time', () async {
      await provider.addActivity(makeActivity(id: 'late', start: DateTime(today.year, today.month, today.day, 14, 0)));
      await provider.addActivity(makeActivity(id: 'early', start: DateTime(today.year, today.month, today.day, 8, 0)));
      provider.selectDay(today);
      expect(provider.activitiesForSelectedDay.first.id, 'early');
      expect(provider.activitiesForSelectedDay.last.id, 'late');
    });

    // ── Note tests ──────────────────────────────────────────────────

    test('starts with empty notes', () {
      expect(provider.notes, isEmpty);
    });

    test('adds note correctly', () {
      provider.addNote(makeNote());
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Test Note');
    });

    test('new note appears at top of list', () {
      provider.addNote(makeNote(id: 'note-1', title: 'First'));
      provider.addNote(makeNote(id: 'note-2', title: 'Second'));
      expect(provider.notes.first.title, 'Second');
    });

    test('updates note correctly', () {
      provider.addNote(makeNote());
      final updated = provider.notes.first.copyWith(title: 'Updated');
      provider.updateNote(updated);
      expect(provider.notes.first.title, 'Updated');
    });

    test('deletes note correctly', () {
      provider.addNote(makeNote(id: 'note-1'));
      provider.addNote(makeNote(id: 'note-2', title: 'Second'));
      provider.deleteNote('note-1');
      expect(provider.notes.length, 1);
      expect(provider.notes.first.id, 'note-2');
    });

    // ── Persistence tests ───────────────────────────────────────────

    test('data persists after save and reload', () async {
      await provider.addActivity(makeActivity(title: 'Persistent Activity'));
      provider.addNote(makeNote(title: 'Persistent Note'));

      final provider2 = ScheduleProvider();
      await provider2.load();

      expect(provider2.activities.length, 1);
      expect(provider2.activities.first.title, 'Persistent Activity');
      expect(provider2.notes.length, 1);
      expect(provider2.notes.first.title, 'Persistent Note');
    });

    test('clearAll removes all activities and notes', () async {
      await provider.addActivity(makeActivity());
      provider.addNote(makeNote());
      await provider.clearAll();
      expect(provider.activities, isEmpty);
      expect(provider.notes, isEmpty);
    });

    test('clearAll persists after reload', () async {
      await provider.addActivity(makeActivity());
      provider.addNote(makeNote());
      await provider.clearAll();

      final provider2 = ScheduleProvider();
      await provider2.load();
      expect(provider2.activities, isEmpty);
      expect(provider2.notes, isEmpty);
    });

    // ── Free tier tests ─────────────────────────────────────────────

    test('generateId returns unique ids', () {
      final id1 = provider.generateId();
      final id2 = provider.generateId();
      expect(id1, isNot(equals(id2)));
    });

    test('selectDay updates selected day', () {
      provider.selectDay(tomorrow);
      expect(provider.selectedDay.day, tomorrow.day);
    });
  });
}
