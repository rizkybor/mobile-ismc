import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/photo.dart';

/// Avatar: foto dari data URL / http, atau inisial nama.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.radius = 28,
  });

  final String name;
  final String photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bytes = PhotoRules.bytesFromDataUrl(photoUrl);
    ImageProvider? image;
    if (bytes != null) {
      image = MemoryImage(bytes);
    } else if (photoUrl.startsWith('http')) {
      image = NetworkImage(photoUrl);
    }
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim()[0].toUpperCase(); // l10n-ignore
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      foregroundImage: image,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
