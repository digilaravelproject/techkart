import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beenzo/features/affiliate/data/models/affiliate_models.dart';
import 'package:beenzo/features/affiliate/data/repository/affiliate_repository.dart';
import 'package:beenzo/features/affiliate/presentation/widgets/product_share_earn_banner.dart';
import 'package:beenzo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:beenzo/features/affiliate/presentation/pages/affiliate_dashboard_page.dart';

class MockWidgetAffiliateRepository implements AffiliateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ProductShareInfo?> getProductShareInfo(int productId) async {
    return const ProductShareInfo(
      productId: 1,
      price: 1490.0,
      commission: ProductCommissionInfo(
        isExcluded: false,
        type: 'percentage',
        rate: 10.0,
        estimatedAmount: 149.0,
        displayText: 'Earn ₹149.00 (10%)',
      ),
      isAffiliate: true,
      referralCode: 'BNZTEST',
      shareUrl: 'https://example.com/p/1?ref=BNZTEST',
      shareMessage: 'Check out this product: https://example.com/p/1?ref=BNZTEST',
    );
  }

  @override
  Future<AffiliateDashboardData> getDashboard() async {
    return AffiliateDashboardData(
      affiliateId: 1,
      status: 'active',
      referralCode: 'BNZ8X9K2L',
      referralLink: 'https://example.com?ref=BNZ8X9K2L',
      wallet: const AffiliateWallet(
        availableBalance: 1250.0,
        availableFormatted: '₹1,250.00',
        pendingBalance: 350.0,
        pendingFormatted: '₹350.00',
        lockedBalance: 0.0,
        lockedFormatted: '₹0.00',
        lifetimeEarned: 1600.0,
        lifetimeFormatted: '₹1,600.00',
        totalWithdrawn: 0.0,
        currency: 'INR',
        currencySymbol: '₹',
      ),
      stats: const AffiliateStats(
        totalClicks: 84,
        totalOrders: 6,
        conversionRate: 7.1,
      ),
      payoutProfile: const AffiliatePayoutProfile(
        method: 'upi',
        upiId: 'rahul@okhdfcbank',
      ),
      config: const AffiliateConfig(
        minWithdrawalAmount: 500.0,
        clearanceDays: 7,
        defaultCommissionType: 'percentage',
        defaultCommissionValue: 10.0,
      ),
    );
  }

  @override
  Future<AffiliateTransactionsResponse> getTransactions({
    int page = 1,
    int limit = 15,
  }) async {
    return const AffiliateTransactionsResponse(
      data: [],
      meta: PaginationMeta.empty(),
    );
  }

  @override
  Future<AffiliateCommissionsResponse> getCommissions({
    int page = 1,
    int limit = 15,
  }) async {
    return const AffiliateCommissionsResponse(
      data: [],
      meta: PaginationMeta.empty(),
    );
  }

  @override
  Future<AffiliatePayoutsResponse> getPayouts({
    int page = 1,
    int limit = 15,
  }) async {
    return const AffiliatePayoutsResponse(
      data: [],
      meta: PaginationMeta.empty(),
    );
  }
}

class FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  FakeAuthBloc()
      : super(const AuthAuthenticated(
          token: 'fake_token',
          userName: 'Rahul',
          userEmail: 'rahul@example.com',
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('ProductShareEarnBanner renders commission text and Share button', (tester) async {
    final repo = MockWidgetAffiliateRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepositoryProvider<AffiliateRepository>.value(
            value: repo,
            child: const ProductShareEarnBanner(productId: 1),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Earn ₹149.00 (10%)'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
  });

  testWidgets('AffiliateDashboardPage displays wallet balance and referral code for active affiliate', (tester) async {
    final repo = MockWidgetAffiliateRepository();
    final authBloc = FakeAuthBloc();

    await tester.pumpWidget(
      RepositoryProvider<AffiliateRepository>.value(
        value: repo,
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) {
                return ElevatedButton(
                  onPressed: () => AffiliateDashboardPage.navigate(ctx),
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Refer & Earn'), findsOneWidget);
    expect(find.text('Available to Withdraw'), findsOneWidget);
    expect(find.text('₹1,250.00'), findsOneWidget);
    expect(find.text('BNZ8X9K2L'), findsOneWidget);
    expect(find.text('Withdraw Funds'), findsOneWidget);
    expect(find.text('Total Clicks'), findsOneWidget);
  });
}
