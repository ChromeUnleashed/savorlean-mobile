import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';
import '../../services/order_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

const _timeWindows = [
  'Morning (9am – 12pm)',
  'Afternoon (12pm – 4pm)',
  'Evening (4pm – 8pm)',
];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _startDateController = TextEditingController();

  String _paymentMethod = 'cod';
  String? _timeWindow;
  bool _isPlacing = false;
  String? _error;
  bool _saveInfo = false;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _instructionsController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _prefillFromProfile() async {
    try {
      final address = await ref.read(defaultAddressProvider.future);
      if (address != null && mounted) {
        _nameController.text = address.fullName;
        _phoneController.text = address.phone;
        _streetController.text = address.streetAddress;
        _areaController.text = address.area;
        _cityController.text = address.city;
      }
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.olive),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _startDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPlacing = true;
      _error = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser!;
      final items = ref.read(cartProvider);
      final subtotal = ref.read(cartSubtotalProvider);
      final discount = ref.read(cartDiscountProvider);
      final total = ref.read(cartTotalProvider);

      final order = await OrderService(Supabase.instance.client).placeOrder(
        email: user.email!,
        userId: user.id,
        items: items,
        subtotalPkr: subtotal,
        discountPkr: discount,
        totalPkr: total,
        paymentMethod: _paymentMethod,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        streetAddress: _streetController.text.trim(),
        areaZone: _areaController.text.trim(),
        city: _cityController.text.trim(),
        mealInstructions: _instructionsController.text.trim(),
        preferredStartDate: _startDateController.text.trim(),
        timeWindow: _timeWindow,
      );

      ref.read(cartProvider.notifier).clear();
      ref.read(appliedPromoProvider.notifier).clear();

      if (_saveInfo) {
        try {
          await AddressService().saveDefaultAddress(
            userId: user.id,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            streetAddress: _streetController.text.trim(),
            area: _areaController.text.trim(),
            city: _cityController.text.trim(),
          );
          ref.invalidate(defaultAddressProvider);
        } catch (_) {
          // Non-critical — order is placed, address save failure is silently ignored.
        }
      }

      if (mounted) {
        context.go('/checkout/confirmation', extra: order);
      }
    } catch (_) {
      setState(() => _error = 'Could not place order. Please try again.');
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(cartDiscountProvider);
    final total = ref.watch(cartTotalProvider);
    final appliedPromo = ref.watch(appliedPromoProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          'Checkout',
          style: AppTextStyles.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // Delivery details
            _SectionHeading('Delivery Details'),
            const SizedBox(height: 12),
            _Field(
              controller: _nameController,
              label: 'Full name',
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _phoneController,
              label: 'Phone number',
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _streetController,
              label: 'Street address',
              textCapitalization: TextCapitalization.sentences,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _areaController,
              label: 'Area / zone',
              textCapitalization: TextCapitalization.words,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _cityController,
              label: 'City',
              textCapitalization: TextCapitalization.words,
              validator: _required,
            ),
            const SizedBox(height: 12),
            // Save-info checkbox
            InkWell(
              onTap: () => setState(() => _saveInfo = !_saveInfo),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _saveInfo,
                        onChanged: (v) =>
                            setState(() => _saveInfo = v ?? false),
                        activeColor: AppColors.olive,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Save my details for faster checkout next time',
                        style: AppTextStyles.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Schedule preferences (optional)
            _SectionHeading('Schedule Preferences'),
            const SizedBox(height: 4),
            Text('Optional', style: AppTextStyles.bodyMuted),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startDateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _inputDecoration('Preferred start date'),
            ),
            const SizedBox(height: 12),
            DropdownMenu<String>(
              initialSelection: _timeWindow,
              label: const Text('Delivery time window'),
              onSelected: (v) => setState(() => _timeWindow = v),
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: _timeWindows
                  .map((w) => DropdownMenuEntry(value: w, label: w))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Meal instructions (optional)
            _SectionHeading('Meal Instructions'),
            const SizedBox(height: 4),
            Text(
              'Allergies, preferences, etc.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instructionsController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration('e.g. No nuts, extra spicy'),
            ),
            const SizedBox(height: 24),

            // Payment method
            _SectionHeading('Payment Method'),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'cod',
                    title: Text(
                      'Cash on Delivery',
                      style: AppTextStyles.inter(fontSize: 14),
                    ),
                    activeColor: AppColors.olive,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  RadioListTile<String>(
                    value: 'bank_transfer',
                    title: Text(
                      'Bank Transfer',
                      style: AppTextStyles.inter(fontSize: 14),
                    ),
                    activeColor: AppColors.olive,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order summary
            _SectionHeading('Order Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: [
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name}${item.quantity > 1 ? ' ×${item.quantity}' : ''}',
                              style: AppTextStyles.inter(fontSize: 13),
                            ),
                          ),
                          Text(
                            'Rs. ${item.lineTotalPkr}',
                            style: AppTextStyles.inter(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: AppColors.border, height: 20),
                  _SummaryRow('Subtotal', 'Rs. $subtotal'),
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    _SummaryRow(
                      appliedPromo != null
                          ? 'Discount (${appliedPromo.code})'
                          : 'Discount',
                      '− Rs. $discount',
                      valueColor: AppColors.success,
                    ),
                  ],
                  const SizedBox(height: 4),
                  const _SummaryRow('Delivery', 'Free'),
                  Divider(color: AppColors.border, height: 16),
                  _SummaryRow('Total', 'Rs. $total', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_error != null) ...[
              Text(
                _error!,
                style: AppTextStyles.inter(
                  fontSize: 13,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            AppButton(
              label: 'Place Order — Rs. $total',
              onPressed: _isPlacing ? null : _placeOrder,
              isLoading: _isPlacing,
              variant: AppButtonVariant.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  InputDecoration _inputDecoration(String? label) => InputDecoration(
    labelText: label,
    hintText: label,
    hintStyle: AppTextStyles.bodyMuted,
    labelStyle: AppTextStyles.bodyMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: const BorderSide(color: AppColors.olive),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.olive),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.value, {
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.inter(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: valueColor != null ? style.copyWith(color: valueColor) : style,
        ),
      ],
    );
  }
}
