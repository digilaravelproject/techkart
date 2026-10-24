import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/repository/account_repository.dart';
import '../bloc/account_dashboard_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../pages/orders_page.dart';
import '../pages/account_menu_page.dart';
import '../pages/preferences_bottom_sheet.dart';
import '../pages/settings_bottom_sheet.dart';
import '../../../affiliate/presentation/pages/affiliate_dashboard_page.dart';

/// Quick action chips: My Orders, Account, Settings
/// Figma: node-id=220-6548
class QuickActionChips extends StatelessWidget {
  const QuickActionChips({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              _buildChip(
                context: context,
                label: l10n.accountMyOrders,
                isDark: isDark,
                onTap: () {
                  final repository = context.read<AccountRepository>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RepositoryProvider.value(
                        value: repository,
                        child: BlocProvider(
                          create: (_) =>
                              OrdersBloc(repository: repository)
                                ..add(const LoadOrders()),
                          child: const OrdersPage(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildChip(
                context: context,
                label: l10n.accountAccount,
                isDark: isDark,
                onTap: () {
                  _navigateToAccountMenu(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(
                context: context,
                label: l10n.accountSettings,
                isDark: isDark,
                onTap: () {
                  SettingsBottomSheet.show(context);
                },
              ),
              const SizedBox(width: 12),
              _buildChip(
                context: context,
                label: l10n.accountPreferences,
                isDark: isDark,
                onTap: () {
                  PreferencesBottomSheet.show(context, showSettingsSection: false);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Refer & Earn Quick Banner ──
          GestureDetector(
            onTap: () => AffiliateDashboardPage.navigate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary50, AppColors.primary100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refer & Earn Rewards',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.primary900,
                          ),
                        ),
                        Text(
                          'Share products & earn wallet cashback',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAccountMenu(BuildContext context) {
    final profile = context.read<AccountDashboardBloc>().state.profile;
    final repository = context.read<AccountRepository>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: AccountMenuPage(profile: profile),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : AppColors.neutral100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? AppColors.neutral200 : AppColors.neutral900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
