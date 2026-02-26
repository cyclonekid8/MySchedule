import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PurchaseService', () {
    late PurchaseService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = PurchaseService();
      await service.init();
    });

    test('starts as non-premium', () {
      expect(service.isPremium, false);
    });

    test('isLoading is false by default', () {
      expect(service.isLoading, false);
    });

    test('isSimulated is false by default', () {
      expect(service.isSimulated, false);
    });

    test('toggleSimulatePremium enables premium', () async {
      await service.toggleSimulatePremium();
      expect(service.isPremium, true);
      expect(service.isSimulated, true);
    });

    test('toggleSimulatePremium toggles back to false', () async {
      await service.toggleSimulatePremium();
      await service.toggleSimulatePremium();
      expect(service.isPremium, false);
      expect(service.isSimulated, false);
    });

    test('simulate state persists after reinit', () async {
      await service.toggleSimulatePremium();
      final service2 = PurchaseService();
      await service2.init();
      expect(service2.isPremium, true);
    });

    test('buyPremium does not throw', () async {
      expect(() async => await service.buyPremium(), returnsNormally);
    });

    test('restorePurchases does not throw', () async {
      expect(() async => await service.restorePurchases(), returnsNormally);
    });
  });
}
