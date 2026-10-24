import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/affiliate_models.dart';
import '../../data/repository/affiliate_repository.dart';

/// Product Share & Earn banner displayed on the Product Detail Page (PDP).
class ProductShareEarnBanner extends StatefulWidget {
  final int productId;

  const ProductShareEarnBanner({super.key, required this.productId});

  @override
  State<ProductShareEarnBanner> createState() => _ProductShareEarnBannerState();
}

class _ProductShareEarnBannerState extends State<ProductShareEarnBanner> {
  ProductShareInfo? _shareInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShareInfo();
  }

  @override
  void didUpdateWidget(covariant ProductShareEarnBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _loadShareInfo();
    }
  }

  Future<void> _loadShareInfo() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AffiliateRepository>();
      final info = await repo.getProductShareInfo(widget.productId);
      if (mounted) {
        setState(() {
          _shareInfo = info;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _share(BuildContext context) {
    final msg = _shareInfo?.shareMessage ??
        'Check out this product on BEENZO: ${_shareInfo?.shareUrl ?? ""}';

    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      msg,
      subject: _shareInfo?.name ?? 'BEENZO Product',
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final info = _shareInfo;
    if (info == null || info.commission.isExcluded) {
      return const SizedBox.shrink();
    }

    final displayText = info.commission.displayText.isNotEmpty
        ? info.commission.displayText
        : 'Earn commission on every referral';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary50,
            AppColors.primary100.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary300, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary600.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayText,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primary900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Share link with friends & get rewarded',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary600,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _share(context),
            icon: const Icon(Icons.share, size: 14),
            label: const Text(
              'Share',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
