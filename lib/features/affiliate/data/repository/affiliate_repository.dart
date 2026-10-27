import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/affiliate_queries.dart';
import '../../../../core/graphql/graphql_client.dart';
import '../../../auth/domain/services/auth_storage.dart';
import '../datasources/affiliate_rest_datasource.dart';
import '../models/affiliate_models.dart';

class AffiliateException implements Exception {
  final String message;
  AffiliateException(this.message);

  @override
  String toString() => message;
}

/// Repository responsible for all Affiliate, Referral and Wallet operations.
/// Primary: Bagisto GraphQL API
/// Fallback: Bagisto REST API (/api/v1/affiliate)
class AffiliateRepository {
  final GraphQLClient? client;
  final AffiliateRestDataSource restDataSource;

  AffiliateRepository({
    this.client,
    AffiliateRestDataSource? restDataSource,
  }) : restDataSource = restDataSource ?? AffiliateRestDataSource();

  /// Obtain an authenticated or guest GraphQL client
  Future<GraphQLClient> _getClient() async {
    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      return GraphQLClientProvider.buildClient(token: token);
    }
    return client ?? GraphQLClientProvider.buildClient();
  }

  // ─── 1. Affiliate Dashboard ───────────────────────────────────────────────

  Future<AffiliateDashboardData> getDashboard() async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.query(
        QueryOptions(
          document: gql(AffiliateQueries.getAffiliateDashboard),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['affiliateDashboard'];
      if (data == null) {
        throw AffiliateException('Empty response received from GraphQL');
      }

      return AffiliateDashboardData.fromJson(data as Map<String, dynamic>);
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL getDashboard failed: $gqlErr. Falling back to REST API...');
      try {
        final result = await restDataSource.getDashboard();
        debugPrint('✅ [AffiliateRepo] REST getDashboard fallback successful!');
        return result;
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST fallback getDashboard also failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to load affiliate dashboard: $gqlErr');
      }
    }
  }

  // ─── 2. Product Share & Commission Info ───────────────────────────────────

  Future<ProductShareInfo?> getProductShareInfo(int productId) async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.query(
        QueryOptions(
          document: gql(AffiliateQueries.getProductShareInfo),
          variables: {'productId': productId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['productShareInfo'];
      if (data == null) {
        throw AffiliateException('Empty productShareInfo from GraphQL');
      }

      return ProductShareInfo.fromJson(data as Map<String, dynamic>);
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL getProductShareInfo failed: $gqlErr. Falling back to REST API...');
      try {
        return await restDataSource.getProductShareInfo(productId);
      } catch (restErr) {
        debugPrint('⚠️ [AffiliateRepo] REST getProductShareInfo fallback also failed: $restErr');
        return null;
      }
    }
  }

  // ─── 3. Register Affiliate (1-Click Activate) ─────────────────────────────

  Future<AffiliateRegistrationResult> registerAffiliate() async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.mutate(
        MutationOptions(
          document: gql(AffiliateQueries.registerAffiliate),
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['registerAffiliate'];
      if (data == null) {
        throw AffiliateException('Empty response received from registration');
      }

      return AffiliateRegistrationResult.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL registerAffiliate failed: $gqlErr. Falling back to REST API...');
      try {
        final result = await restDataSource.registerAffiliate();
        debugPrint('✅ [AffiliateRepo] REST registerAffiliate fallback successful!');
        return result;
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST fallback registerAffiliate failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to activate affiliate: $gqlErr');
      }
    }
  }

  // ─── 4. Update Payout Settings ────────────────────────────────────────────

  Future<PayoutSettingsResult> updatePayoutSettings({
    required String payoutMethod,
    String? upiId,
    String? accountNumber,
    String? ifscCode,
    String? accountHolder,
    String? bankName,
  }) async {
    try {
      final activeClient = await _getClient();
      final variables = <String, dynamic>{
        'payoutMethod': payoutMethod,
        if (upiId != null) 'upiId': upiId,
        if (accountNumber != null) 'accountNumber': accountNumber,
        if (ifscCode != null) 'ifscCode': ifscCode,
        if (accountHolder != null) 'accountHolder': accountHolder,
        if (bankName != null) 'bankName': bankName,
      };

      final result = await activeClient.mutate(
        MutationOptions(
          document: gql(AffiliateQueries.updateAffiliatePayoutSettings),
          variables: variables,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['updateAffiliatePayoutSettings'];
      if (data == null) {
        throw AffiliateException('Empty response received from server');
      }

      return PayoutSettingsResult.fromJson(data as Map<String, dynamic>);
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL updatePayoutSettings failed: $gqlErr. Falling back to REST API...');
      try {
        final result = await restDataSource.updatePayoutSettings(
          payoutMethod: payoutMethod,
          upiId: upiId,
          accountNumber: accountNumber,
          ifscCode: ifscCode,
          accountHolder: accountHolder,
          bankName: bankName,
        );
        debugPrint('✅ [AffiliateRepo] REST updatePayoutSettings fallback successful!');
        return result;
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST updatePayoutSettings failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to update payout settings: $gqlErr');
      }
    }
  }

  // ─── 5. Request Payout / Withdrawal ───────────────────────────────────────

  Future<PayoutRequestResult> requestPayout({
    required double amount,
    String? payoutMethod,
    String? upiId,
  }) async {
    try {
      final activeClient = await _getClient();
      final variables = <String, dynamic>{
        'amount': amount,
        'payoutMethod': ?payoutMethod,
        'upiId': ?upiId,
      };

      final result = await activeClient.mutate(
        MutationOptions(
          document: gql(AffiliateQueries.requestAffiliatePayout),
          variables: variables,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['requestAffiliatePayout'];
      if (data == null) {
        throw AffiliateException('Empty response received from server');
      }

      return PayoutRequestResult.fromJson(data as Map<String, dynamic>);
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL requestPayout failed: $gqlErr. Falling back to REST API...');
      try {
        final result = await restDataSource.requestPayout(
          amount: amount,
          payoutMethod: payoutMethod,
          upiId: upiId,
        );
        debugPrint('✅ [AffiliateRepo] REST requestPayout fallback successful!');
        return result;
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST requestPayout failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to request withdrawal: $gqlErr');
      }
    }
  }

  // ─── 6. Transactions Passbook ─────────────────────────────────────────────

  Future<AffiliateTransactionsResponse> getTransactions({
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.query(
        QueryOptions(
          document: gql(AffiliateQueries.getAffiliateTransactions),
          variables: {'page': page, 'limit': limit},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['affiliateTransactions'];
      if (data == null) {
        throw AffiliateException('Empty transactions response from GraphQL');
      }

      return AffiliateTransactionsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL getTransactions failed: $gqlErr. Falling back to REST API...');
      try {
        return await restDataSource.getTransactions(page: page, limit: limit);
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST getTransactions failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to load transactions: $gqlErr');
      }
    }
  }

  // ─── 7. Referral Commissions History ──────────────────────────────────────

  Future<AffiliateCommissionsResponse> getCommissions({
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.query(
        QueryOptions(
          document: gql(AffiliateQueries.getAffiliateCommissions),
          variables: {'page': page, 'limit': limit},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['affiliateCommissions'];
      if (data == null) {
        throw AffiliateException('Empty commissions response from GraphQL');
      }

      return AffiliateCommissionsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL getCommissions failed: $gqlErr. Falling back to REST API...');
      try {
        return await restDataSource.getCommissions(page: page, limit: limit);
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST getCommissions failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to load commissions: $gqlErr');
      }
    }
  }

  // ─── 8. Payout Requests History ───────────────────────────────────────────

  Future<AffiliatePayoutsResponse> getPayouts({
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.query(
        QueryOptions(
          document: gql(AffiliateQueries.getAffiliatePayouts),
          variables: {'page': page, 'limit': limit},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        throw AffiliateException(err);
      }

      final data = result.data?['affiliatePayouts'];
      if (data == null) {
        throw AffiliateException('Empty payouts response from GraphQL');
      }

      return AffiliatePayoutsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (gqlErr) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL getPayouts failed: $gqlErr. Falling back to REST API...');
      try {
        return await restDataSource.getPayouts(page: page, limit: limit);
      } catch (restErr) {
        debugPrint('❌ [AffiliateRepo] REST getPayouts failed: $restErr');
        if (restErr is AffiliateException) rethrow;
        throw AffiliateException('Failed to load payouts: $gqlErr');
      }
    }
  }

  // ─── 9. Track Referral Click ──────────────────────────────────────────────

  Future<bool> trackReferral(String referralCode) async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.mutate(
        MutationOptions(
          document: gql(AffiliateQueries.trackAffiliateReferral),
          variables: {'referralCode': referralCode},
        ),
      );

      if (result.hasException) {
        throw AffiliateException('GraphQL track referral error');
      }
      return result.data?['trackAffiliateReferral']?['success'] == true;
    } catch (_) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL trackReferral failed. Falling back to REST API...');
      return await restDataSource.trackReferral(referralCode);
    }
  }

  // ─── 10. Generate Custom Affiliate Link ───────────────────────────────────

  Future<Map<String, dynamic>?> generateLink({
    String? url,
    int? productId,
  }) async {
    try {
      final activeClient = await _getClient();
      final result = await activeClient.mutate(
        MutationOptions(
          document: gql(AffiliateQueries.generateAffiliateLink),
          variables: {
            'url': ?url,
            'productId': ?productId,
          },
        ),
      );

      if (result.hasException) {
        throw AffiliateException('GraphQL generate link error');
      }
      return result.data?['generateAffiliateLink'] as Map<String, dynamic>?;
    } catch (_) {
      debugPrint('⚠️ [AffiliateRepo] GraphQL generateLink failed. Falling back to REST API...');
      return await restDataSource.generateLink(url: url, productId: productId);
    }
  }

  // ─── Error parser ─────────────────────────────────────────────────────────

  String _extractErrorMessage(OperationException exception) {
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    if (exception.linkException != null) {
      return 'Network error: please check your connection';
    }
    return 'An unexpected error occurred';
  }
}
