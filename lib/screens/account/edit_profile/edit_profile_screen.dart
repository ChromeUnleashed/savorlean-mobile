import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/address_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/address_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _cityCtrl;

  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _areaCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _areaCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _prefill(AsyncValue addressAsync) {
    if (_prefilled) return;
    if (addressAsync.isLoading) return;

    final address = addressAsync.asData?.value;
    _nameCtrl.text = address?.fullName ?? '';
    _phoneCtrl.text = address?.phone ?? '';
    _streetCtrl.text = address?.streetAddress ?? '';
    _areaCtrl.text = address?.area ?? '';
    _cityCtrl.text = address?.city ?? '';
    _prefilled = true;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await AddressService().saveDefaultAddress(
        userId: user.id,
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        streetAddress: _streetCtrl.text.trim(),
        area: _areaCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
      );
      ref.invalidate(defaultAddressProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile saved')));
        context.canPop() ? context.pop() : context.go('/account');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressAsync = ref.watch(defaultAddressProvider);
    _prefill(addressAsync);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/account'),
        ),
        title: Text('Edit Profile', style: AppTextStyles.headingBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FieldLabel('Full Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('e.g. Mohid Ahmed'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 24),
                _FieldLabel('Phone Number'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('e.g. +92 300 1234567'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: 32),
                Text(
                  'Default Delivery Address',
                  style: AppTextStyles.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pre-filled automatically at checkout.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 16),
                _FieldLabel('Street Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _streetCtrl,
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('e.g. House 12, Street 4'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Street address is required'
                      : null,
                ),
                const SizedBox(height: 24),
                _FieldLabel('Area'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _areaCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('e.g. DHA Phase 5'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Area is required'
                      : null,
                ),
                const SizedBox(height: 24),
                _FieldLabel('City'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cityCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('e.g. Lahore'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'City is required'
                      : null,
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: _saving ? 'Saving…' : 'Save Changes',
                  onPressed: _saving ? null : _save,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMuted,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.cta, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
