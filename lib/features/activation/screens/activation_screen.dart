import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/customers_repository.dart';
import '../../../domain/account_status.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/session_controller.dart';

/// F-02.2 Lengkapi data perusahaan → dokumen `customers` baru (menunggu
/// verifikasi admin) + notifikasi ke tim ISM.
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _form = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _phone = TextEditingController();
  final _telp = TextEditingController();
  final _address = TextEditingController();
  bool _isCompany = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_company, _phone, _telp, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(customersRepositoryProvider);
    try {
      if (await repo.hasAnyCustomer(user.email)) {
        setState(() => _error = l10n.activationAlreadyExists);
        return;
      }
      final customerName = _isCompany ? _company.text.trim() : user.name.trim();
      await repo.createActivation(
        email: user.email,
        customerName: customerName,
        isCompany: _isCompany,
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        telp: _telp.text.trim(),
      );
      // Gagal mengirim notifikasi tidak membatalkan aktivasi.
      await repo
          .notifyPanelActivationRequested(
            customerName: customerName,
            createdByName: user.name,
            uid: user.uid,
          )
          .catchError((_) {});
      if (mounted) context.pop();
    } on Object {
      if (mounted) setState(() => _error = l10n.activationFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: l10n.activationTitle,
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.activationFormTitle, style: t.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.activationFormSubtitle,
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.fieldCustomerType,
                style: t.labelLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.customerTypeCompany),
                    icon: const Icon(Icons.business_outlined),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.customerTypeIndividual),
                    icon: const Icon(Icons.person_outline_rounded),
                  ),
                ],
                selected: {_isCompany},
                onSelectionChanged: (s) => setState(() => _isCompany = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_isCompany) ...[
                AppTextField(
                  label: l10n.fieldCompanyName,
                  controller: _company,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.apartment_outlined,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? l10n.validationRequired : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                label: l10n.fieldPhone,
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.smartphone_outlined,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return l10n.validationRequired;
                  if (!AccountStatusRules.validatePhone(s)) {
                    return l10n.validationPhoneDigits;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldTelp,
                hint: l10n.fieldOptional,
                controller: _telp,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.fieldAddress,
                controller: _address,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                prefixIcon: Icons.location_on_outlined,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                InlineMessage(text: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton(
                label: l10n.activationSubmit,
                loading: _saving,
                onPressed: _submit,
                icon: Icons.send_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.activationFooter,
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
