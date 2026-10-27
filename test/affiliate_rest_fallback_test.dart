import 'package:flutter_test/flutter_test.dart';
import 'package:beenzo/features/affiliate/data/datasources/affiliate_rest_datasource.dart';
import 'package:beenzo/features/affiliate/data/models/affiliate_models.dart';
import 'package:beenzo/features/affiliate/data/repository/affiliate_repository.dart';

class MockFailingRestDataSource extends AffiliateRestDataSource {
  @override
  Future<AffiliateDashboardData> getDashboard() async {
    return AffiliateDashboardData.fromJson({
      'affiliate_id': 99,
      'status': 'active',
      'referral_code': 'BNZ_REST_FALLBACK',
      'wallet': {
        'available_balance': 999.0,
        'available_formatted': '₹999.00',
        'pending_balance': 100.0,
        'locked_balance': 0.0,
        'lifetime_earned': 1099.0,
        'total_withdrawn': 0.0,
      },
      'stats': {
        'total_clicks': 50,
        'total_orders': 5,
        'conversion_rate': 10.0,
      },
      'payout_profile': {
        'method': 'upi',
        'upi_id': 'fallback@upi',
      },
      'config': {
        'min_withdrawal_amount': 500.0,
        'clearance_days': 7,
      },
    });
  }

  @override
  Future<ProductShareInfo?> getProductShareInfo(int productId) async {
    return ProductShareInfo.fromJson({
      'product_id': productId,
      'name': 'REST Fallback Product',
      'price': 499.0,
      'price_formatted': '₹499.00',
      'commission': {
        'is_excluded': false,
        'display_text': 'Earn ₹49.90 (10%)',
        'estimated_amount': 49.9,
      },
      'is_affiliate': true,
      'referral_code': 'BNZ_REST_FALLBACK',
    });
  }

  @override
  Future<bool> trackReferral(String referralCode) async {
    return true;
  }
}

void main() {
  group('AffiliateRepository REST Fallback Tests', () {
    test('Falls back to REST when GraphQL fails on getDashboard', () async {
      // Repository without valid client -> GraphQL fails, triggers REST fallback
      final mockRest = MockFailingRestDataSource();
      final repository = AffiliateRepository(restDataSource: mockRest);

      final result = await repository.getDashboard();

      expect(result.affiliateId, 99);
      expect(result.referralCode, 'BNZ_REST_FALLBACK');
      expect(result.wallet.availableBalance, 999.0);
      expect(result.stats.totalClicks, 50);
      expect(result.payoutProfile.upiId, 'fallback@upi');
    });

    test('Falls back to REST when GraphQL fails on getProductShareInfo', () async {
      final mockRest = MockFailingRestDataSource();
      final repository = AffiliateRepository(restDataSource: mockRest);

      final result = await repository.getProductShareInfo(123);

      expect(result, isNotNull);
      expect(result!.productId, 123);
      expect(result.name, 'REST Fallback Product');
      expect(result.commission.displayText, 'Earn ₹49.90 (10%)');
    });

    test('Falls back to REST on trackReferral', () async {
      final mockRest = MockFailingRestDataSource();
      final repository = AffiliateRepository(restDataSource: mockRest);

      final success = await repository.trackReferral('BNZ123');
      expect(success, isTrue);
    });
  });
}
