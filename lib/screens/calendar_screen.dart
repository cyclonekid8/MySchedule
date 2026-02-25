import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/activity.dart';
import '../providers/schedule_provider.dart';
import 'add_activity_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  String _categoryEmoji(Category c) {
    const emojis = {
      Category.work: '💼', Category.personal: '🙋',
      Category.healthFitness: '🏃', Category.social: '👥',
      Category.errands: '🛒', Category.prayer: '🙏',
      Category.tankMaintenance: '🐠', Category.crSupport: '🤝',
      Category.laundry: '👕', Category.custom: '⭐',
    };
    return emojis[c] ?? '📌';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final dividerColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);
    final outsideColor = isDark ? const Color(0xFF444455) : const Color(0xFFCCCCCC);
    final provider = context.watch<ScheduleProvider>();
    final selected = provider.selectedDay;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('Calendar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor))),
        ),
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: selected,
          selectedDayPredicate: (day) => isSameDay(day, selected),
          onDaySelected: (sel, _) => provider.selectDay(sel),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(color: textColor),
            weekendTextStyle: const TextStyle(color: Color(0xFFFF6B6B)),
            selectedDecoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.3), shape: BoxShape.circle),
            todayTextStyle: TextStyle(color: textColor),
            outsideTextStyle: TextStyle(color: outsideColor),
            markerDecoration: const BoxDecoration(color: Color(0xFF43E97B), shape: BoxShape.circle),
            tableBorder: TableBorder.all(color: Colors.transparent),
            cellMargin: const EdgeInsets.all(4),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false, titleCentered: true,
            titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
            rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
            decoration: BoxDecoration(color: bg),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: subColor, fontWeight: FontWeight.w600),
            weekendStyle: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w600),
          ),
          eventLoader: (day) => provider.activities.where((a) =>
            a.startTime.year == day.year && a.startTime.month == day.month && a.startTime.day == day.day).toList(),
        ),
        Divider(color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(DateFormat('EEE, MMM dd').format(selected),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
            Text('${provider.activitiesForSelectedDay.length} activities',
              style: TextStyle(color: subColor, fontSize: 12)),
          ]),
        ),
        Expanded(child: provider.activitiesForSelectedDay.isEmpty
          ? Center(child: Text('No activities this day', style: TextStyle(color: subColor)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: provider.activitiesForSelectedDay.length,
              itemBuilder: (ctx, i) {
                final a = provider.activitiesForSelectedDay[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddActivityScreen(existing: a))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: a.displayColor.withOpacity(isDark ? 0.1 : 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(left: BorderSide(color: a.displayColor, width: 3)),
                    ),
                    child: Row(children: [
                      Text(_categoryEmoji(a.category)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        Text('${DateFormat('HH:mm').format(a.startTime)} – ${DateFormat('HH:mm').format(a.endTime)}',
                          style: TextStyle(color: subColor, fontSize: 11, fontFamily: 'monospace')),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: a.displayColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(a.displayCategory, style: TextStyle(fontSize: 10, color: a.displayColor, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                );
              },
            ),
        ),
      ])),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddActivityScreen())),
      ),
    );
  }
}
