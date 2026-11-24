import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/config/contacts.dart';
import '../../../core/config/env.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/i18n/supported_locales.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/users_repository.dart';
import '../../../domain/photo.dart';
import '../../../shared/widgets/widgets.dart';
import '../../activation/account_status_provider.dart';
import '../../auth/session_controller.dart';
import '../../debug/debug_fab.dart';
import '../../onboarding/onboarding_controller.dart';
import '../widgets/user_avatar.dart';

/// Profil (PRD F-07): akun & perusahaan (baca saja), foto, password,
/// bahasa, privasi, kontak, versi, hapus akun, keluar.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _savingPhoto = false;

  Future<void> _changePhoto() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profilePhotoCamera),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profilePhotoGallery),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null || !mounted) return;
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    setState(() => _savingPhoto = true);
    try {
      final dataUrl = PhotoRules.toProfileDataUrl(await picked.readAsBytes());
      await ref
          .read(usersRepositoryProvider)
          .updatePhoto(
            username: user.username,
            photoDataUrl: dataUrl,
            updatedBy: user.name,
          );
      ref.read(sessionProvider.notifier).setPhoto(dataUrl);
      _snack(l10n.profilePhotoSaved);
    } on PhotoTooLargeException {
      _snack(l10n.profilePhotoTooLarge);
    } on Object {
      _snack(l10n.profilePhotoFailed);
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickLanguage() async {
    final l10n = context.l10n;
    final current = ref.read(localeProvider);
    final chosen = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                l10n.languageSheetTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            RadioGroup<Locale>(
              groupValue: current,
              onChanged: (v) => Navigator.of(ctx).pop(v),
              child: Column(
                children: [
                  RadioListTile<Locale>(
                    value: SupportedLocales.id,
                    title: Text(l10n.languageIndonesian),
                  ),
                  RadioListTile<Locale>(
                    value: SupportedLocales.en,
                    title: Text(l10n.languageEnglish),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (chosen != null) {
      await ref.read(localeProvider.notifier).setLocale(chosen);
    }
  }

  Future<void> _confirmSignOut() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.signOutButton),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider).user;
    final customer = ref.watch(accountStatusProvider).value?.customer;
    final locale = ref.watch(localeProvider);

    return AppScaffold.brand(
      title: l10n.profileTitle,
      subtitle: l10n.profileSubtitle,
      floatingActionButton: const DebugFab(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl * 4),
        children: [
          if (user != null)
            AppCard(
              child: Row(
                children: [
                  Stack(
                    children: [
                      UserAvatar(
                        name: user.name,
                        photoUrl: user.photoUrl,
                        radius: 32,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _savingPhoto ? null : _changePhoto,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: _savingPhoto
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: AppLoader(
                                        size: 4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.photo_camera_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: t.titleMedium),
                        const SizedBox(height: 2),
                        Text(user.email, style: t.bodySmall),
                        Text(
                          '@${user.username} · ${l10n.profileRole}', // l10n-ignore: username + label
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: l10n.profileCompanySection,
            children: [
              if (customer == null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(l10n.profileCompanyEmpty, style: t.bodySmall),
                )
              else ...[
                _InfoRow(
                  label: l10n.profileCompanyName,
                  value: customer.customerName,
                ),
                _InfoRow(
                  label: l10n.profileCompanyPhone,
                  value: customer.phone,
                ),
                _InfoRow(label: l10n.profileCompanyTelp, value: customer.telp),
                _InfoRow(
                  label: l10n.profileCompanyAddress,
                  value: customer.address,
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(l10n.profileCompanyNote, style: t.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: l10n.profileSettingsSection,
            children: [
              _MenuTile(
                icon: Icons.translate_rounded,
                title: l10n.profileLanguage,
                trailingText: locale == SupportedLocales.en
                    ? l10n.languageEnglish
                    : l10n.languageIndonesian,
                onTap: _pickLanguage,
              ),
              _MenuTile(
                icon: Icons.lock_reset_rounded,
                title: l10n.profileChangePassword,
                onTap: () => context.push(Routes.changePassword),
              ),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                title: l10n.profileGuide,
                onTap: () {
                  ref.read(onboardingProvider.notifier).reopen();
                  context.go(Routes.home);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: l10n.profileAboutSection,
            children: [
              _MenuTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.profilePrivacy,
                onTap: () => unawaited(
                  launchUrl(
                    Uri.parse(
                      Env.privacyPolicyUrl.isEmpty
                          ? IsmContacts.website
                          : Env.privacyPolicyUrl,
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
              _MenuTile(
                icon: Icons.support_agent_rounded,
                title: l10n.profileContact,
                trailingText: IsmContacts.phoneDisplay,
                onTap: () => unawaited(
                  launchUrl(
                    Uri.parse(IsmContacts.whatsappUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
              const _VersionTile(),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.signOutButton,
            variant: AppButtonVariant.outline,
            icon: Icons.logout_rounded,
            onPressed: _confirmSignOut,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.profileDeleteAccount,
            variant: AppButtonVariant.text,
            icon: Icons.delete_outline_rounded,
            onPressed: () => context.push(Routes.deleteAccount),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(title, style: Theme.of(context).textTheme.labelMedium),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: t.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: t.bodyMedium,
            ), // l10n-ignore
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailingText,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText!,
              style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) => ListTile(
        leading: const Icon(
          Icons.info_outline_rounded,
          color: AppColors.primary,
        ),
        title: Text(
          l10n.profileVersion,
          style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          snap.hasData
              ? l10n.profileVersionValue(
                  snap.data!.version,
                  snap.data!.buildNumber,
                )
              : '',
          style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
