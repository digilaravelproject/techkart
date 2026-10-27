import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/models/affiliate_models.dart';
import '../../data/repository/affiliate_repository.dart';
import '../bloc/affiliate_bloc.dart';
import '../widgets/payout_settings_dialog.dart';
import '../widgets/withdraw_dialog.dart';

class AffiliateDashboardPage extends StatelessWidget {
  const AffiliateDashboardPage({super.key});

  static Future<void> navigate(BuildContext context) {
    final repository = context.read<AffiliateRepository>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: BlocProvider(
            create: (_) => AffiliateBloc(repository: repository)
              ..add(const LoadAffiliateDashboard()),
            child: const AffiliateDashboardPage(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AffiliateBloc, AffiliateState>(
      listener: (context, state) {
        if (state.actionSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccessMessage!),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.errorMessage != null && state.status != AffiliateStatus.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.neutral900 : AppColors.white,
          appBar: AppBar(
            leading: const AppBackButton(),
            title: const Text(
              'Refer & Earn',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            backgroundColor: isDark ? AppColors.neutral900 : AppColors.white,
            elevation: 0,
            actions: [
              if (state.dashboard?.isActive == true)
                IconButton(
                  tooltip: 'Payout Settings',
                  icon: const Icon(Icons.settings_outlined, color: AppColors.primary600),
                  onPressed: () {
                    PayoutSettingsDialog.show(
                      context,
                      currentProfile: state.dashboard!.payoutProfile,
                      onSave: ({
                        required payoutMethod,
                        accountHolder,
                        accountNumber,
                        bankName,
                        ifscCode,
                        upiId,
                      }) {
                        context.read<AffiliateBloc>().add(
                              UpdatePayoutSettingsEvent(
                                payoutMethod: payoutMethod,
                                accountHolder: accountHolder,
                                accountNumber: accountNumber,
                                bankName: bankName,
                                ifscCode: ifscCode,
                                upiId: upiId,
                              ),
                            );
                      },
                    );
                  },
                ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: _buildBody(context, state, isDark),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AffiliateState state, bool isDark) {
    final authState = context.watch<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;

    if (!isLoggedIn) {
      return _buildLoginPrompt(context, isDark);
    }

    if (state.status == AffiliateStatus.loading && state.dashboard == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary500),
      );
    }

    final dashboard = state.dashboard;
    if (dashboard == null || !dashboard.isActive) {
      return _buildRegistrationView(context, state, isDark);
    }

    return RefreshIndicator(
      color: AppColors.primary500,
      onRefresh: () async {
        context.read<AffiliateBloc>().add(
              const LoadAffiliateDashboard(isRefresh: true),
            );
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Wallet Card
          _buildWalletCard(context, dashboard, isDark),
          const SizedBox(height: 16),

          // Referral Link & Code Card
          _buildReferralCard(context, dashboard, isDark),
          const SizedBox(height: 16),

          // Performance Stats
          _buildStatsSection(context, dashboard.stats, isDark),
          const SizedBox(height: 20),

          // History Section Header & Tabs
          _buildTabsHeader(context, state, isDark),
          const SizedBox(height: 12),

          // Tab Content
          _buildTabContent(context, state, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── 1. Login Prompt ──────────────────────────────────────────────────────

  Widget _buildLoginPrompt(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary200),
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 48,
                color: AppColors.primary600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'BEENZO Affiliate & Referral Program',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: isDark ? AppColors.white : AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to your account to get your unique referral link, earn commissions on friends\' purchases, and withdraw rewards to UPI / Bank.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Login to Continue', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 2. One-Click Registration Onboarding ────────────────────────────────

  Widget _buildRegistrationView(BuildContext context, AffiliateState state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary50, AppColors.primary100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 56,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Join BEENZO Affiliate Program',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: isDark ? AppColors.white : AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share fashion & lifestyle products with friends and followers. Earn instant commission on every delivered order!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.neutral300 : AppColors.neutral600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          _buildBenefitItem(
            icon: Icons.percent,
            title: 'Earn High Commissions',
            subtitle: 'Get up to 10% commission on eligible orders placed through your link.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.account_balance_wallet,
            title: 'Live Wallet & Fast Payouts',
            subtitle: 'Instant passbook tracking. Withdraw directly to UPI or bank account.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.share,
            title: '1-Tap Product Sharing',
            subtitle: 'Direct WhatsApp share buttons right inside product pages.',
            isDark: isDark,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: state.isSubmittingAction
                  ? null
                  : () {
                      context.read<AffiliateBloc>().add(
                            const RegisterAffiliateEvent(),
                          );
                    },
              child: state.isSubmittingAction
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Activate Affiliate Program Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary200),
          ),
          child: Icon(icon, color: AppColors.primary600, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 3. Wallet Card ───────────────────────────────────────────────────────

  Widget _buildWalletCard(
    BuildContext context,
    AffiliateDashboardData dashboard,
    bool isDark,
  ) {
    final wallet = dashboard.wallet;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary700,
            AppColors.primary900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Affiliate Wallet',
                    style: TextStyle(
                      color: AppColors.primary100,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Text(
            'Available to Withdraw',
            style: TextStyle(color: AppColors.primary100, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            wallet.availableFormatted,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),

          // Withdraw CTA Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    elevation: 0,
                  ),
                  onPressed: () {
                    WithdrawDialog.show(
                      context,
                      dashboard: dashboard,
                      onConfirm: (amount, method, upiId) {
                        context.read<AffiliateBloc>().add(
                              RequestPayoutEvent(
                                amount: amount,
                                payoutMethod: method,
                                upiId: upiId,
                              ),
                            );
                      },
                    );
                  },
                  icon: const Icon(Icons.arrow_circle_up, size: 18, color: AppColors.primary700),
                  label: const Text(
                    'Withdraw Funds',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // Sub-balances
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubBalanceItem(
                label: 'Pending',
                value: wallet.pendingFormatted,
                tooltip: 'Clears in ${dashboard.config.clearanceDays} days',
              ),
              _buildSubBalanceItem(
                label: 'Lifetime Earned',
                value: wallet.lifetimeFormatted,
              ),
              _buildSubBalanceItem(
                label: 'Total Withdrawn',
                value: '₹${wallet.totalWithdrawn.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubBalanceItem({
    required String label,
    required String value,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.primary100, fontSize: 11),
            ),
            if (tooltip != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 10, color: AppColors.primary200),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ─── 4. Referral Code & Link Card ────────────────────────────────────────

  Widget _buildReferralCard(
    BuildContext context,
    AffiliateDashboardData dashboard,
    bool isDark,
  ) {
    final code = dashboard.referralCode ?? '';
    final link = dashboard.referralLink ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Referral Code',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.neutral900,
                ),
              ),
              const Icon(Icons.qr_code, size: 20, color: AppColors.primary600),
            ],
          ),
          const SizedBox(height: 10),

          // Code Container with Copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral900 : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontSize: 16,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 16, color: AppColors.primary600),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: AppColors.primary600,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Share Link CTA
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary600,
                    side: const BorderSide(color: AppColors.primary500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral link copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Copy Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final box = context.findRenderObject() as RenderBox?;
                    Share.share(
                      'Shop premium products on BEENZO with my referral link: $link',
                      sharePositionOrigin: box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : Rect.zero,
                    );
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 5. Performance Stats ────────────────────────────────────────────────

  Widget _buildStatsSection(
    BuildContext context,
    AffiliateStats stats,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Total Clicks',
            value: stats.totalClicks.toString(),
            icon: Icons.ads_click,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            label: 'Total Orders',
            value: stats.totalOrders.toString(),
            icon: Icons.shopping_bag_outlined,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            label: 'Conversion',
            value: '${stats.conversionRate.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary600),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 6. Tabs Header ──────────────────────────────────────────────────────

  Widget _buildTabsHeader(BuildContext context, AffiliateState state, bool isDark) {
    final titles = ['Passbook', 'Orders', 'Payouts'];

    return Row(
      children: List.generate(titles.length, (index) {
        final isSelected = state.selectedTabIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<AffiliateBloc>().add(SwitchAffiliateTabEvent(index));
            },
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary600
                    : (isDark ? AppColors.neutral800 : AppColors.neutral100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.white
                        : (isDark ? AppColors.neutral300 : AppColors.neutral700),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── 7. Tab Content ──────────────────────────────────────────────────────

  Widget _buildTabContent(BuildContext context, AffiliateState state, bool isDark) {
    switch (state.selectedTabIndex) {
      case 0:
        return _buildPassbookList(state.transactions, isDark);
      case 1:
        return _buildCommissionsList(state.commissions, isDark);
      case 2:
        return _buildPayoutsList(state.payouts, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPassbookList(List<AffiliateTransaction> items, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('No wallet transactions found yet.');
    }

    return Column(
      children: items.map((tx) {
        final isCredit = tx.isCredit;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCredit
                      ? AppColors.success50
                      : AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 16,
                  color: isCredit ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title ?? (isCredit ? 'Commission Credited' : 'Withdrawal Debit'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.white : AppColors.neutral900,
                      ),
                    ),
                    if (tx.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        tx.createdAt!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}${tx.amountFormatted}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isCredit ? AppColors.successGreen : AppColors.neutral900,
                    ),
                  ),
                  Text(
                    'Bal: ${tx.balanceAfterFormatted}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommissionsList(List<AffiliateCommission> items, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('No referral orders or commissions yet.');
    }

    return Column(
      children: items.map((comm) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${comm.orderNumber ?? comm.orderId ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comm.clearsAt != null
                        ? 'Clears at: ${comm.clearsAt}'
                        : (comm.createdAt ?? ''),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${comm.commissionFormatted}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.successGreen,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: comm.status.toLowerCase() == 'cleared'
                          ? AppColors.success50
                          : AppColors.primary50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      comm.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: comm.status.toLowerCase() == 'cleared'
                            ? AppColors.successGreen
                            : AppColors.primary700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayoutsList(List<AffiliatePayout> items, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('No withdrawal requests submitted yet.');
    }

    return Column(
      children: items.map((payout) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payout #${payout.payoutNumber ?? payout.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Method: ${payout.payoutMethod.toUpperCase()}${payout.transactionReference != null ? " • Ref: ${payout.transactionReference}" : ""}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payout.amountFormatted,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.white : AppColors.neutral900,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: payout.status.toLowerCase() == 'paid'
                          ? AppColors.success50
                          : AppColors.primary50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      payout.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: payout.status.toLowerCase() == 'paid'
                            ? AppColors.successGreen
                            : AppColors.primary700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.neutral500,
          fontSize: 13,
        ),
      ),
    );
  }
}
