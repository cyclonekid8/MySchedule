import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/schedule_provider.dart';
import 'add_activity_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _WeekStrip(),
            Expanded(child: _TimeGrid()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddActivityScreen())),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final selected = context.watch<ScheduleProvider>().selectedDay;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MySchedule', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5)),
              Text(DateFormat('EEE dd — MMM yyyy').format(selected).toUpperCase(),
                style: TextStyle(fontSize: 11, color: subColor, fontFamily: 'monospace')),
            ],
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF6C63FF),
            child: const Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? const Color(0xFF18181F) : const Color(0xFFF0F0F5);
    final unselectedText = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF888888);
    final provider = context.watch<ScheduleProvider>();
    final selected = provider.selectedDay;
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: days.map((day) {
          final isSelected = day.year == selected.year && day.month == selected.month && day.day == selected.day;
          final hasEvents = provider.activities.any((a) {
            return a.startTime.year == day.year && a.startTime.month == day.month && a.startTime.day == day.day;
          });
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.selectDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : unselectedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('E').format(day).substring(0, 2),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white70 : unselectedText)),
                    const SizedBox(height: 2),
                    Text('${day.day}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A1A2E)))),
                    const SizedBox(height: 3),
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasEvents
                          ? (isSelected ? Colors.white54 : const Color(0xFF43E97B))
                          : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimeGrid extends StatefulWidget {
  @override
  State<_TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends State<_TimeGrid> {
  final ScrollController _scrollController = ScrollController();
  static const double _hourHeight = 54.0; // 48 content + ~6 padding/divider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final selected = context.read<ScheduleProvider>().selectedDay;
    final isToday = now.year == selected.year &&
        now.month == selected.month &&
        now.day == selected.day;

    if (isToday && _scrollController.hasClients) {
      // Scroll to current hour, offset by 2 hours earlier for context
      final targetHour = (now.hour - 2).clamp(0, 23);
      final offset = targetHour * _hourHeight;
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        offset.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF888888);
    final dividerColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);
    final activities = context.watch<ScheduleProvider>().activitiesForSelectedDay;
    final hours = List.generate(24, (i) => i);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final slotActivities = activities.where((a) => a.startTime.hour == hour).toList();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(fontSize: 10, color: subColor, fontFamily: 'monospace')),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(height: 1, color: dividerColor),
                  if (slotActivities.isEmpty)
                    const SizedBox(height: 48)
                  else
                    ...slotActivities.map((a) => _ActivityCard(activity: a)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);
    final provider = context.read<ScheduleProvider>();
    final color = activity.category.color;
    final done = activity.isDone;

    return GestureDetector(
      onLongPress: () => _showOptions(context, activity),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: done ? 0.4 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (activity.hasCompletionTracking)
                  GestureDetector(
                    onTap: () => provider.toggleDone(activity.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20, height: 20,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: done ? const Color(0xFF43E97B) : Colors.transparent,
                        border: Border.all(color: done ? const Color(0xFF43E97B) : borderColor, width: 2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: titleColor,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: titleColor.withOpacity(0.5),
                        )),
                      const SizedBox(height: 2),
                      Text('${DateFormat('HH:mm').format(activity.startTime)} – ${DateFormat('HH:mm').format(activity.endTime)}',
                        style: TextStyle(fontSize: 10, color: subColor, fontFamily: 'monospace')),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(activity.category.emoji, style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(activity.category.label,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                              color: color, letterSpacing: 0.5)),
                          if (activity.repeat != RepeatType.none) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.repeat, size: 10, color: color),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, Activity activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF18181F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
              title: Text('Edit', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddActivityScreen(existing: activity)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
              title: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
              onTap: () {
                context.read<ScheduleProvider>().deleteActivity(activity.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
