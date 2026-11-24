import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/contacts.dart';
import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';

/// Kredit satu baris, kecil: © tahun PT Indo Safety Marine · Developed by JCD.
class CreditsFooter extends StatelessWidget {
  const CreditsFooter({super.key, this.onDark = false});
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = onDark
        ? Colors.white.withValues(alpha: 0.65)
        : AppColors.textMuted;
    final style = TextStyle(fontSize: 10, height: 1.2, color: color);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.creditCopyright(IsmContacts.copyrightYear), style: style),
          Text(' · ', style: style), // l10n-ignore: pemisah
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => launchUrl(
              Uri.parse(IsmContacts.developerUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              l10n.creditDevelopedBy(IsmContacts.developerName),
              style: style.copyWith(
                fontWeight: FontWeight.w600,
                color: onDark ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
