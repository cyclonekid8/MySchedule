import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/schedule_provider.dart';
import '../services/purchase_service.dart';
import 'paywall_screen.dart';

class AddActivityScreen extends StatefulWidget {
  final Activity? existing;
  const AddActivityScreen({super.key, this.existing});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _titleController = TextEditingController();
  late DateTime _startTime;
  late DateTime _endTime;
  Category _category = Category.work;
  RepeatType _repeat = RepeatType.none;
  bool _hasCompletion = false;
  bool _hasReminder = false;
  int _reminderMins = 15;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.existing != null) {
      final e = widget.existing!;
      _titleController.text = e.title;
      _startTime = e.startTime;
      _endTime = e.endTime;
      _category = e.category;
      _repeat = e.repeat;
      _hasCompletion = e.hasCompletionTracking;
      _hasReminder = e.hasReminder;
      _reminderMins = e.reminderMinutesBefore;
    } else {
      _startTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
      _endTime = DateTime(now.year, now.month, now.day, now.hour + 2, 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, picked.hour, picked.minute);
        } else {
          _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, picked.hour, picked.minute);
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(picked.year, picked.month, picked.day, _startTime.hour, _startTime.minute);
        _endTime = DateTime(picked.year, picked.month, picked.day, _endTime.hour, _endTime.minute);
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an activity name')));
      return;
    }
    final provider = context.read<ScheduleProvider>();
    final purchase = context.read<PurchaseService>();

    // Free limit: 2 activities per day
    if (widget.existing == null && !purchase.isPremium) {
      final activitiesToday = provider.activities.where((a) =>
        a.startTime.year == _startTime.year &&
        a.startTime.month == _startTime.month &&
        a.startTime.day == _startTime.day).length;
      if (activitiesToday >= 2) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const PaywallScreen(
            reason: 'Free users can only add 2 activities per day. Upgrade to Premium for unlimited activities!')));
        return;
      }
    }

    if (widget.existing != null) {
      provider.updateActivity(widget.existing!.copyWith(
        title: _titleController.text.trim(),
        startTime: _startTime, endTime: _endTime,
        category: _category, repeat: _repeat,
        hasCompletionTracking: _hasCompletion,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _reminderMins,
      ));
    } else {
      provider.addActivity(Activity(
        id: provider.generateId(),
        title: _titleController.text.trim(),
        startTime: _startTime, endTime: _endTime,
        category: _category, repeat: _repeat,
        hasCompletionTracking: _hasCompletion,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _reminderMins,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F13),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.existing != null ? 'Edit Activity' : 'Add Activity',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Activity name
          _SectionLabel('Activity Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Morning Prayer…',
              hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
              filled: true, fillColor: const Color(0xFF18181F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3A3A4A))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3A3A4A))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF))),
            ),
          ),
          const SizedBox(height: 20),

          // Date
          _SectionLabel('Date'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF18181F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF3A3A4A))),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: Color(0xFF6C63FF), size: 18),
                const SizedBox(width: 10),
                Text(DateFormat('EEE, MMM dd yyyy').format(_startTime), style: const TextStyle(color: Colors.white)),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Time
          _SectionLabel('Time'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => _pickTime(true),
              child: _TimeBox(DateFormat('HH:mm').format(_startTime), 'Start'),
            )),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_forward, color: Color(0xFFAAAAAA), size: 16)),
            Expanded(child: GestureDetector(
              onTap: () => _pickTime(false),
              child: _TimeBox(DateFormat('HH:mm').format(_endTime), 'End'),
            )),
          ]),
          const SizedBox(height: 20),

          // Category
          _SectionLabel('Category'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: Category.values.map((cat) {
              final selected = _category == cat;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? cat.color : cat.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cat.color.withOpacity(0.4)),
                  ),
                  child: Text('${cat.emoji} ${cat.label}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : cat.color)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Repeat
          _SectionLabel('Repeat'),
          const SizedBox(height: 8),
          Row(children: RepeatType.values.map((r) {
            final sel = _repeat == r;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _repeat = r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF6C63FF).withOpacity(0.2) : const Color(0xFF18181F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? const Color(0xFF6C63FF) : const Color(0xFF3A3A4A)),
                ),
                child: Text(r.label, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: sel ? const Color(0xFF6C63FF) : const Color(0xFFAAAAAA))),
              ),
            ));
          }).toList()),
          const SizedBox(height: 20),

          // Completion tracking
          _ToggleRow(
            icon: Icons.check_circle_outline,
            label: 'Mark as Done checkbox',
            subtitle: 'Lets you tick this activity off later',
            value: _hasCompletion,
            onChanged: (v) => setState(() => _hasCompletion = v),
          ),
          const SizedBox(height: 12),

          // Reminder
          _ToggleRow(
            icon: Icons.notifications_outlined,
            label: 'Reminder notification',
            subtitle: 'Notify me before this activity',
            value: _hasReminder,
            onChanged: (v) => setState(() => _hasReminder = v),
          ),
          if (_hasReminder) ...[
            const SizedBox(height: 12),
            _SectionLabel('Remind me'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [5, 10, 15, 30, 60].map((mins) {
                final sel = _reminderMins == mins;
                return GestureDetector(
                  onTap: () => setState(() => _reminderMins = mins),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF6C63FF) : const Color(0xFF18181F),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? const Color(0xFF6C63FF) : const Color(0xFF3A3A4A)),
                    ),
                    child: Text('$mins min', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : const Color(0xFFAAAAAA))),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 32),

          // Save button
          GestureDetector(
            onTap: _save,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: const Center(child: Text('Save Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA), letterSpacing: 0.8));
}

class _TimeBox extends StatelessWidget {
  final String time;
  final String label;
  const _TimeBox(this.time, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF18181F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF3A3A4A))),
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
      const SizedBox(height: 4),
      Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'monospace')),
    ]),
  );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF18181F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF3A3A4A))),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(subtitle, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6C63FF)),
    ]),
  );
}
