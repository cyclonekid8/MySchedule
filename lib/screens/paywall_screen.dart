import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/purchase_service.dart';

class PaywallScreen extends StatelessWidget {
  final String reason;
  const PaywallScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final purchase = context.watch<PurchaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F13) : Colors.white;
    final surface = isDark ? const Color(0xFF18181F) : const Color(0xFFF5F5F5);
    final text = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtext = isDark ? const Color(0xFF8888AA) : const Color(0xFF666688);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Unlock Premium', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: text)),
            const SizedBox(height: 8),
            Text(reason, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: subtext, height: 1.5)),
            const SizedBox(height: 32),

            // Features list
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E3D).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _FeatureRow('Unlimited activities', text),
                  _FeatureRow('Unlimited notes', text),
                  _FeatureRow('All categories', text),
                  _FeatureRow('Custom categories', text),
                  _FeatureRow('Multiple reminders', text),
                ],
              ),
            ),
            const Spacer(),

            // Price
            Text('\$1.99 SGD / month', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: text)),
            const SizedBox(height: 4),
            Text('Cancel anytime', style: TextStyle(fontSize: 12, color: subtext)),
            const SizedBox(height: 16),

            // Subscribe button
            GestureDetector(
              onTap: purchase.isLoading ? null : () => purchase.buyPremium(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 6),
                  )],
                ),
                child: Center(child: purchase.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Subscribe Now',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              ),
            ),
            const SizedBox(height: 12),

            // Restore
            TextButton(
              onPressed: () => purchase.restorePurchases(),
              child: Text('Restore purchase',
                style: TextStyle(color: subtext, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final Color textColor;
  const _FeatureRow(this.text, this.textColor);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, color: Color(0xFF43E97B), size: 20),
      const SizedBox(width: 12),
      Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
    ]),
  );
}
