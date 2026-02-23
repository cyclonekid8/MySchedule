import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 24),
          _SettingsTile(icon: Icons.dark_mode, label: 'Dark Mode', subtitle: 'Always on', trailing: const Icon(Icons.toggle_on, color: Color(0xFF6C63FF), size: 32)),
          _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications', subtitle: 'Manage reminder alerts', trailing: const Icon(Icons.chevron_right, color: Color(0xFF8888AA))),
          _SettingsTile(icon: Icons.calendar_today, label: 'Week starts on', subtitle: 'Monday', trailing: const Icon(Icons.chevron_right, color: Color(0xFF8888AA))),
          _SettingsTile(icon: Icons.info_outline, label: 'About', subtitle: 'MySchedule v1.0.0', trailing: const Icon(Icons.chevron_right, color: Color(0xFF8888AA))),
        ]),
      )),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget trailing;
  const _SettingsTile({required this.icon, required this.label, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF18181F), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2E2E3D))),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        Text(subtitle, style: const TextStyle(color: Color(0xFF8888AA), fontSize: 12)),
      ])),
      trailing,
    ]),
  );
}
