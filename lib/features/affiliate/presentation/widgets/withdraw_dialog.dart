import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/affiliate_models.dart';

class WithdrawDialog extends StatefulWidget {
  final AffiliateDashboardData dashboard;
  final void Function(double amount, String payoutMethod, String? upiId) onConfirm;

  const WithdrawDialog({
    super.key,
    required this.dashboard,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required AffiliateDashboardData dashboard,
    required void Function(double amount, String payoutMethod, String? upiId) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WithdrawDialog(
        dashboard: dashboard,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  String _selectedMethod = 'upi';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final profile = widget.dashboard.payoutProfile;
    if (profile.method != null && profile.method!.isNotEmpty) {
      _selectedMethod = profile.method!;
    }
    if (profile.upiId != null) {
      _upiController.text = profile.upiId!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    final minAmount = widget.dashboard.config.minWithdrawalAmount;
    final available = widget.dashboard.wallet.availableBalance;

    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Please enter a valid withdrawal amount');
      return;
    }
    if (amount < minAmount) {
      setState(() => _errorText = 'Minimum withdrawal is ₹${minAmount.toStringAsFixed(0)}');
      return;
    }
    if (amount > available) {
      setState(() => _errorText = 'Amount exceeds available balance of ${widget.dashboard.wallet.availableFormatted}');
      return;
    }

    if (_selectedMethod == 'upi' && _upiController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter your UPI ID');
      return;
    }

    Navigator.of(context).pop();
    widget.onConfirm(
      amount,
      _selectedMethod,
      _selectedMethod == 'upi' ? _upiController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final available = widget.dashboard.wallet.availableFormatted;
    final minAmount = widget.dashboard.config.minWithdrawalAmount;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral900 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Withdraw Funds',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.neutral900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Balance note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppColors.primary600, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance: $available',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        'Minimum payout: ₹${minAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount field
            Text(
              'Withdrawal Amount (₹)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? AppColors.neutral300 : AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount (e.g. 500)',
                prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary500, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payout Method Selector
            Text(
              'Payout Method',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? AppColors.neutral300 : AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('UPI')),
                    selected: _selectedMethod == 'upi',
                    selectedColor: AppColors.primary100,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMethod = 'upi');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Bank Transfer')),
                    selected: _selectedMethod == 'bank_transfer',
                    selectedColor: AppColors.primary100,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMethod = 'bank_transfer');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_selectedMethod == 'upi') ...[
              Text(
                'UPI ID',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _upiController,
                decoration: InputDecoration(
                  hintText: 'e.g. username@okhdfcbank',
                  prefixIcon: const Icon(Icons.mobile_friendly, color: AppColors.primary600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary500, width: 2),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.dashboard.payoutProfile.accountNumber != null
                      ? 'Will transfer to A/C: ${widget.dashboard.payoutProfile.accountNumber} (${widget.dashboard.payoutProfile.bankName ?? "Bank"})'
                      : 'Please configure bank account details in Payout Settings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                  ),
                ),
              ),
            ],

            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
              ),
            ],

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
                onPressed: _submit,
                child: const Text(
                  'Confirm Withdrawal Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
