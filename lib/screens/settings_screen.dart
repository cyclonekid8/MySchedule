import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _weekStart = 'Monday';
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _weekStart = prefs.getString('week_start') ?? 'Monday';
    });
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveWeekStart(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('week_start', value);
    setState(() => _weekStart = value);
  }

  void _showWeekStartDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Week starts on',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _OptionTile(
              label: 'Monday',
              selected: _weekStart == 'Monday',
              onTap: () { _saveWeekStart('Monday'); Navigator.pop(context); },
            ),
            _OptionTile(
              label: 'Sunday',
              selected: _weekStart == 'Sunday',
              onTap: () { _saveWeekStart('Sunday'); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF18181F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('MySchedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Version $_appVersion', style: TextStyle(color: Color(0xFF8888AA))),
            const SizedBox(height: 8),
            const Text('A personal weekly scheduling app with notes, reminders, and 9 activity categories.',
              style: TextStyle(color: Color(0xFF8888AA), fontSize: 13, height: 1.5)),
            const SizedBox(height: 8),
            const Text('Built with Flutter ❤️', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF6C63FF))),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF18181F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear all data?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('This will delete all your activities and notes permanently. This cannot be undone.',
          style: TextStyle(color: Color(0xFF8888AA), height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8888AA))),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('activities');
              await prefs.remove('notes');
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared'), backgroundColor: Color(0xFFFF6B6B)));
              }
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 24),

            // Section: Preferences
            _SectionHeader('Preferences'),
            const SizedBox(height: 10),

            // Dark mode toggle (always on)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18181F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E2E3D)),
              ),
              child: Row(children: [
                const Icon(Icons.dark_mode, color: Color(0xFF6C63FF), size: 20),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Dark Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  Text('Always enabled', style: TextStyle(color: Color(0xFF8888AA), fontSize: 12)),
                ])),
                Switch(
                  value: true,
                  onChanged: null, // always on
                  activeColor: const Color(0xFF6C63FF),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // Notifications toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18181F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E2E3D)),
              ),
              child: Row(children: [
                const Icon(Icons.notifications_outlined, color: Color(0xFF6C63FF), size: 20),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  Text('Enable activity reminders', style: TextStyle(color: Color(0xFF8888AA), fontSize: 12)),
                ])),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _saveNotifications,
                  activeColor: const Color(0xFF6C63FF),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // Week starts on
            GestureDetector(
              onTap: _showWeekStartDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E2E3D)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF6C63FF), size: 20),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Week starts on', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ])),
                  Text(_weekStart, style: const TextStyle(color: Color(0xFF8888AA), fontSize: 13)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Color(0xFF8888AA)),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // Section: Data
            _SectionHeader('Data'),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showClearDataDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E2E3D)),
                ),
                child: const Row(children: [
                  Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 20),
                  SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Clear all data', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w500)),
                    Text('Delete all activities and notes', style: TextStyle(color: Color(0xFF8888AA), fontSize: 12)),
                  ])),
                  Icon(Icons.chevron_right, color: Color(0xFF8888AA)),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // Section: About
            _SectionHeader('About'),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showAboutDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E2E3D)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 20),
                  SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('About MySchedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    Text('Version 1.0.0', style: TextStyle(color: Color(0xFF8888AA), fontSize: 12)),
                  ])),
                  Icon(Icons.chevron_right, color: Color(0xFF8888AA)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Text(title.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: Color(0xFF8888AA), letterSpacing: 0.8));
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF6C63FF).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? const Color(0xFF6C63FF) : const Color(0xFF2E2E3D)),
      ),
      child: Row(children: [
        Text(label, style: TextStyle(color: selected ? const Color(0xFF6C63FF) : Colors.white,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
        const Spacer(),
        if (selected) const Icon(Icons.check, color: Color(0xFF6C63FF), size: 18),
      ]),
    ),
  );
}
