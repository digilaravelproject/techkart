import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/affiliate_queries.dart';
import '../../../../core/graphql/graphql_client.dart';
import '../../../auth/domain/services/auth_storage.dart';
import '../models/affiliate_models.dart';

class AffiliateException implements Exception {
  final String message;
  AffiliateException(this.message);

  @override
  String toString() => message;
}

/// Repository responsible for all Affiliate, Referral and Wallet operations.
class AffiliateRepository {
  final GraphQLClient? client;

  AffiliateRepository({this.client});

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
        debugPrint('❌ AffiliateRepo.getDashboard error: $err');
        throw AffiliateException(err);
      }

      final data = result.data?['affiliateDashboard'];
      if (data == null) {
        return AffiliateDashboardData.empty();
      }

      return AffiliateDashboardData.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to load affiliate dashboard: $e');
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
        debugPrint('⚠️ AffiliateRepo.getProductShareInfo warning: $err');
        return null;
      }

      final data = result.data?['productShareInfo'];
      if (data == null) return null;

      return ProductShareInfo.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ AffiliateRepo.getProductShareInfo exception: $e');
      return null;
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
        debugPrint('❌ AffiliateRepo.registerAffiliate error: $err');
        throw AffiliateException(err);
      }

      final data = result.data?['registerAffiliate'];
      if (data == null) {
        throw AffiliateException('Empty response received from registration');
      }

      return AffiliateRegistrationResult.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to activate affiliate: $e');
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
        'upiId': ?upiId,
        'accountNumber': ?accountNumber,
        'ifscCode': ?ifscCode,
        'accountHolder': ?accountHolder,
        'bankName': ?bankName,
      };

      final result = await activeClient.mutate(
        MutationOptions(
          document: gql(AffiliateQueries.updateAffiliatePayoutSettings),
          variables: variables,
        ),
      );

      if (result.hasException) {
        final err = _extractErrorMessage(result.exception!);
        debugPrint('❌ AffiliateRepo.updatePayoutSettings error: $err');
        throw AffiliateException(err);
      }

      final data = result.data?['updateAffiliatePayoutSettings'];
      if (data == null) {
        throw AffiliateException('Empty response received from server');
      }

      return PayoutSettingsResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to update payout settings: $e');
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
        debugPrint('❌ AffiliateRepo.requestPayout error: $err');
        throw AffiliateException(err);
      }

      final data = result.data?['requestAffiliatePayout'];
      if (data == null) {
        throw AffiliateException('Empty response received from server');
      }

      return PayoutRequestResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to request withdrawal: $e');
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
        return AffiliateTransactionsResponse(
          data: const [],
          meta: PaginationMeta.empty(),
        );
      }

      return AffiliateTransactionsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to load transactions: $e');
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
        return AffiliateCommissionsResponse(
          data: const [],
          meta: PaginationMeta.empty(),
        );
      }

      return AffiliateCommissionsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to load commissions: $e');
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
        return AffiliatePayoutsResponse(
          data: const [],
          meta: PaginationMeta.empty(),
        );
      }

      return AffiliatePayoutsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AffiliateException) rethrow;
      throw AffiliateException('Failed to load payouts: $e');
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

      if (result.hasException) return false;
      return result.data?['trackAffiliateReferral']?['success'] == true;
    } catch (_) {
      return false;
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
