import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';
import '../../services/order_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

const _timeWindows = [
  'Morning (9am – 12pm)',
  'Afternoon (12pm – 4pm)',
  'Evening (4pm – 8pm)',
];

const _lahoreAreas = [
  'DHA (All Phases)',
  'Gulberg',
  'Model Town',
  'Johar Town',
  'Bahria Town',
  'Cantt',
];

// Shared menu style used by both dropdowns — surface (cream) background, app border, no elevation tint.
const _menuStyle = MenuStyle(
  backgroundColor: WidgetStatePropertyAll(AppColors.surface),
  surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  elevation: WidgetStatePropertyAll(3),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      side: BorderSide(color: AppColors.border),
    ),
  ),
);

// ---------------------------------------------------------------------------
// Checkout form draft — persists form values across back/forward navigation.
// Uses a plain StateProvider (no build_runner needed) marked keepAlive so it
// survives when the CheckoutScreen widget is disposed.
// ---------------------------------------------------------------------------

class _CheckoutDraft {
  const _CheckoutDraft({
    required this.email,
    required this.name,
    required this.phone,
    required this.street,
    this.area,
    required this.city,
    required this.instructions,
    required this.startDate,
    this.timeWindow,
    required this.paymentMethod,
    required this.saveInfo,
  });

  final String email;
  final String name;
  final String phone;
  final String street;
  final String? area;
  final String city;
  final String instructions;
  final String startDate;
  final String? timeWindow;
  final String paymentMethod;
  final bool saveInfo;
}

class _CheckoutDraftNotifier extends Notifier<_CheckoutDraft?> {
  @override
  _CheckoutDraft? build() => null;

  void save(_CheckoutDraft draft) => state = draft;
  void clear() => state = null;
}

final _checkoutDraftProvider =
    NotifierProvider<_CheckoutDraftNotifier, _CheckoutDraft?>(
      _CheckoutDraftNotifier.new,
    );

// ---------------------------------------------------------------------------

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _startDateController = TextEditingController();

  // Area and city are tracked in state (DropdownMenu is uncontrolled).
  String? _selectedArea;
  String _selectedCity = 'Lahore';
  String? _areaError;

  String _paymentMethod = 'cod';
  String? _timeWindow;
  bool _isPlacing = false;
  String? _error;
  bool _saveInfo = false;

  // Set to true after a successful order so dispose() does not re-save the draft.
  bool _orderPlaced = false;

  Map<String, String> _siteSettings = {};

  @override
  void initState() {
    super.initState();
    _restoreFromDraft();
    // Profile prefill and schedule defaults only run when there is no saved
    // draft — the draft takes precedence over every default value.
    if (ref.read(_checkoutDraftProvider) == null) {
      _prefillFromProfile();
      // Default start date: tomorrow
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _startDateController.text =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      // Default time window: Morning
      _timeWindow = _timeWindows.first;
    }
    // Attach listeners so the draft is saved on every keystroke — this is
    // more reliable than saving in dispose() because Riverpod's ref can be
    // invalidated before ConsumerState.dispose() runs on some versions.
    _emailController.addListener(_saveDraft);
    _nameController.addListener(_saveDraft);
    _phoneController.addListener(_saveDraft);
    _streetController.addListener(_saveDraft);
    _instructionsController.addListener(_saveDraft);
    _startDateController.addListener(_saveDraft);
  }

  void _restoreFromDraft() {
    final draft = ref.read(_checkoutDraftProvider);
    if (draft == null) return;
    _emailController.text = draft.email;
    _nameController.text = draft.name;
    _phoneController.text = draft.phone;
    _streetController.text = draft.street;
    _selectedArea = draft.area;
    _selectedCity = draft.city;
    _instructionsController.text = draft.instructions;
    _startDateController.text = draft.startDate;
    _timeWindow = draft.timeWindow;
    _paymentMethod = draft.paymentMethod;
    _saveInfo = draft.saveInfo;
  }

  // Persist current form state to the provider so it survives back-navigation.
  // Called on every text change and every dropdown/radio/checkbox interaction.
  void _saveDraft() {
    if (_orderPlaced) return;
    ref
        .read(_checkoutDraftProvider.notifier)
        .save(
          _CheckoutDraft(
            email: _emailController.text,
            name: _nameController.text,
            phone: _phoneController.text,
            street: _streetController.text,
            area: _selectedArea,
            city: _selectedCity,
            instructions: _instructionsController.text,
            startDate: _startDateController.text,
            timeWindow: _timeWindow,
            paymentMethod: _paymentMethod,
            saveInfo: _saveInfo,
          ),
        );
  }

  @override
  void dispose() {
    _emailController.removeListener(_saveDraft);
    _nameController.removeListener(_saveDraft);
    _phoneController.removeListener(_saveDraft);
    _streetController.removeListener(_saveDraft);
    _instructionsController.removeListener(_saveDraft);
    _startDateController.removeListener(_saveDraft);
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
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
        if (_lahoreAreas.contains(address.area)) {
          setState(() => _selectedArea = address.area);
        }
      }
    } catch (_) {}
  }

  Future<void> _maybeLoadSettings() async {
    if (_siteSettings.isNotEmpty) return;
    try {
      final settings = await SettingsService(
        Supabase.instance.client,
      ).fetchSiteSettings();
      if (mounted) setState(() => _siteSettings = settings);
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
    // Validate the manual dropdown before running Form.validate so all
    // errors appear at once.
    final areaOk = _selectedArea != null;
    setState(() => _areaError = areaOk ? null : 'Please select your area');

    if (!_formKey.currentState!.validate() || !areaOk) return;

    setState(() {
      _isPlacing = true;
      _error = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? _emailController.text.trim();
      final userId = user?.id;

      final items = ref.read(cartProvider);
      final subtotal = ref.read(cartSubtotalProvider);
      final discount = ref.read(cartDiscountProvider);
      final total = ref.read(cartTotalProvider);

      final order = await OrderService(Supabase.instance.client).placeOrder(
        email: email,
        userId: userId,
        items: items,
        subtotalPkr: subtotal,
        discountPkr: discount,
        totalPkr: total,
        paymentMethod: _paymentMethod,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        streetAddress: _streetController.text.trim(),
        areaZone: _selectedArea!,
        city: _selectedCity,
        mealInstructions: _instructionsController.text.trim(),
        preferredStartDate: _startDateController.text.trim(),
        timeWindow: _timeWindow,
      );

      ref.read(cartProvider.notifier).clear();
      ref.read(appliedPromoProvider.notifier).clear();

      if (_saveInfo && userId != null) {
        try {
          await AddressService().saveDefaultAddress(
            userId: userId,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            streetAddress: _streetController.text.trim(),
            area: _selectedArea!,
            city: _selectedCity,
          );
          ref.invalidate(defaultAddressProvider);
        } catch (_) {}
      }

      // Clear the draft and mark as placed so dispose() doesn't re-save it.
      _orderPlaced = true;
      ref.read(_checkoutDraftProvider.notifier).clear();

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        context.go('/checkout/confirmation', extra: order);
        // Do NOT call setState here or in finally — the widget is being
        // disposed by the navigation. Calling setState after context.go()
        // marks the element dirty; go_router then disposes it before Flutter
        // can process the rebuild, causing a defunct-element assertion.
        return;
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _error = 'Could not place order. Please try again.';
          _isPlacing = false;
        });
      }
    }
    // Only reached on error paths where we stayed on this screen.
    if (context.mounted) setState(() => _isPlacing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isGuest = user == null;

    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(cartDiscountProvider);
    final total = ref.watch(cartTotalProvider);
    final appliedPromo = ref.watch(appliedPromoProvider);

    // Shared decoration theme used by both DropdownMenu widgets so their
    // text fields look identical to the regular _Field inputs.
    final dropdownDecoration = InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          'Checkout',
          style: AppTextStyles.inter(fontWeight: FontWeight.w700),
        ),
      ),
      // SingleChildScrollView + Column keeps ALL form fields in the widget tree
      // at all times. Using ListView here would lazily discard off-screen
      // TextFormFields, unregistering them from FormState so they are silently
      // skipped by validate() — allowing empty required fields to pass.
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email — only for guest users
              if (isGuest) ...[
                _SectionHeading('Contact'),
                const SizedBox(height: 12),
                _Field(
                  controller: _emailController,
                  label: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  isRequired: true,
                ),
                const SizedBox(height: 24),
              ],

              // Delivery details
              _SectionHeading('Delivery Details'),
              const SizedBox(height: 12),
              _Field(
                controller: _nameController,
                label: 'Full name',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: _required,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _phoneController,
                label: 'Phone number',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _streetController,
                label: 'Street address',
                textCapitalization: TextCapitalization.sentences,
                validator: _required,
                isRequired: true,
              ),
              const SizedBox(height: 12),

              // Area — DropdownMenu opens as an anchored panel below the field.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownMenu<String>(
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: _selectedArea,
                    enableFilter: false,
                    requestFocusOnTap: false,
                    label: const _RequiredLabel('Area / zone'),
                    textStyle: AppTextStyles.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    menuStyle: _menuStyle,
                    inputDecorationTheme: dropdownDecoration.copyWith(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(
                          color: _areaError != null
                              ? AppColors.error
                              : AppColors.border,
                        ),
                      ),
                    ),
                    dropdownMenuEntries: _lahoreAreas
                        .map(
                          (a) => DropdownMenuEntry<String>(
                            value: a,
                            label: a,
                            style: ButtonStyle(
                              textStyle: WidgetStatePropertyAll(
                                AppTextStyles.inter(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onSelected: (v) {
                      setState(() {
                        _selectedArea = v;
                        if (v != null) _areaError = null;
                      });
                      _saveDraft();
                    },
                  ),
                  if (_areaError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        _areaError!,
                        style: AppTextStyles.inter(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // City — only Lahore; shown as a non-editable dropdown.
              DropdownMenu<String>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: _selectedCity,
                enableFilter: false,
                requestFocusOnTap: false,
                label: Text('City', style: AppTextStyles.bodyMuted),
                textStyle: AppTextStyles.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                menuStyle: _menuStyle,
                inputDecorationTheme: dropdownDecoration,
                dropdownMenuEntries: ['Lahore']
                    .map(
                      (c) => DropdownMenuEntry<String>(
                        value: c,
                        label: c,
                        style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(
                            AppTextStyles.inter(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onSelected: (v) {
                  if (v != null) setState(() => _selectedCity = v);
                  _saveDraft();
                },
              ),
              const SizedBox(height: 12),

              // Save-info checkbox — only for logged-in users
              if (!isGuest)
                InkWell(
                  onTap: () {
                    setState(() => _saveInfo = !_saveInfo);
                    _saveDraft();
                  },
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
                            onChanged: (v) {
                              setState(() => _saveInfo = v ?? false);
                              _saveDraft();
                            },
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
                onSelected: (v) {
                  setState(() => _timeWindow = v);
                  _saveDraft();
                },
                expandedInsets: EdgeInsets.zero,
                menuStyle: _menuStyle,
                inputDecorationTheme: dropdownDecoration,
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
                onChanged: (v) {
                  setState(() => _paymentMethod = v!);
                  if (v == 'bank_transfer') _maybeLoadSettings();
                  _saveDraft();
                },
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

              if (_paymentMethod == 'bank_transfer') ...[
                const SizedBox(height: 4),
                _BankTransferBox(settings: _siteSettings),
              ],
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
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(\+92|0)[0-9]{10}$').hasMatch(digits)) {
      return 'Enter a valid phone number (e.g. 03001234567)';
    }
    return null;
  }

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
        ? 'Transfer the total amount and send a screenshot to our WhatsApp at $whatsapp. Your order will be confirmed once payment is verified.'
        : 'Transfer the total amount and send a screenshot of your transfer to our WhatsApp. Your order will be confirmed once payment is verified.';

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
                'Bank Transfer Details',
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.olive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasDetails) ...[
            if (bankName != null) _InfoLine(label: 'Bank', value: bankName),
            if (accountTitle != null)
              _InfoLine(label: 'Account Title', value: accountTitle),
            if (accountNo != null)
              _InfoLine(label: 'Account No.', value: accountNo),
            if (iban != null) _InfoLine(label: 'IBAN', value: iban),
            const SizedBox(height: 10),
          ] else if (settings.isEmpty) ...[
            const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            instruction,
            style: AppTextStyles.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        label: isRequired ? _RequiredLabel(label) : null,
        labelText: isRequired ? null : label,
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

// Label with a red asterisk — used for required form fields.
class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTextStyles.bodyMuted,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
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
