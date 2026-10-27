import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/affiliate_models.dart';

class PayoutSettingsDialog extends StatefulWidget {
  final AffiliatePayoutProfile currentProfile;
  final void Function({
    required String payoutMethod,
    String? upiId,
    String? accountNumber,
    String? ifscCode,
    String? accountHolder,
    String? bankName,
  }) onSave;

  const PayoutSettingsDialog({
    super.key,
    required this.currentProfile,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required AffiliatePayoutProfile currentProfile,
    required void Function({
      required String payoutMethod,
      String? upiId,
      String? accountNumber,
      String? ifscCode,
      String? accountHolder,
      String? bankName,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayoutSettingsDialog(
        currentProfile: currentProfile,
        onSave: onSave,
      ),
    );
  }

  @override
  State<PayoutSettingsDialog> createState() => _PayoutSettingsDialogState();
}

class _PayoutSettingsDialogState extends State<PayoutSettingsDialog> {
  String _selectedMethod = 'upi';
  late final TextEditingController _upiController;
  late final TextEditingController _accNumController;
  late final TextEditingController _ifscController;
  late final TextEditingController _holderController;
  late final TextEditingController _bankController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;
    _selectedMethod = (p.method == 'bank_transfer') ? 'bank_transfer' : 'upi';
    _upiController = TextEditingController(text: p.upiId ?? '');
    _accNumController = TextEditingController(text: p.accountNumber ?? '');
    _ifscController = TextEditingController(text: p.ifscCode ?? '');
    _holderController = TextEditingController(text: p.accountHolder ?? '');
    _bankController = TextEditingController(text: p.bankName ?? '');
  }

  @override
  void dispose() {
    _upiController.dispose();
    _accNumController.dispose();
    _ifscController.dispose();
    _holderController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _errorText = null);

    if (_selectedMethod == 'upi') {
      final upi = _upiController.text.trim();
      if (upi.isEmpty) {
        setState(() => _errorText = 'Please enter a valid UPI ID');
        return;
      }
      Navigator.of(context).pop();
      widget.onSave(payoutMethod: 'upi', upiId: upi);
    } else {
      final acc = _accNumController.text.trim();
      final ifsc = _ifscController.text.trim();
      final holder = _holderController.text.trim();
      final bank = _bankController.text.trim();

      if (acc.isEmpty || ifsc.isEmpty || holder.isEmpty) {
        setState(() => _errorText = 'Account number, IFSC code, and Holder name are required');
        return;
      }
      Navigator.of(context).pop();
      widget.onSave(
        payoutMethod: 'bank_transfer',
        accountNumber: acc,
        ifscCode: ifsc,
        accountHolder: holder,
        bankName: bank.isNotEmpty ? bank : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral900 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: viewInsets > 0 ? viewInsets + 16 : 24,
          ),
          child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payout Settings',
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
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('UPI Account')),
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
                    label: const Center(child: Text('Bank Details')),
                    selected: _selectedMethod == 'bank_transfer',
                    selectedColor: AppColors.primary100,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMethod = 'bank_transfer');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_selectedMethod == 'upi') ...[
              _buildField(
                label: 'UPI ID (Virtual Payment Address)',
                hint: 'e.g. rahul@okhdfcbank',
                controller: _upiController,
                isDark: isDark,
              ),
            ] else ...[
              _buildField(
                label: 'Account Holder Name',
                hint: 'Name as registered in bank',
                controller: _holderController,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Bank Account Number',
                hint: 'e.g. 50100412345678',
                controller: _accNumController,
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'IFSC Code',
                hint: 'e.g. HDFC0001234',
                controller: _ifscController,
                textCapitalization: TextCapitalization.characters,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Bank Name (Optional)',
                hint: 'e.g. HDFC Bank',
                controller: _bankController,
                isDark: isDark,
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
                onPressed: _save,
                child: const Text(
                  'Save Payout Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    ),
  );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? AppColors.neutral300 : AppColors.neutral700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary500, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
