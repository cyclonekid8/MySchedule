import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/models/note.dart';
import 'package:myschedule/providers/schedule_provider.dart';
import 'package:myschedule/providers/theme_provider.dart';
import 'package:myschedule/services/purchase_service.dart';
import 'package:myschedule/screens/notes_screen.dart';

Widget buildTestApp(Widget child, {
  ScheduleProvider? scheduleProvider,
  PurchaseService? purchaseService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => scheduleProvider ?? ScheduleProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => purchaseService ?? PurchaseService()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotesScreen Widget Tests', () {
    testWidgets('shows Notes title', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows free tier badge for free user', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.textContaining('free'), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.text('Search notes...'), findsOneWidget);
    });

    testWidgets('shows FAB add button', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('tapping FAB opens new note sheet', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('shows existing note in list', (tester) async {
      final provider = ScheduleProvider();
      final now = DateTime.now();
      provider.addNote(Note(
        id: 'note-1',
        title: 'Shopping List',
        body: 'Milk, eggs, bread',
        createdAt: now,
        updatedAt: now,
      ));
      await tester.pumpWidget(buildTestApp(const NotesScreen(), scheduleProvider: provider));
      await tester.pump();
      expect(find.text('Shopping List'), findsOneWidget);
    });

    testWidgets('can add a new note via bottom sheet', (tester) async {
      final provider = ScheduleProvider();
      await tester.pumpWidget(buildTestApp(const NotesScreen(), scheduleProvider: provider));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'My New Note');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'My New Note');
    });

    testWidgets('free user sees paywall after 1 note', (tester) async {
      final provider = ScheduleProvider();
      final purchase = PurchaseService();
      final now = DateTime.now();
      provider.addNote(Note(
        id: 'note-1',
        title: 'Existing Note',
        body: 'body',
        createdAt: now,
        updatedAt: now,
      ));
      await tester.pumpWidget(buildTestApp(
        const NotesScreen(),
        scheduleProvider: provider,
        purchaseService: purchase,
      ));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('tapping existing note opens edit sheet', (tester) async {
      final provider = ScheduleProvider();
      final now = DateTime.now();
      provider.addNote(Note(
        id: 'note-1',
        title: 'My Note',
        body: 'Content here',
        createdAt: now,
        updatedAt: now,
      ));
      await tester.pumpWidget(buildTestApp(const NotesScreen(), scheduleProvider: provider));
      await tester.pump();
      await tester.tap(find.text('My Note'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Note'), findsOneWidget);
    });

    testWidgets('search filters notes correctly', (tester) async {
      final provider = ScheduleProvider();
      final now = DateTime.now();
      provider.addNote(Note(id: '1', title: 'Shopping List', body: '', createdAt: now, updatedAt: now));
      provider.addNote(Note(id: '2', title: 'Work Tasks', body: '', createdAt: now, updatedAt: now));
      await tester.pumpWidget(buildTestApp(const NotesScreen(), scheduleProvider: provider));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Shopping');
      await tester.pump();
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Work Tasks'), findsNothing);
    });
  });
}
