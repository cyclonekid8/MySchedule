import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../services/purchase_service.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _weekStart = 'Monday';
  static const String _appVersion = '1.0.0';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Week starts on', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _OptionTile(label: 'Monday', selected: _weekStart == 'Monday', onTap: () { _saveWeekStart('Monday'); Navigator.pop(context); }),
              _OptionTile(label: 'Sunday', selected: _weekStart == 'Sunday', onTap: () { _saveWeekStart('Sunday'); Navigator.pop(context); }),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('MySchedule', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
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
            Text('Version $_appVersion', style: TextStyle(color: subColor)),
            const SizedBox(height: 8),
            Text('A personal weekly scheduling app with notes, reminders, and activity categories.',
              style: TextStyle(color: subColor, fontSize: 13, height: 1.5)),
            const SizedBox(height: 8),
            const Text('Built with Flutter', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear all data?', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        content: Text('This will delete all your activities and notes permanently. This cannot be undone.',
          style: TextStyle(color: subColor, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: subColor)),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final purchase = context.watch<PurchaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F13) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final surface = isDark ? const Color(0xFF18181F) : const Color(0xFFF5F5F5);
    final border = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 24),

            // Premium banner
            if (!purchase.isPremium)
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen(reason: 'Upgrade to unlock all features'))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Go Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Unlimited activities, notes & more', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ]),
                ),
              ),

            if (purchase.isPremium)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF43E97B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF43E97B).withOpacity(0.4)),
                ),
                child: const Row(children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF43E97B), size: 24),
                  SizedBox(width: 12),
                  Text('Premium Active', style: TextStyle(color: Color(0xFF43E97B), fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
              ),

            _SectionHeader('Appearance', subColor),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.dark_mode,
              label: themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
              subtitle: 'Toggle theme',
              surface: surface, border: border, textColor: textColor, subColor: subColor,
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggle(),
                activeColor: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              subtitle: 'Enable activity reminders',
              surface: surface, border: border, textColor: textColor, subColor: subColor,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _saveNotifications,
                activeColor: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showWeekStartDialog,
              child: _SettingsTile(
                icon: Icons.calendar_today,
                label: 'Week starts on',
                subtitle: _weekStart,
                surface: surface, border: border, textColor: textColor, subColor: subColor,
                trailing: Icon(Icons.chevron_right, color: subColor),
              ),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Data', subColor),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showClearDataDialog,
              child: _SettingsTile(
                icon: Icons.delete_outline,
                label: 'Clear all data',
                subtitle: 'Delete all activities and notes',
                surface: surface, border: border,
                textColor: const Color(0xFFFF6B6B),
                subColor: subColor,
                iconColor: const Color(0xFFFF6B6B),
                trailing: Icon(Icons.chevron_right, color: subColor),
              ),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Developer', subColor),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.science_outlined,
              label: 'Simulate Premium',
              subtitle: purchase.isSimulated ? 'Premium simulation ON' : 'Test premium features',
              surface: surface, border: border, textColor: textColor, subColor: subColor,
              trailing: Switch(
                value: purchase.isSimulated,
                onChanged: (_) => purchase.toggleSimulatePremium(),
                activeColor: const Color(0xFF6C63FF),
              ),
            ),

            const SizedBox(height: 24),
            _SectionHeader('About', subColor),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showAboutDialog,
              child: _SettingsTile(
                icon: Icons.info_outline,
                label: 'About MySchedule',
                subtitle: 'Version $_appVersion',
                surface: surface, border: border, textColor: textColor, subColor: subColor,
                trailing: Icon(Icons.chevron_right, color: subColor),
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
  final Color color;
  const _SectionHeader(this.title, this.color);
  @override
  Widget build(BuildContext context) => Text(title.toUpperCase(),
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.8));
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget trailing;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color subColor;
  final Color iconColor;

  const _SettingsTile({
    required this.icon, required this.label, required this.subtitle,
    required this.trailing, required this.surface, required this.border,
    required this.textColor, required this.subColor,
    this.iconColor = const Color(0xFF6C63FF),
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border),
    ),
    child: Row(children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
      ])),
      trailing,
    ]),
  );
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
        border: Border.all(color: selected ? const Color(0xFF6C63FF) : const Color(0xFF3A3A4A)),
      ),
      child: Row(children: [
        Text(label, style: TextStyle(
          color: selected ? const Color(0xFF6C63FF) : Colors.white,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
        const Spacer(),
        if (selected) const Icon(Icons.check, color: Color(0xFF6C63FF), size: 18),
      ]),
    ),
  );
}
