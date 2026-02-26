import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ── E2E Flow 1: First time user adds an activity ──────────────────
  group('E2E: Adding an activity', () {
    testWidgets('user can add a new activity from Schedule screen', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap FAB on schedule screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should be on Add Activity screen
      expect(find.text('Add Activity'), findsOneWidget);

      // Enter activity name
      await tester.enterText(
        find.byType(TextField).first,
        'Morning Prayer',
      );

      // Tap Save Activity
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should be back on Schedule screen with activity visible
      expect(find.text('Morning Prayer'), findsOneWidget);
    });

    testWidgets('user can add activity from Calendar screen', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Calendar tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Add Activity'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Team Meeting');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Team Meeting'), findsOneWidget);
    });
  });

  // ── E2E Flow 2: Edit an existing activity ─────────────────────────
  group('E2E: Editing an activity', () {
    testWidgets('user can edit activity title via long press', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add activity first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Old Title');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Long press to get options
      await tester.longPress(find.text('Old Title'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Edit Activity'), findsOneWidget);

      // Clear and enter new title
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      textField.controller?.clear();
      await tester.enterText(find.byType(TextField).first, 'New Title');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('New Title'), findsOneWidget);
      expect(find.text('Old Title'), findsNothing);
    });
  });

  // ── E2E Flow 3: Delete an activity ───────────────────────────────
  group('E2E: Deleting an activity', () {
    testWidgets('user can delete activity via long press', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add activity
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Delete Me');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Delete Me'), findsOneWidget);

      // Long press and delete
      await tester.longPress(find.text('Delete Me'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Delete Me'), findsNothing);
    });
  });

  // ── E2E Flow 4: Mark activity as done ────────────────────────────
  group('E2E: Marking activity as done', () {
    testWidgets('user can toggle done checkbox on activity', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add activity with completion tracking
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Task To Complete');

      // Enable mark as done toggle
      final toggles = find.byType(Switch);
      if (toggles.evaluate().isNotEmpty) {
        await tester.tap(toggles.first);
        await tester.pump();
      }

      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap the checkbox
      final checkboxes = find.byType(AnimatedContainer);
      if (checkboxes.evaluate().isNotEmpty) {
        await tester.tap(checkboxes.first);
        await tester.pump();
      }
    });
  });

  // ── E2E Flow 5: Notes flow ────────────────────────────────────────
  group('E2E: Notes', () {
    testWidgets('user can create and view a note', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Notes tab
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('New Note'), findsOneWidget);

      // Enter title and body
      await tester.enterText(
        find.byType(TextField).first,
        'My First Note',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'This is the content',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('My First Note'), findsOneWidget);
    });

    testWidgets('user can edit an existing note', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create note
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Original Title');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap note to edit
      await tester.tap(find.text('Original Title'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Edit Note'), findsOneWidget);

      // Update title
      final titleField = find.byType(TextField).first;
      await tester.tap(titleField);
      await tester.pump();
      await tester.enterText(titleField, 'Updated Title');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Updated Title'), findsOneWidget);
    });

    testWidgets('user can search notes', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add two notes
      for (final title in ['Shopping List', 'Work Tasks']) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.enterText(find.byType(TextField).first, title);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Search
      await tester.enterText(find.byType(TextField).first, 'Shopping');
      await tester.pump();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Work Tasks'), findsNothing);
    });
  });

  // ── E2E Flow 6: Navigation between tabs ──────────────────────────
  group('E2E: Tab navigation', () {
    testWidgets('user can navigate between all tabs', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Schedule (default)
      expect(find.text('MySchedule'), findsOneWidget);

      // Calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Calendar'), findsOneWidget);

      // Notes
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Notes'), findsOneWidget);

      // Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Settings'), findsOneWidget);

      // Back to Schedule
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('MySchedule'), findsOneWidget);
    });
  });

  // ── E2E Flow 7: Settings ─────────────────────────────────────────
  group('E2E: Settings', () {
    testWidgets('user can toggle light mode', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find and tap light mode switch
      final switches = find.byType(Switch);
      await tester.tap(switches.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('user can change week start day', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Week starts on'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Sunday'), findsOneWidget);
      await tester.tap(find.text('Sunday'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Sunday'), findsOneWidget);
    });
  });

  // ── E2E Flow 8: Free tier limits ─────────────────────────────────
  group('E2E: Free tier limits', () {
    testWidgets('free user hits paywall after 2 activities on same day', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add 2 activities
      for (int i = 1; i <= 2; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.enterText(find.byType(TextField).first, 'Activity $i');
        await tester.tap(find.text('Save Activity'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Try to add 3rd
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Activity 3');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should see paywall
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('free user hits paywall after 1 note', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add 1 note
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Note 1');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to add 2nd note
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.textContaining('Premium'), findsWidgets);
    });
  });

  // ── E2E Flow 9: Premium simulate toggle ──────────────────────────
  group('E2E: Simulate Premium', () {
    testWidgets('enabling simulate premium removes limits', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Enable simulate premium in settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.scrollUntilVisible(find.text('Simulate Premium'), 200);
      final simulateSwitches = find.byType(Switch);
      await tester.tap(simulateSwitches.last);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Go back and add 3 activities freely
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      for (int i = 1; i <= 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.enterText(find.byType(TextField).first, 'Activity $i');
        await tester.tap(find.text('Save Activity'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // All 3 should be saved without paywall
      expect(find.text('Activity 1'), findsOneWidget);
      expect(find.text('Activity 2'), findsOneWidget);
      expect(find.text('Activity 3'), findsOneWidget);
    });
  });

  // ── E2E Flow 10: Data persistence across app restart ─────────────
  group('E2E: Data persistence', () {
    testWidgets('activity persists after provider reload', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Add activity
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).first, 'Persistent Task');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Persistent Task'), findsOneWidget);

      // Re-launch app (simulated by restarting widget)
      await tester.pumpWidget(const SizedBox());
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Persistent Task'), findsOneWidget);
    });
  });
}
