import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myschedule/models/activity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Activity Model', () {
    late Activity activity;

    setUp(() {
      activity = Activity(
        id: 'test-id',
        title: 'Morning Prayer',
        startTime: DateTime(2026, 2, 25, 9, 0),
        endTime: DateTime(2026, 2, 25, 10, 0),
        category: Category.prayer,
      );
    });

    test('creates activity with correct fields', () {
      expect(activity.id, 'test-id');
      expect(activity.title, 'Morning Prayer');
      expect(activity.category, Category.prayer);
      expect(activity.repeat, RepeatType.none);
      expect(activity.isDone, false);
      expect(activity.hasReminder, false);
    });

    test('displayCategory returns correct label for standard category', () {
      expect(activity.displayCategory, 'Prayer');
    });

    test('displayCategory returns custom name for custom category', () {
      final custom = activity.copyWith(
        category: Category.custom,
        customCategoryName: 'My Custom',
      );
      expect(custom.displayCategory, 'My Custom');
    });

    test('displayColor returns correct color for standard category', () {
      expect(activity.displayColor, const Color(0xFFF9CA24));
    });

    test('displayColor returns custom color for custom category', () {
      final custom = activity.copyWith(
        category: Category.custom,
        customCategoryColor: Colors.red,
      );
      expect(custom.displayColor, Colors.red);
    });

    test('copyWith updates fields correctly', () {
      final updated = activity.copyWith(
        title: 'Evening Prayer',
        isDone: true,
      );
      expect(updated.title, 'Evening Prayer');
      expect(updated.isDone, true);
      expect(updated.id, activity.id); // id unchanged
      expect(updated.category, activity.category); // category unchanged
    });

    test('toJson and fromJson round trip', () {
      final json = activity.toJson();
      final restored = Activity.fromJson(json);
      expect(restored.id, activity.id);
      expect(restored.title, activity.title);
      expect(restored.category, activity.category);
      expect(restored.startTime, activity.startTime);
      expect(restored.endTime, activity.endTime);
      expect(restored.repeat, activity.repeat);
      expect(restored.isDone, activity.isDone);
    });

    test('end time after start time is valid', () {
      expect(activity.endTime.isAfter(activity.startTime), true);
    });
  });

  group('Category Extension', () {
    test('all categories have labels', () {
      for (final cat in Category.values) {
        expect(cat.label, isNotEmpty);
      }
    });

    test('all categories have colors', () {
      for (final cat in Category.values) {
        expect(cat.color, isNotNull);
      }
    });

    test('all categories have emojis', () {
      for (final cat in Category.values) {
        expect(cat.emoji, isNotEmpty);
      }
    });

    test('free categories are correct', () {
      expect(freeCategories, contains(Category.work));
      expect(freeCategories, contains(Category.personal));
      expect(freeCategories, contains(Category.healthFitness));
      expect(freeCategories, isNot(contains(Category.prayer)));
      expect(freeCategories, isNot(contains(Category.social)));
    });

    test('isFree returns true for free categories', () {
      expect(Category.work.isFree, true);
      expect(Category.personal.isFree, true);
      expect(Category.healthFitness.isFree, true);
    });

    test('isFree returns false for premium categories', () {
      expect(Category.prayer.isFree, false);
      expect(Category.social.isFree, false);
      expect(Category.tankMaintenance.isFree, false);
    });
  });

  group('RepeatType Extension', () {
    test('all repeat types have labels', () {
      for (final r in RepeatType.values) {
        expect(r.label, isNotEmpty);
      }
    });
  });
}
