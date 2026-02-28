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
  String _customCategoryName = '';
  Color _customCategoryColor = const Color(0xFF6C63FF);
  String? _selectedCustomCategoryId;

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
      _customCategoryName = e.customCategoryName;
      _customCategoryColor = e.customCategoryColor;
    } else {
      // Use selected day from provider for the date portion
      final selected = context.read<ScheduleProvider>().selectedDay;
      _startTime = DateTime(selected.year, selected.month, selected.day, now.hour + 1, 0);
      _endTime = DateTime(selected.year, selected.month, selected.day, now.hour + 2, 0);
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

  void _showCreateCustomCategoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF18181F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final surface = isDark ? const Color(0xFF16161E) : const Color(0xFFF0F0F5);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);

    final nameController = TextEditingController();
    Color selectedColor = const Color(0xFF6C63FF);
    String selectedEmoji = '⭐';

    const colorOptions = [
      Color(0xFF6C63FF), Color(0xFFFF6B6B), Color(0xFF43E97B),
      Color(0xFFF7971E), Color(0xFF4FACFE), Color(0xFFF9CA24),
      Color(0xFF00CEC9), Color(0xFFA29BFE), Color(0xFFFD79A8),
      Color(0xFFE17055), Color(0xFF00B894), Color(0xFF0984E3),
    ];

    const emojiOptions = ['⭐', '🎯', '📚', '🎨', '🎵', '🏠', '✈️', '🍳', '💪', '🧘', '🙏', '💡', '🎮', '🛒', '👕', '🐠'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Custom Tag', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Name
              TextField(
                controller: nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Tag name (e.g. Reading)',
                  hintStyle: TextStyle(color: subColor),
                  filled: true, fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF))),
                ),
              ),
              const SizedBox(height: 16),

              // Emoji picker
              Text('ICON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subColor, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: emojiOptions.map((emoji) {
                  final sel = selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedEmoji = emoji),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF6C63FF).withOpacity(0.2) : surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? const Color(0xFF6C63FF) : borderColor),
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Color picker
              Text('COLOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subColor, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: colorOptions.map((color) {
                  final sel = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = color),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 3),
                        boxShadow: sel ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : null,
                      ),
                      child: sel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Preview + Save
              Row(
                children: [
                  // Preview
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selectedColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        '$selectedEmoji ${nameController.text.isEmpty ? 'Preview' : nameController.text}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selectedColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save button
                  GestureDetector(
                    onTap: () {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a tag name')));
                        return;
                      }
                      final provider = context.read<ScheduleProvider>();
                      final newCat = CustomCategory(
                        id: provider.generateId(),
                        name: nameController.text.trim(),
                        color: selectedColor,
                        emoji: selectedEmoji,
                      );
                      provider.addCustomCategory(newCat);
                      setState(() {
                        _category = Category.custom;
                        _customCategoryName = newCat.name;
                        _customCategoryColor = newCat.color;
                        _selectedCustomCategoryId = newCat.id;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an activity name')));
      return;
    }
    if (!_endTime.isAfter(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')));
      return;
    }
    // Prevent adding new activities to past dates
    if (widget.existing == null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final activityDate = DateTime(_startTime.year, _startTime.month, _startTime.day);
      if (activityDate.isBefore(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot add activities to past dates')));
        return;
      }
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
        customCategoryName: _customCategoryName,
        customCategoryColor: _customCategoryColor,
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
        customCategoryName: _customCategoryName,
        customCategoryColor: _customCategoryColor,
        hasCompletionTracking: _hasCompletion,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _reminderMins,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final surface = isDark ? const Color(0xFF16161E) : const Color(0xFFF0F0F5);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);
    final customCategories = context.watch<ScheduleProvider>().customCategories;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.existing != null ? 'Edit Activity' : 'Add Activity',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
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
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'e.g. Morning Prayer…',
              hintStyle: TextStyle(color: subColor),
              filled: true, fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
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
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: Color(0xFF6C63FF), size: 18),
                const SizedBox(width: 10),
                Text(DateFormat('EEE, MMM dd yyyy').format(_startTime), style: TextStyle(color: textColor)),
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
            children: [
              // Built-in categories (exclude 'custom' from enum)
              ...Category.values.where((c) => c != Category.custom).map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() {
                    _category = cat;
                    _selectedCustomCategoryId = null;
                    _customCategoryName = '';
                    _customCategoryColor = const Color(0xFF6C63FF);
                  }),
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
              }),
              // User's custom categories
              ...customCategories.map((cc) {
                final selected = _category == Category.custom && _selectedCustomCategoryId == cc.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _category = Category.custom;
                    _selectedCustomCategoryId = cc.id;
                    _customCategoryName = cc.name;
                    _customCategoryColor = cc.color;
                  }),
                  onLongPress: () => _showDeleteCustomCategoryDialog(cc),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? cc.color : cc.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cc.color.withOpacity(0.4)),
                    ),
                    child: Text('${cc.emoji} ${cc.name}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : cc.color)),
                  ),
                );
              }),
              // Add custom tag button
              GestureDetector(
                onTap: _showCreateCustomCategoryDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: subColor),
                      const SizedBox(width: 4),
                      Text('New Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subColor)),
                    ],
                  ),
                ),
              ),
            ],
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
                  color: sel ? const Color(0xFF6C63FF).withOpacity(0.2) : surface,
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
                      color: sel ? const Color(0xFF6C63FF) : surface,
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

  void _showDeleteCustomCategoryDialog(CustomCategory cc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "${cc.name}"?', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        content: Text('This will remove the custom tag. Activities using it will keep their color but show as Custom.',
          style: TextStyle(color: subColor, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: subColor)),
          ),
          TextButton(
            onPressed: () {
              context.read<ScheduleProvider>().removeCustomCategory(cc.id);
              if (_selectedCustomCategoryId == cc.id) {
                setState(() {
                  _category = Category.work;
                  _selectedCustomCategoryId = null;
                  _customCategoryName = '';
                  _customCategoryColor = const Color(0xFF6C63FF);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF16161E) : const Color(0xFFF0F0F5);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10, color: subColor)),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor, fontFamily: 'monospace')),
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF16161E) : const Color(0xFFF0F0F5);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(subtitle, style: TextStyle(color: subColor, fontSize: 11)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6C63FF)),
      ]),
    );
  }
}
