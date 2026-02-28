import 'package:flutter/material.dart';

class AboutYourDataScreen extends StatelessWidget {
  const AboutYourDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
    final surface = isDark ? const Color(0xFF16161E) : const Color(0xFFF0F0F5);
    final borderColor = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('About Your Data',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Your Privacy Matters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Here\'s how MySchedule handles your data',
              style: TextStyle(fontSize: 13, color: subColor)),
          ),
          const SizedBox(height: 28),

          _DataSection(
            icon: Icons.phone_android,
            title: 'Stored Locally',
            description: 'All your activities, notes, and preferences are stored locally on your device using SharedPreferences. Nothing is sent to external servers.',
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 12),

          _DataSection(
            icon: Icons.cloud_off_outlined,
            title: 'No Cloud Sync',
            description: 'MySchedule does not upload or sync your data to any cloud service. Your schedule stays on your device.',
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 12),

          _DataSection(
            icon: Icons.analytics_outlined,
            title: 'No Analytics or Tracking',
            description: 'We do not collect usage analytics, crash reports, or any behavioral data. No third-party trackers are embedded in the app.',
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 12),

          _DataSection(
            icon: Icons.shopping_cart_outlined,
            title: 'In-App Purchases',
            description: 'Premium purchases are handled securely through the Google Play Store. MySchedule does not store or process any payment information.',
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 12),

          _DataSection(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            description: 'Reminders are scheduled locally on your device. No notification data is shared with any external service.',
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 12),

          _DataSection(
            icon: Icons.delete_outline,
            title: 'Deleting Your Data',
            description: 'You can clear all your data at any time from Settings > Clear all data. Uninstalling the app also removes all stored data from your device.',
            surface: surface,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 28),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF43E97B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF43E97B).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: Color(0xFF43E97B), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MySchedule is designed with privacy first. Your data belongs to you and stays on your device.',
                    style: TextStyle(fontSize: 12, color: textColor, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color surface;
  final Color borderColor;
  final Color textColor;
  final Color subColor;

  const _DataSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.surface,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(
                  color: subColor, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
