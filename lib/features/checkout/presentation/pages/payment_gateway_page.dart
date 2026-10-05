import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';

enum PaymentResultStatus {
  success,
  failed,
  cancelled,
}

class PaymentResult {
  final PaymentResultStatus status;
  final String? message;
  final String? orderId;

  const PaymentResult({
    required this.status,
    this.message,
    this.orderId,
  });

  bool get isSuccess => status == PaymentResultStatus.success;
}

class PaymentGatewayPage extends StatefulWidget {
  final String paymentUrl;
  final String? authToken;
  final String paymentTitle;

  const PaymentGatewayPage({
    super.key,
    required this.paymentUrl,
    this.authToken,
    this.paymentTitle = 'Payment Gateway',
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  double _progress = 0.0;
  bool _isLoading = true;
  bool _isFinished = false;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'X-STOREFRONT-KEY': storefrontKey,
      'X-CHANNEL': channelCode,
    };
    if (widget.authToken != null && widget.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${widget.authToken}';
    }
    return headers;
  }

  void _checkUrl(String? url) {
    if (url == null || _isFinished) return;

    final lower = url.toLowerCase();
    debugPrint('[PaymentGateway] Current URL: $url');

    // Success detection
    if (lower.contains('/success') ||
        lower.contains('/onepage/success') ||
        lower.contains('/razorpay/payment/success') ||
        lower.contains('/checkout/success') ||
        lower.contains('order-success')) {
      _isFinished = true;
      debugPrint('✅ [PaymentGateway] Payment SUCCESS detected at: $url');
      
      // Attempt to extract order ID if present in URL query params
      String? orderId;
      try {
        final uri = Uri.parse(url);
        orderId = uri.queryParameters['order_id'] ??
            uri.queryParameters['orderId'] ??
            uri.queryParameters['id'];
      } catch (_) {}

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pop(
            PaymentResult(
              status: PaymentResultStatus.success,
              orderId: orderId,
              message: 'Payment completed successfully!',
            ),
          );
        }
      });
      return;
    }

    // Failure / Cancel detection
    if (lower.contains('/failure') ||
        lower.contains('/razorpay/payment/failure') ||
        lower.contains('/payment/cancel') ||
        (lower.contains('/checkout/cart') && !lower.contains('redirect'))) {
      _isFinished = true;
      debugPrint('❌ [PaymentGateway] Payment FAILURE/CANCEL detected at: $url');
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pop(
            const PaymentResult(
              status: PaymentResultStatus.failed,
              message: 'Payment failed or was cancelled.',
            ),
          );
        }
      });
      return;
    }
  }

  Future<bool> _onWillPop() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel the payment? Your order will not be completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      if (mounted) {
        Navigator.of(context).pop(
          const PaymentResult(
            status: PaymentResultStatus.cancelled,
            message: 'Payment was cancelled by the user.',
          ),
        );
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.paymentTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.neutral900,
            ),
          ),
          backgroundColor: isDark ? AppColors.neutral900 : AppColors.white,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.white : AppColors.neutral900,
            ),
            onPressed: _onWillPop,
          ),
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary500,
                    ),
                  ),
                )
              : null,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.paymentUrl),
                headers: _headers,
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                transparentBackground: false,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
              ),
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() => _isLoading = true);
                }
                _checkUrl(url?.toString());
              },
              onLoadStop: (controller, url) {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
                _checkUrl(url?.toString());
              },
              onProgressChanged: (controller, progress) {
                if (mounted) {
                  setState(() {
                    _progress = progress / 100.0;
                    if (progress == 100) _isLoading = false;
                  });
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri != null) {
                  _checkUrl(uri.toString());
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (_isLoading && _progress < 0.1)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary500),
                    SizedBox(height: 16),
                    Text(
                      'Connecting to Payment Gateway...',
                      style: TextStyle(fontSize: 14, color: AppColors.neutral600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
