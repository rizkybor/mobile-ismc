import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Input teks dengan label di atas, pesan error, dan toggle lihat sandi.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.secure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.autofillHints,
    this.prefixIcon,
    this.semanticId,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool secure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;

  /// Accessibility identifier (Maestro E2E).
  final String? semanticId;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.secure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Semantics(
          identifier: widget.semanticId,
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscure,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onChanged: widget.onChanged,
            maxLines: widget.secure ? 1 : widget.maxLines,
            autofillHints: widget.autofillHints,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(widget.prefixIcon),
              suffixIcon: widget.secure
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
