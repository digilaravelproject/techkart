/// Bagisto BEENZO Affiliate & Referral System GraphQL Queries & Mutations
class AffiliateQueries {
  // ─── Queries ─────────────────────────────────────────────────────────────

  /// Fetch affiliate dashboard (live wallet, referral code, stats, payout settings)
  static const String getAffiliateDashboard = r'''
    query GetAffiliateDashboard {
      affiliateDashboard {
        affiliateId
        status
        referralCode
        referralLink
        wallet {
          availableBalance
          availableFormatted
          pendingBalance
          pendingFormatted
          lockedBalance
          lockedFormatted
          lifetimeEarned
          lifetimeFormatted
          totalWithdrawn
          currency
          currencySymbol
        }
        stats {
          totalClicks
          totalOrders
          conversionRate
        }
        payoutProfile {
          method
          upiId
          accountNumber
          ifscCode
          accountHolder
          bankName
        }
        config {
          minWithdrawalAmount
          clearanceDays
          defaultCommissionType
          defaultCommissionValue
        }
      }
    }
  ''';

  /// Fetch dynamic product commission info and shareable link for PDP
  static const String getProductShareInfo = r'''
    query GetProductShareInfo($productId: Int!) {
      productShareInfo(productId: $productId) {
        productId
        name
        urlKey
        price
        priceFormatted
        commission {
          isExcluded
          type
          rate
          estimatedAmount
          displayText
        }
        isAffiliate
        referralCode
        shareUrl
        shareMessage
      }
    }
  ''';

  /// Paginated wallet passbook transactions
  static const String getAffiliateTransactions = r'''
    query GetAffiliateTransactions($page: Int, $limit: Int) {
      affiliateTransactions(page: $page, limit: $limit) {
        data {
          id
          transactionNumber
          type
          amount
          amountFormatted
          balanceAfter
          balanceAfterFormatted
          status
          title
          description
          createdAt
        }
        meta {
          currentPage
          lastPage
          perPage
          total
        }
      }
    }
  ''';

  /// Paginated affiliate commissions (earned from referral orders)
  static const String getAffiliateCommissions = r'''
    query GetAffiliateCommissions($page: Int, $limit: Int) {
      affiliateCommissions(page: $page, limit: $limit) {
        data {
          id
          orderId
          orderNumber
          itemPrice
          itemQty
          commissionType
          commissionRate
          commissionAmount
          commissionFormatted
          status
          clearsAt
          createdAt
        }
        meta {
          currentPage
          lastPage
          perPage
          total
        }
      }
    }
  ''';

  /// Paginated affiliate withdrawal / payout requests
  static const String getAffiliatePayouts = r'''
    query GetAffiliatePayouts($page: Int, $limit: Int) {
      affiliatePayouts(page: $page, limit: $limit) {
        data {
          id
          payoutNumber
          amount
          amountFormatted
          payoutMethod
          status
          transactionReference
          adminNotes
          createdAt
        }
        meta {
          currentPage
          lastPage
          perPage
          total
        }
      }
    }
  ''';

  // ─── Mutations ───────────────────────────────────────────────────────────

  /// 1-Click activate affiliate program
  static const String registerAffiliate = r'''
    mutation RegisterAffiliate {
      registerAffiliate {
        success
        message
        affiliateId
        referralCode
        referralLink
        status
      }
    }
  ''';

  /// Custom affiliate link generator
  static const String generateAffiliateLink = r'''
    mutation GenerateAffiliateLink($url: String, $productId: Int) {
      generateAffiliateLink(url: $url, productId: $productId) {
        success
        referralCode
        shareUrl
        shareMessage
      }
    }
  ''';

  /// Update payout settings (UPI or Bank account)
  static const String updateAffiliatePayoutSettings = r'''
    mutation UpdatePayoutSettings(
      $payoutMethod: String!
      $upiId: String
      $accountNumber: String
      $ifscCode: String
      $accountHolder: String
      $bankName: String
    ) {
      updateAffiliatePayoutSettings(
        payoutMethod: $payoutMethod
        upiId: $upiId
        accountNumber: $accountNumber
        ifscCode: $ifscCode
        accountHolder: $accountHolder
        bankName: $bankName
      ) {
        success
        message
        payoutMethod
        details
      }
    }
  ''';

  /// Request withdrawal of available balance
  static const String requestAffiliatePayout = r'''
    mutation RequestPayout($amount: Float!, $payoutMethod: String, $upiId: String) {
      requestAffiliatePayout(amount: $amount, payoutMethod: $payoutMethod, upiId: $upiId) {
        success
        message
        payoutId
        payoutNumber
        amount
        amountFormatted
        method
        status
        availableBalance
        lockedBalance
      }
    }
  ''';

  /// Record referral click (e.g. from deep link)
  static const String trackAffiliateReferral = r'''
    mutation TrackReferral($referralCode: String!) {
      trackAffiliateReferral(referralCode: $referralCode) {
        success
        message
        referralCode
      }
    }
  ''';
}
