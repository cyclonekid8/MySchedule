import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService extends ChangeNotifier {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  bool _isSimulated = false;

  bool get isPremium => _isSimulated;
  bool get isSimulated => _isSimulated;
  bool get isLoading => false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSimulated = prefs.getBool('simulate_premium') ?? false;
    notifyListeners();
  }

  Future<void> buyPremium() async {
    // Real billing will be added when app is published
    // For now show a message
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    notifyListeners();
  }

  Future<void> toggleSimulatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isSimulated = !_isSimulated;
    await prefs.setBool('simulate_premium', _isSimulated);
    notifyListeners();
  }
}
