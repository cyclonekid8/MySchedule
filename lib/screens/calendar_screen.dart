import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../models/activity.dart';
import 'add_activity_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final selected = provider.selectedDay;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(child: Column(children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('Calendar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: selected,
          selectedDayPredicate: (day) => isSameDay(day, selected),
          onDaySelected: (sel, _) => provider.selectDay(sel),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: const TextStyle(color: Color(0xFFFF6B6B)),
            selectedDecoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.3), shape: BoxShape.circle),
            todayTextStyle: const TextStyle(color: Colors.white),
            outsideTextStyle: const TextStyle(color: Color(0xFF444455)),
            markerDecoration: const BoxDecoration(color: Color(0xFF43E97B), shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false, titleCentered: true,
            titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.w600),
            weekendStyle: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w600),
          ),
          eventLoader: (day) => provider.activities.where((a) =>
            a.startTime.year == day.year && a.startTime.month == day.month && a.startTime.day == day.day).toList(),
        ),
        const Divider(color: Color(0xFF3A3A4A)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(DateFormat('EEE, MMM dd').format(selected),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            Text('${provider.activitiesForSelectedDay.length} activities',
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
          ]),
        ),
        Expanded(child: provider.activitiesForSelectedDay.isEmpty
          ? const Center(child: Text('No activities this day', style: TextStyle(color: Color(0xFFAAAAAA))))
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
                      color: a.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(left: BorderSide(color: a.category.color, width: 3)),
                    ),
                    child: Row(children: [
                      Text(a.category.emoji),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text('${DateFormat('HH:mm').format(a.startTime)} – ${DateFormat('HH:mm').format(a.endTime)}',
                          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11, fontFamily: 'monospace')),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: a.category.color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(a.category.label, style: TextStyle(fontSize: 10, color: a.category.color, fontWeight: FontWeight.w600)),
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
