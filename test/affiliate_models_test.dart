import 'package:flutter_test/flutter_test.dart';
import 'package:beenzo/features/affiliate/data/models/affiliate_models.dart';

void main() {
  group('Affiliate Models Serialization & Parsing Tests', () {
    test('AffiliateDashboardData parses valid JSON correctly', () {
      final json = {
        'affiliateId': 1,
        'status': 'active',
        'referralCode': 'BNZ8X9K2L',
        'referralLink': 'https://indigo-rhinoceros-151425.hostingersite.com?ref=BNZ8X9K2L',
        'wallet': {
          'availableBalance': 1250.0,
          'availableFormatted': '₹1,250.00',
          'pendingBalance': 350.0,
          'pendingFormatted': '₹350.00',
          'lockedBalance': 0.0,
          'lockedFormatted': '₹0.00',
          'lifetimeEarned': 1600.0,
          'lifetimeFormatted': '₹1,600.00',
          'totalWithdrawn': 0.0,
          'currency': 'INR',
          'currencySymbol': '₹',
        },
        'stats': {
          'totalClicks': 84,
          'totalOrders': 6,
          'conversionRate': 7.1,
        },
        'payoutProfile': {
          'method': 'upi',
          'upiId': 'rahul@okhdfcbank',
        },
        'config': {
          'minWithdrawalAmount': 500.0,
          'clearanceDays': 7,
          'defaultCommissionType': 'percentage',
          'defaultCommissionValue': 10.0,
        },
      };

      final data = AffiliateDashboardData.fromJson(json);

      expect(data.affiliateId, 1);
      expect(data.status, 'active');
      expect(data.isActive, isTrue);
      expect(data.referralCode, 'BNZ8X9K2L');
      expect(data.wallet.availableBalance, 1250.0);
      expect(data.wallet.availableFormatted, '₹1,250.00');
      expect(data.stats.totalClicks, 84);
      expect(data.stats.totalOrders, 6);
      expect(data.stats.conversionRate, 7.1);
      expect(data.payoutProfile.method, 'upi');
      expect(data.payoutProfile.upiId, 'rahul@okhdfcbank');
      expect(data.config.minWithdrawalAmount, 500.0);
      expect(data.config.clearanceDays, 7);
    });

    test('ProductShareInfo parses commission displayText and shareMessage', () {
      final json = {
        'productId': 1,
        'name': 'Testing Product by Digi Store',
        'price': 1490.0,
        'priceFormatted': '₹1,490.00',
        'commission': {
          'isExcluded': false,
          'type': 'percentage',
          'rate': 10.0,
          'estimatedAmount': 149.0,
          'displayText': 'Earn ₹149.00 (10%)',
        },
        'isAffiliate': true,
        'referralCode': 'BNZ8X9K2L',
        'shareUrl': 'https://example.com/item?ref=BNZ8X9K2L',
        'shareMessage': 'Check out this item: https://example.com/item?ref=BNZ8X9K2L',
      };

      final info = ProductShareInfo.fromJson(json);

      expect(info.productId, 1);
      expect(info.price, 1490.0);
      expect(info.isAffiliate, isTrue);
      expect(info.commission.isExcluded, isFalse);
      expect(info.commission.estimatedAmount, 149.0);
      expect(info.commission.displayText, 'Earn ₹149.00 (10%)');
      expect(info.shareMessage, contains('BNZ8X9K2L'));
    });

    test('AffiliateTransaction parses credit and debit correctly', () {
      final json = {
        'id': '101',
        'transactionNumber': 'TXN101',
        'type': 'credit',
        'amount': 150.0,
        'amountFormatted': '₹150.00',
        'balanceAfter': 1400.0,
        'balanceAfterFormatted': '₹1,400.00',
        'status': 'completed',
        'title': 'Commission from Order #501',
        'createdAt': '2026-10-24',
      };

      final tx = AffiliateTransaction.fromJson(json);

      expect(tx.id, '101');
      expect(tx.isCredit, isTrue);
      expect(tx.amount, 150.0);
      expect(tx.balanceAfter, 1400.0);
      expect(tx.status, 'completed');
    });

    test('AffiliatePayout parses payout requests properly', () {
      final json = {
        'id': '55',
        'payoutNumber': 'PAY55',
        'amount': 500.0,
        'amountFormatted': '₹500.00',
        'payoutMethod': 'upi',
        'status': 'approved',
        'transactionReference': 'UTR123456789',
        'createdAt': '2026-10-23',
      };

      final payout = AffiliatePayout.fromJson(json);

      expect(payout.id, '55');
      expect(payout.amount, 500.0);
      expect(payout.payoutMethod, 'upi');
      expect(payout.status, 'approved');
      expect(payout.transactionReference, 'UTR123456789');
    });
  });
}
