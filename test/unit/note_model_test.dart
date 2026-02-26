import 'package:flutter_test/flutter_test.dart';
import 'package:myschedule/models/note.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Note Model', () {
    late Note note;
    final now = DateTime(2026, 2, 25, 10, 0);

    setUp(() {
      note = Note(
        id: 'note-id',
        title: 'Test Note',
        body: 'This is a test note body',
        createdAt: now,
        updatedAt: now,
      );
    });

    test('creates note with correct fields', () {
      expect(note.id, 'note-id');
      expect(note.title, 'Test Note');
      expect(note.body, 'This is a test note body');
      expect(note.createdAt, now);
      expect(note.updatedAt, now);
    });

    test('copyWith updates fields correctly', () {
      final later = now.add(const Duration(hours: 1));
      final updated = note.copyWith(
        title: 'Updated Title',
        body: 'Updated body',
        updatedAt: later,
      );
      expect(updated.title, 'Updated Title');
      expect(updated.body, 'Updated body');
      expect(updated.updatedAt, later);
      expect(updated.id, note.id); // id unchanged
      expect(updated.createdAt, note.createdAt); // createdAt unchanged
    });

    test('toJson and fromJson round trip', () {
      final json = note.toJson();
      final restored = Note.fromJson(json);
      expect(restored.id, note.id);
      expect(restored.title, note.title);
      expect(restored.body, note.body);
      expect(restored.createdAt, note.createdAt);
      expect(restored.updatedAt, note.updatedAt);
    });

    test('toJson contains all required keys', () {
      final json = note.toJson();
      expect(json.containsKey('id'), true);
      expect(json.containsKey('title'), true);
      expect(json.containsKey('body'), true);
      expect(json.containsKey('createdAt'), true);
      expect(json.containsKey('updatedAt'), true);
    });
  });
}
