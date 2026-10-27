import 'package:equatable/equatable.dart';

/// Affiliate dashboard data model
class AffiliateDashboardData extends Equatable {
  final int? affiliateId;
  final String status;
  final String? referralCode;
  final String? referralLink;
  final AffiliateWallet wallet;
  final AffiliateStats stats;
  final AffiliatePayoutProfile payoutProfile;
  final AffiliateConfig config;

  const AffiliateDashboardData({
    this.affiliateId,
    required this.status,
    this.referralCode,
    this.referralLink,
    required this.wallet,
    required this.stats,
    required this.payoutProfile,
    required this.config,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory AffiliateDashboardData.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['affiliateDashboard'] is Map<String, dynamic>
            ? json['affiliateDashboard'] as Map<String, dynamic>
            : json);

    return AffiliateDashboardData(
      affiliateId: raw['affiliateId'] is int
          ? raw['affiliateId']
          : (raw['affiliate_id'] is int
              ? raw['affiliate_id']
              : int.tryParse(
                  (raw['affiliateId'] ?? raw['affiliate_id'])?.toString() ?? '',
                )),
      status: (raw['status'] ?? raw['affiliate_status'])?.toString() ?? 'inactive',
      referralCode: (raw['referralCode'] ?? raw['referral_code'])?.toString(),
      referralLink: (raw['referralLink'] ?? raw['referral_link'])?.toString(),
      wallet: raw['wallet'] is Map<String, dynamic>
          ? AffiliateWallet.fromJson(raw['wallet'] as Map<String, dynamic>)
          : AffiliateWallet.empty(),
      stats: raw['stats'] is Map<String, dynamic>
          ? AffiliateStats.fromJson(raw['stats'] as Map<String, dynamic>)
          : AffiliateStats.empty(),
      payoutProfile: (raw['payoutProfile'] ?? raw['payout_profile']) is Map<String, dynamic>
          ? AffiliatePayoutProfile.fromJson(
              (raw['payoutProfile'] ?? raw['payout_profile']) as Map<String, dynamic>,
            )
          : AffiliatePayoutProfile.empty(),
      config: raw['config'] is Map<String, dynamic>
          ? AffiliateConfig.fromJson(raw['config'] as Map<String, dynamic>)
          : AffiliateConfig.empty(),
    );
  }

  factory AffiliateDashboardData.empty() {
    return AffiliateDashboardData(
      affiliateId: null,
      status: 'inactive',
      referralCode: null,
      referralLink: null,
      wallet: AffiliateWallet.empty(),
      stats: AffiliateStats.empty(),
      payoutProfile: AffiliatePayoutProfile.empty(),
      config: AffiliateConfig.empty(),
    );
  }

  @override
  List<Object?> get props => [
    affiliateId,
    status,
    referralCode,
    referralLink,
    wallet,
    stats,
    payoutProfile,
    config,
  ];
}

/// Affiliate wallet model
class AffiliateWallet extends Equatable {
  final double availableBalance;
  final String availableFormatted;
  final double pendingBalance;
  final String pendingFormatted;
  final double lockedBalance;
  final String lockedFormatted;
  final double lifetimeEarned;
  final String lifetimeFormatted;
  final double totalWithdrawn;
  final String currency;
  final String currencySymbol;

  const AffiliateWallet({
    required this.availableBalance,
    required this.availableFormatted,
    required this.pendingBalance,
    required this.pendingFormatted,
    required this.lockedBalance,
    required this.lockedFormatted,
    required this.lifetimeEarned,
    required this.lifetimeFormatted,
    required this.totalWithdrawn,
    required this.currency,
    required this.currencySymbol,
  });

  factory AffiliateWallet.fromJson(Map<String, dynamic> json) {
    return AffiliateWallet(
      availableBalance: _toDouble(json['availableBalance'] ?? json['available_balance']),
      availableFormatted:
          (json['availableFormatted'] ?? json['available_formatted'])?.toString() ?? '₹0.00',
      pendingBalance: _toDouble(json['pendingBalance'] ?? json['pending_balance']),
      pendingFormatted:
          (json['pendingFormatted'] ?? json['pending_formatted'])?.toString() ?? '₹0.00',
      lockedBalance: _toDouble(json['lockedBalance'] ?? json['locked_balance']),
      lockedFormatted:
          (json['lockedFormatted'] ?? json['locked_formatted'])?.toString() ?? '₹0.00',
      lifetimeEarned: _toDouble(json['lifetimeEarned'] ?? json['lifetime_earned']),
      lifetimeFormatted:
          (json['lifetimeFormatted'] ?? json['lifetime_formatted'])?.toString() ?? '₹0.00',
      totalWithdrawn: _toDouble(json['totalWithdrawn'] ?? json['total_withdrawn']),
      currency: json['currency']?.toString() ?? 'INR',
      currencySymbol: (json['currencySymbol'] ?? json['currency_symbol'])?.toString() ?? '₹',
    );
  }

  factory AffiliateWallet.empty() {
    return const AffiliateWallet(
      availableBalance: 0.0,
      availableFormatted: '₹0.00',
      pendingBalance: 0.0,
      pendingFormatted: '₹0.00',
      lockedBalance: 0.0,
      lockedFormatted: '₹0.00',
      lifetimeEarned: 0.0,
      lifetimeFormatted: '₹0.00',
      totalWithdrawn: 0.0,
      currency: 'INR',
      currencySymbol: '₹',
    );
  }

  @override
  List<Object?> get props => [
    availableBalance,
    availableFormatted,
    pendingBalance,
    pendingFormatted,
    lockedBalance,
    lockedFormatted,
    lifetimeEarned,
    lifetimeFormatted,
    totalWithdrawn,
    currency,
    currencySymbol,
  ];
}

/// Affiliate performance statistics
class AffiliateStats extends Equatable {
  final int totalClicks;
  final int totalOrders;
  final double conversionRate;

  const AffiliateStats({
    required this.totalClicks,
    required this.totalOrders,
    required this.conversionRate,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    return AffiliateStats(
      totalClicks: _toInt(json['totalClicks'] ?? json['total_clicks']),
      totalOrders: _toInt(json['totalOrders'] ?? json['total_orders']),
      conversionRate: _toDouble(json['conversionRate'] ?? json['conversion_rate']),
    );
  }

  factory AffiliateStats.empty() {
    return const AffiliateStats(
      totalClicks: 0,
      totalOrders: 0,
      conversionRate: 0.0,
    );
  }

  @override
  List<Object?> get props => [totalClicks, totalOrders, conversionRate];
}

/// Affiliate payout profile (saved UPI / Bank account details)
class AffiliatePayoutProfile extends Equatable {
  final String? method;
  final String? upiId;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolder;
  final String? bankName;

  const AffiliatePayoutProfile({
    this.method,
    this.upiId,
    this.accountNumber,
    this.ifscCode,
    this.accountHolder,
    this.bankName,
  });

  bool get isConfigured =>
      ((method == 'upi' || method == 'UPI') && upiId != null && upiId!.isNotEmpty) ||
      ((method == 'bank_transfer' || method == 'bank') &&
          accountNumber != null &&
          accountNumber!.isNotEmpty);

  factory AffiliatePayoutProfile.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? details;
    if (json['details'] is Map<String, dynamic>) {
      details = json['details'] as Map<String, dynamic>;
    }

    return AffiliatePayoutProfile(
      method: (json['method'] ?? json['payout_method'])?.toString(),
      upiId: (json['upiId'] ??
              json['upi_id'] ??
              details?['upiId'] ??
              details?['upi_id'])
          ?.toString(),
      accountNumber: (json['accountNumber'] ??
              json['account_number'] ??
              details?['accountNumber'] ??
              details?['account_number'])
          ?.toString(),
      ifscCode: (json['ifscCode'] ??
              json['ifsc_code'] ??
              details?['ifscCode'] ??
              details?['ifsc_code'])
          ?.toString(),
      accountHolder: (json['accountHolder'] ??
              json['account_holder'] ??
              details?['accountHolder'] ??
              details?['account_holder'])
          ?.toString(),
      bankName: (json['bankName'] ??
              json['bank_name'] ??
              details?['bankName'] ??
              details?['bank_name'])
          ?.toString(),
    );
  }

  factory AffiliatePayoutProfile.empty() {
    return const AffiliatePayoutProfile();
  }

  @override
  List<Object?> get props => [
    method,
    upiId,
    accountNumber,
    ifscCode,
    accountHolder,
    bankName,
  ];
}

/// Affiliate system configurations
class AffiliateConfig extends Equatable {
  final double minWithdrawalAmount;
  final int clearanceDays;
  final String defaultCommissionType;
  final double defaultCommissionValue;

  const AffiliateConfig({
    required this.minWithdrawalAmount,
    required this.clearanceDays,
    required this.defaultCommissionType,
    required this.defaultCommissionValue,
  });

  factory AffiliateConfig.fromJson(Map<String, dynamic> json) {
    return AffiliateConfig(
      minWithdrawalAmount: _toDouble(
        json['minWithdrawalAmount'] ?? json['min_withdrawal_amount'],
        fallback: 500.0,
      ),
      clearanceDays: _toInt(
        json['clearanceDays'] ?? json['clearance_days'],
        fallback: 7,
      ),
      defaultCommissionType:
          (json['defaultCommissionType'] ?? json['default_commission_type'])?.toString() ??
              'percentage',
      defaultCommissionValue: _toDouble(
        json['defaultCommissionValue'] ?? json['default_commission_value'],
        fallback: 10.0,
      ),
    );
  }

  factory AffiliateConfig.empty() {
    return const AffiliateConfig(
      minWithdrawalAmount: 500.0,
      clearanceDays: 7,
      defaultCommissionType: 'percentage',
      defaultCommissionValue: 10.0,
    );
  }

  @override
  List<Object?> get props => [
    minWithdrawalAmount,
    clearanceDays,
    defaultCommissionType,
    defaultCommissionValue,
  ];
}

/// Product share & commission info (for Product Detail Screen)
class ProductShareInfo extends Equatable {
  final int productId;
  final String? name;
  final String? urlKey;
  final double price;
  final String? priceFormatted;
  final ProductCommissionInfo commission;
  final bool isAffiliate;
  final String? referralCode;
  final String? shareUrl;
  final String? shareMessage;

  const ProductShareInfo({
    required this.productId,
    this.name,
    this.urlKey,
    required this.price,
    this.priceFormatted,
    required this.commission,
    required this.isAffiliate,
    this.referralCode,
    this.shareUrl,
    this.shareMessage,
  });

  factory ProductShareInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['productShareInfo'] is Map<String, dynamic>
            ? json['productShareInfo'] as Map<String, dynamic>
            : json);

    return ProductShareInfo(
      productId: _toInt(raw['productId'] ?? raw['product_id']),
      name: raw['name']?.toString(),
      urlKey: (raw['urlKey'] ?? raw['url_key'])?.toString(),
      price: _toDouble(raw['price']),
      priceFormatted: (raw['priceFormatted'] ?? raw['price_formatted'])?.toString(),
      commission: raw['commission'] is Map<String, dynamic>
          ? ProductCommissionInfo.fromJson(
              raw['commission'] as Map<String, dynamic>,
            )
          : ProductCommissionInfo.empty(),
      isAffiliate: (raw['isAffiliate'] ?? raw['is_affiliate']) == true,
      referralCode: (raw['referralCode'] ?? raw['referral_code'])?.toString(),
      shareUrl: (raw['shareUrl'] ?? raw['share_url'])?.toString(),
      shareMessage: (raw['shareMessage'] ?? raw['share_message'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    urlKey,
    price,
    priceFormatted,
    commission,
    isAffiliate,
    referralCode,
    shareUrl,
    shareMessage,
  ];
}

/// Dynamic product commission detail
class ProductCommissionInfo extends Equatable {
  final bool isExcluded;
  final String type;
  final double rate;
  final double estimatedAmount;
  final String displayText;

  const ProductCommissionInfo({
    required this.isExcluded,
    required this.type,
    required this.rate,
    required this.estimatedAmount,
    required this.displayText,
  });

  factory ProductCommissionInfo.fromJson(Map<String, dynamic> json) {
    return ProductCommissionInfo(
      isExcluded: (json['isExcluded'] ?? json['is_excluded']) == true,
      type: json['type']?.toString() ?? 'percentage',
      rate: _toDouble(json['rate']),
      estimatedAmount: _toDouble(json['estimatedAmount'] ?? json['estimated_amount']),
      displayText: (json['displayText'] ?? json['display_text'])?.toString() ?? '',
    );
  }

  factory ProductCommissionInfo.empty() {
    return const ProductCommissionInfo(
      isExcluded: false,
      type: 'percentage',
      rate: 0.0,
      estimatedAmount: 0.0,
      displayText: '',
    );
  }

  @override
  List<Object?> get props => [
    isExcluded,
    type,
    rate,
    estimatedAmount,
    displayText,
  ];
}

/// Wallet transaction (Passbook item)
class AffiliateTransaction extends Equatable {
  final String id;
  final String? transactionNumber;
  final String type; // credit, debit, withdrawal
  final double amount;
  final String amountFormatted;
  final double balanceAfter;
  final String balanceAfterFormatted;
  final String status;
  final String? title;
  final String? description;
  final String? createdAt;

  const AffiliateTransaction({
    required this.id,
    this.transactionNumber,
    required this.type,
    required this.amount,
    required this.amountFormatted,
    required this.balanceAfter,
    required this.balanceAfterFormatted,
    required this.status,
    this.title,
    this.description,
    this.createdAt,
  });

  bool get isCredit => type.toLowerCase() == 'credit';

  factory AffiliateTransaction.fromJson(Map<String, dynamic> json) {
    return AffiliateTransaction(
      id: json['id']?.toString() ?? '',
      transactionNumber: (json['transactionNumber'] ?? json['transaction_number'])?.toString(),
      type: json['type']?.toString() ?? 'credit',
      amount: _toDouble(json['amount']),
      amountFormatted: (json['amountFormatted'] ?? json['amount_formatted'])?.toString() ?? '₹0.00',
      balanceAfter: _toDouble(json['balanceAfter'] ?? json['balance_after']),
      balanceAfterFormatted:
          (json['balanceAfterFormatted'] ?? json['balance_after_formatted'])?.toString() ?? '₹0.00',
      status: json['status']?.toString() ?? 'completed',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    transactionNumber,
    type,
    amount,
    amountFormatted,
    balanceAfter,
    balanceAfterFormatted,
    status,
    title,
    description,
    createdAt,
  ];
}

/// Paginated transactions container
class AffiliateTransactionsResponse extends Equatable {
  final List<AffiliateTransaction> data;
  final PaginationMeta meta;

  const AffiliateTransactionsResponse({
    required this.data,
    required this.meta,
  });

  factory AffiliateTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return AffiliateTransactionsResponse(
      data: list
          .map((e) => AffiliateTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : PaginationMeta.empty(),
    );
  }

  @override
  List<Object?> get props => [data, meta];
}

/// Referral order commission
class AffiliateCommission extends Equatable {
  final String id;
  final String? orderId;
  final String? orderNumber;
  final double itemPrice;
  final int itemQty;
  final String? commissionType;
  final double commissionRate;
  final double commissionAmount;
  final String commissionFormatted;
  final String status; // pending, cleared, rejected
  final String? clearsAt;
  final String? createdAt;

  const AffiliateCommission({
    required this.id,
    this.orderId,
    this.orderNumber,
    required this.itemPrice,
    required this.itemQty,
    this.commissionType,
    required this.commissionRate,
    required this.commissionAmount,
    required this.commissionFormatted,
    required this.status,
    this.clearsAt,
    this.createdAt,
  });

  factory AffiliateCommission.fromJson(Map<String, dynamic> json) {
    return AffiliateCommission(
      id: json['id']?.toString() ?? '',
      orderId: (json['orderId'] ?? json['order_id'])?.toString(),
      orderNumber: (json['orderNumber'] ?? json['order_number'])?.toString(),
      itemPrice: _toDouble(json['itemPrice'] ?? json['item_price']),
      itemQty: _toInt(json['itemQty'] ?? json['item_qty'], fallback: 1),
      commissionType: (json['commissionType'] ?? json['commission_type'])?.toString(),
      commissionRate: _toDouble(json['commissionRate'] ?? json['commission_rate']),
      commissionAmount: _toDouble(json['commissionAmount'] ?? json['commission_amount']),
      commissionFormatted:
          (json['commissionFormatted'] ?? json['commission_formatted'])?.toString() ?? '₹0.00',
      status: json['status']?.toString() ?? 'pending',
      clearsAt: (json['clearsAt'] ?? json['clears_at'])?.toString(),
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    orderNumber,
    itemPrice,
    itemQty,
    commissionType,
    commissionRate,
    commissionAmount,
    commissionFormatted,
    status,
    clearsAt,
    createdAt,
  ];
}

/// Paginated commissions container
class AffiliateCommissionsResponse extends Equatable {
  final List<AffiliateCommission> data;
  final PaginationMeta meta;

  const AffiliateCommissionsResponse({
    required this.data,
    required this.meta,
  });

  factory AffiliateCommissionsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return AffiliateCommissionsResponse(
      data: list
          .map((e) => AffiliateCommission.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : PaginationMeta.empty(),
    );
  }

  @override
  List<Object?> get props => [data, meta];
}

/// Withdrawal / Payout request
class AffiliatePayout extends Equatable {
  final String id;
  final String? payoutNumber;
  final double amount;
  final String amountFormatted;
  final String payoutMethod;
  final String status; // pending, approved, paid, rejected
  final String? transactionReference; // UTR or Bank ref
  final String? adminNotes;
  final String? createdAt;

  const AffiliatePayout({
    required this.id,
    this.payoutNumber,
    required this.amount,
    required this.amountFormatted,
    required this.payoutMethod,
    required this.status,
    this.transactionReference,
    this.adminNotes,
    this.createdAt,
  });

  factory AffiliatePayout.fromJson(Map<String, dynamic> json) {
    return AffiliatePayout(
      id: json['id']?.toString() ?? '',
      payoutNumber: (json['payoutNumber'] ?? json['payout_number'])?.toString(),
      amount: _toDouble(json['amount']),
      amountFormatted: (json['amountFormatted'] ?? json['amount_formatted'])?.toString() ?? '₹0.00',
      payoutMethod: (json['payoutMethod'] ?? json['payout_method'])?.toString() ?? 'upi',
      status: json['status']?.toString() ?? 'pending',
      transactionReference: (json['transactionReference'] ?? json['transaction_reference'])?.toString(),
      adminNotes: (json['adminNotes'] ?? json['admin_notes'])?.toString(),
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    payoutNumber,
    amount,
    amountFormatted,
    payoutMethod,
    status,
    transactionReference,
    adminNotes,
    createdAt,
  ];
}

/// Paginated payouts container
class AffiliatePayoutsResponse extends Equatable {
  final List<AffiliatePayout> data;
  final PaginationMeta meta;

  const AffiliatePayoutsResponse({
    required this.data,
    required this.meta,
  });

  factory AffiliatePayoutsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return AffiliatePayoutsResponse(
      data: list
          .map((e) => AffiliatePayout.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : PaginationMeta.empty(),
    );
  }

  @override
  List<Object?> get props => [data, meta];
}

/// Common pagination meta
class PaginationMeta extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: _toInt(json['currentPage'] ?? json['current_page'], fallback: 1),
      lastPage: _toInt(json['lastPage'] ?? json['last_page'], fallback: 1),
      perPage: _toInt(json['perPage'] ?? json['per_page'], fallback: 15),
      total: _toInt(json['total'], fallback: 0),
    );
  }

  const PaginationMeta.empty()
      : currentPage = 1,
        lastPage = 1,
        perPage = 15,
        total = 0;

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}

/// Mutation result objects
class AffiliateRegistrationResult {
  final bool success;
  final String message;
  final int? affiliateId;
  final String? referralCode;
  final String? referralLink;
  final String? status;

  AffiliateRegistrationResult({
    required this.success,
    required this.message,
    this.affiliateId,
    this.referralCode,
    this.referralLink,
    this.status,
  });

  factory AffiliateRegistrationResult.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['registerAffiliate'] is Map<String, dynamic>
            ? json['registerAffiliate'] as Map<String, dynamic>
            : json);

    return AffiliateRegistrationResult(
      success: raw['success'] == true || json['success'] == true,
      message: (raw['message'] ?? json['message'])?.toString() ?? '',
      affiliateId: raw['affiliateId'] is int
          ? raw['affiliateId']
          : (raw['affiliate_id'] is int
              ? raw['affiliate_id']
              : int.tryParse(
                  (raw['affiliateId'] ?? raw['affiliate_id'])?.toString() ?? '',
                )),
      referralCode: (raw['referralCode'] ?? raw['referral_code'])?.toString(),
      referralLink: (raw['referralLink'] ?? raw['referral_link'])?.toString(),
      status: (raw['status'] ?? raw['affiliate_status'])?.toString(),
    );
  }
}

class PayoutRequestResult {
  final bool success;
  final String message;
  final String? payoutId;
  final String? payoutNumber;
  final double? amount;
  final String? amountFormatted;
  final String? method;
  final String? status;
  final double? availableBalance;
  final double? lockedBalance;

  PayoutRequestResult({
    required this.success,
    required this.message,
    this.payoutId,
    this.payoutNumber,
    this.amount,
    this.amountFormatted,
    this.method,
    this.status,
    this.availableBalance,
    this.lockedBalance,
  });

  factory PayoutRequestResult.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['requestAffiliatePayout'] is Map<String, dynamic>
            ? json['requestAffiliatePayout'] as Map<String, dynamic>
            : json);

    return PayoutRequestResult(
      success: raw['success'] == true || json['success'] == true,
      message: (raw['message'] ?? json['message'])?.toString() ?? '',
      payoutId: (raw['payoutId'] ?? raw['payout_id'])?.toString(),
      payoutNumber: (raw['payoutNumber'] ?? raw['payout_number'])?.toString(),
      amount: _toDouble(raw['amount']),
      amountFormatted: (raw['amountFormatted'] ?? raw['amount_formatted'])?.toString(),
      method: (raw['method'] ?? raw['payout_method'])?.toString(),
      status: raw['status']?.toString(),
      availableBalance: _toDouble(raw['availableBalance'] ?? raw['available_balance']),
      lockedBalance: _toDouble(raw['lockedBalance'] ?? raw['locked_balance']),
    );
  }
}

class PayoutSettingsResult {
  final bool success;
  final String message;
  final String? payoutMethod;
  final dynamic details;

  PayoutSettingsResult({
    required this.success,
    required this.message,
    this.payoutMethod,
    this.details,
  });

  factory PayoutSettingsResult.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['updateAffiliatePayoutSettings'] is Map<String, dynamic>
            ? json['updateAffiliatePayoutSettings'] as Map<String, dynamic>
            : json);

    return PayoutSettingsResult(
      success: raw['success'] == true || json['success'] == true,
      message: (raw['message'] ?? json['message'])?.toString() ?? '',
      payoutMethod: (raw['payoutMethod'] ?? raw['payout_method'])?.toString(),
      details: raw['details'],
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

double _toDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
