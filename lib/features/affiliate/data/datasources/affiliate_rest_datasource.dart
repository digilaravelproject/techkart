import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../auth/domain/services/auth_storage.dart';
import '../models/affiliate_models.dart';
import '../repository/affiliate_repository.dart';

/// REST API DataSource for BEENZO Affiliate & Referral System.
/// Serves as a high-availability fallback when GraphQL is unavailable or fails.
class AffiliateRestDataSource {
  final http.Client _client;
  final String _baseUrl;

  AffiliateRestDataSource({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? affiliateRestBaseUrl;

  /// Helper to get request headers with Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Helper to handle JSON decoding & HTTP error extraction
  Map<String, dynamic> _parseResponse(http.Response response, String endpoint) {
    debugPrint('🌐 [Affiliate REST] ${response.statusCode} from $endpoint');
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw AffiliateException('Invalid response from server ($endpoint: ${response.statusCode})');
    }

    if (decoded is! Map<String, dynamic>) {
      throw AffiliateException('Unexpected response format from server');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // Extract API error message
    final msg = decoded['message']?.toString() ??
        decoded['error']?.toString() ??
        'HTTP ${response.statusCode} from $endpoint';
    throw AffiliateException(msg);
  }

  // ─── 1. Dashboard ──────────────────────────────────────────────────────────

  Future<AffiliateDashboardData> getDashboard() async {
    final uri = Uri.parse('$_baseUrl/dashboard');
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    final data = _parseResponse(response, '/dashboard');
    return AffiliateDashboardData.fromJson(data);
  }

  // ─── 2. Product Share Info ────────────────────────────────────────────────

  Future<ProductShareInfo?> getProductShareInfo(int productId) async {
    final uri = Uri.parse('$_baseUrl/product-share-info/$productId');
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    final data = _parseResponse(response, '/product-share-info/$productId');
    return ProductShareInfo.fromJson(data);
  }

  // ─── 3. Register Affiliate (1-Click Auto Activation) ───────────────────────

  Future<AffiliateRegistrationResult> registerAffiliate() async {
    final uri = Uri.parse('$_baseUrl/register');
    final headers = await _getHeaders();
    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode({}),
    );
    final data = _parseResponse(response, '/register');
    return AffiliateRegistrationResult.fromJson(data);
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
    final uri = Uri.parse('$_baseUrl/payout-settings');
    final headers = await _getHeaders();
    final body = <String, dynamic>{
      'payout_method': payoutMethod,
      'payoutMethod': payoutMethod,
      if (upiId != null) ...{
        'upi_id': upiId,
        'upiId': upiId,
      },
      if (accountNumber != null) ...{
        'account_number': accountNumber,
        'accountNumber': accountNumber,
      },
      if (ifscCode != null) ...{
        'ifsc_code': ifscCode,
        'ifscCode': ifscCode,
      },
      if (accountHolder != null) ...{
        'account_holder': accountHolder,
        'accountHolder': accountHolder,
      },
      if (bankName != null) ...{
        'bank_name': bankName,
        'bankName': bankName,
      },
    };

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    final data = _parseResponse(response, '/payout-settings');
    return PayoutSettingsResult.fromJson(data);
  }

  // ─── 5. Request Payout / Withdrawal ───────────────────────────────────────

  Future<PayoutRequestResult> requestPayout({
    required double amount,
    String? payoutMethod,
    String? upiId,
  }) async {
    final uri = Uri.parse('$_baseUrl/payout-request');
    final headers = await _getHeaders();
    final body = <String, dynamic>{
      'amount': amount,
      if (payoutMethod != null) ...{
        'payout_method': payoutMethod,
        'payoutMethod': payoutMethod,
      },
      if (upiId != null) ...{
        'upi_id': upiId,
        'upiId': upiId,
      },
    };

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    final data = _parseResponse(response, '/payout-request');
    return PayoutRequestResult.fromJson(data);
  }

  // ─── 6. Transactions Passbook ─────────────────────────────────────────────

  Future<AffiliateTransactionsResponse> getTransactions({
    int page = 1,
    int limit = 15,
  }) async {
    final uri = Uri.parse('$_baseUrl/wallet/transactions?page=$page&limit=$limit');
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    final data = _parseResponse(response, '/wallet/transactions');
    return AffiliateTransactionsResponse.fromJson(data);
  }

  // ─── 7. Referral Commissions ──────────────────────────────────────────────

  Future<AffiliateCommissionsResponse> getCommissions({
    int page = 1,
    int limit = 15,
  }) async {
    final uri = Uri.parse('$_baseUrl/commissions?page=$page&limit=$limit');
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    final data = _parseResponse(response, '/commissions');
    return AffiliateCommissionsResponse.fromJson(data);
  }

  // ─── 8. Payout History ────────────────────────────────────────────────────

  Future<AffiliatePayoutsResponse> getPayouts({
    int page = 1,
    int limit = 15,
  }) async {
    final uri = Uri.parse('$_baseUrl/payouts?page=$page&limit=$limit');
    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);
    final data = _parseResponse(response, '/payouts');
    return AffiliatePayoutsResponse.fromJson(data);
  }

  // ─── 9. Track Referral Click ──────────────────────────────────────────────

  Future<bool> trackReferral(String referralCode) async {
    try {
      final uri = Uri.parse('$_baseUrl/track-referral');
      final headers = await _getHeaders();
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'referral_code': referralCode,
          'referralCode': referralCode,
        }),
      );
      final data = _parseResponse(response, '/track-referral');
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─── 10. Generate Custom Link ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> generateLink({
    String? url,
    int? productId,
  }) async {
    final uri = Uri.parse('$_baseUrl/generate-link');
    final headers = await _getHeaders();
    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode({
        if (url != null) 'url': url,
        if (productId != null) ...{
          'product_id': productId,
          'productId': productId,
        },
      }),
    );
    final data = _parseResponse(response, '/generate-link');
    return (data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data;
  }
}
