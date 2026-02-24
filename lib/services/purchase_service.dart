import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kPremiumProductId = 'myschedule_premium_monthly';

class PurchaseService extends ChangeNotifier {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  bool _isPremium = false;
  bool _isSimulated = false;
  bool _isLoading = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool get isPremium => _isPremium || _isSimulated;
  bool get isSimulated => _isSimulated;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSimulated = prefs.getBool('simulate_premium') ?? false;
    _isPremium = prefs.getBool('is_premium') ?? false;

    final purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen(_onPurchaseUpdate, onError: (e) {});
    await InAppPurchase.instance.restorePurchases();
    notifyListeners();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == kPremiumProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _setPremium(true);
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        } else if (purchase.status == PurchaseStatus.error) {
          _isLoading = false;
          notifyListeners();
        }
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    _isPremium = value;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> buyPremium() async {
    _isLoading = true;
    notifyListeners();

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await InAppPurchase.instance
        .queryProductDetails({kPremiumProductId});

    if (response.productDetails.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> toggleSimulatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isSimulated = !_isSimulated;
    await prefs.setBool('simulate_premium', _isSimulated);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
