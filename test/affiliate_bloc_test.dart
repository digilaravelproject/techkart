import 'package:flutter_test/flutter_test.dart';
import 'package:beenzo/features/affiliate/data/models/affiliate_models.dart';
import 'package:beenzo/features/affiliate/data/repository/affiliate_repository.dart';
import 'package:beenzo/features/affiliate/presentation/bloc/affiliate_bloc.dart';

class MockAffiliateRepository implements AffiliateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<AffiliateDashboardData> getDashboard() async {
    return AffiliateDashboardData(
      affiliateId: 1,
      status: 'active',
      referralCode: 'BNZTEST',
      referralLink: 'https://example.com?ref=BNZTEST',
      wallet: const AffiliateWallet(
        availableBalance: 1000.0,
        availableFormatted: '₹1,000.00',
        pendingBalance: 200.0,
        pendingFormatted: '₹200.00',
        lockedBalance: 0.0,
        lockedFormatted: '₹0.00',
        lifetimeEarned: 1200.0,
        lifetimeFormatted: '₹1,200.00',
        totalWithdrawn: 0.0,
        currency: 'INR',
        currencySymbol: '₹',
      ),
      stats: const AffiliateStats(
        totalClicks: 25,
        totalOrders: 3,
        conversionRate: 12.0,
      ),
      payoutProfile: const AffiliatePayoutProfile(
        method: 'upi',
        upiId: 'test@upi',
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
      data: [
        AffiliateTransaction(
          id: '1',
          type: 'credit',
          amount: 100.0,
          amountFormatted: '₹100.00',
          balanceAfter: 1000.0,
          balanceAfterFormatted: '₹1,000.00',
          status: 'completed',
        ),
      ],
      meta: PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 1,
      ),
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

  @override
  Future<PayoutRequestResult> requestPayout({
    required double amount,
    String? payoutMethod,
    String? upiId,
  }) async {
    return PayoutRequestResult(
      success: true,
      message: 'Payout requested successfully',
      amount: amount,
      amountFormatted: '₹$amount',
    );
  }
}

void main() {
  group('AffiliateBloc Tests', () {
    late MockAffiliateRepository repository;
    late AffiliateBloc bloc;

  setUp(() {
    repository = MockAffiliateRepository();
    bloc = AffiliateBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has AffiliateStatus.initial', () {
    expect(bloc.state.status, AffiliateStatus.initial);
    expect(bloc.state.dashboard, isNull);
  });

  test('LoadAffiliateDashboard loads dashboard and updates status to success', () async {
    bloc.add(const LoadAffiliateDashboard());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<AffiliateState>((s) => s.status == AffiliateStatus.loading),
        predicate<AffiliateState>((s) {
          return s.status == AffiliateStatus.success &&
              s.dashboard != null &&
              s.dashboard!.referralCode == 'BNZTEST' &&
              s.transactions.length == 1;
        }),
      ]),
    );
  });

  test('SwitchAffiliateTabEvent updates selectedTabIndex', () async {
    bloc.add(const SwitchAffiliateTabEvent(2));

    await expectLater(
      bloc.stream,
      emits(predicate<AffiliateState>((s) => s.selectedTabIndex == 2)),
    );
  });
  });
}
