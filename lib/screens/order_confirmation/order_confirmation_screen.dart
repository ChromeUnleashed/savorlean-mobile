import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/placed_order.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final PlacedOrder order;

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  Map<String, String> _siteSettings = {};

  @override
  void initState() {
    super.initState();
    if (widget.order.paymentMethod == 'bank_transfer') {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService(
      Supabase.instance.client,
    ).fetchSiteSettings();
    if (mounted) setState(() => _siteSettings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final isBankTransfer = widget.order.paymentMethod == 'bank_transfer';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.oliveSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 44,
                  color: AppColors.olive,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed!',
                style: AppTextStyles.headingSerif.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 12),
              Text(
                "We've received your order and will confirm it shortly.",
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Order summary box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Order ID',
                      value: widget.order.id.substring(0, 8).toUpperCase(),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Items',
                      value:
                          '${widget.order.itemCount} item${widget.order.itemCount > 1 ? 's' : ''}',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Total',
                      value: 'Rs. ${widget.order.totalPkr}',
                      bold: true,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Payment',
                      value: isBankTransfer
                          ? 'Bank Transfer'
                          : 'Cash on Delivery',
                    ),
                  ],
                ),
              ),

              // Bank transfer details — shown only when payment method is bank transfer
              if (isBankTransfer) ...[
                const SizedBox(height: 16),
                _BankTransferBox(settings: _siteSettings),
              ],

              const SizedBox(height: 40),
              AppButton(
                label: 'Continue Shopping',
                onPressed: () => context.go('/'),
                variant: AppButtonVariant.primary,
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'View Order History',
                onPressed: () => context.go('/account/orders'),
                variant: AppButtonVariant.secondary,
                fullWidth: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankTransferBox extends StatelessWidget {
  const _BankTransferBox({required this.settings});

  final Map<String, String> settings;

  @override
  Widget build(BuildContext context) {
    final bankName = settings['bank_name'];
    final accountTitle =
        settings['account_title'] ?? settings['bank_account_title'];
    final accountNo =
        settings['account_number'] ?? settings['bank_account_number'];
    final iban = settings['iban'];
    final whatsapp = settings['whatsapp_number'] ?? settings['whatsapp'];

    final hasDetails =
        bankName != null ||
        accountTitle != null ||
        accountNo != null ||
        iban != null;

    final instruction = whatsapp != null
        ? 'Please send a screenshot of your transfer confirmation to our WhatsApp at $whatsapp. Your order will be processed once payment is verified.'
        : 'Please send a screenshot of your transfer confirmation to our WhatsApp. Your order will be processed once payment is verified.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.oliveSoft,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.olive.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 16,
                color: AppColors.olive,
              ),
              const SizedBox(width: 8),
              Text(
                'Bank Transfer Instructions',
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.olive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            instruction,
            style: AppTextStyles.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          if (hasDetails) ...[
            const SizedBox(height: 12),
            if (bankName != null) _InfoLine(label: 'Bank', value: bankName),
            if (accountTitle != null)
              _InfoLine(label: 'Account Title', value: accountTitle),
            if (accountNo != null)
              _InfoLine(label: 'Account No.', value: accountNo),
            if (iban != null) _InfoLine(label: 'IBAN', value: iban),
          ] else if (settings.isEmpty) ...[
            // Settings are still loading
            const SizedBox(height: 8),
            const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        Text(
          value,
          style: AppTextStyles.inter(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
