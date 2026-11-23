import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'brand_header.dart';
import 'offline_banner.dart';

/// Scaffold standar.
///
/// - [AppScaffold] biasa: AppBar putih bergaris tipis (layar sekunder).
/// - [AppScaffold.brand]: header gradien [BrandHeader] untuk layar tab.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.showAppBar = true,
    this.floatingActionButton,
  }) : subtitle = null,
       headerTrailing = null,
       headerBottom = null,
       _brand = false;

  const AppScaffold.brand({
    super.key,
    required this.body,
    required String this.title,
    this.subtitle,
    this.headerTrailing,
    this.headerBottom,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.floatingActionButton,
  }) : actions = null,
       showAppBar = false,
       _brand = true;

  final Widget body;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? headerTrailing;
  final Widget? headerBottom;
  final EdgeInsetsGeometry padding;
  final bool showAppBar;
  final Widget? floatingActionButton;
  final bool _brand;

  @override
  Widget build(BuildContext context) {
    if (_brand) {
      return Scaffold(
        floatingActionButton: floatingActionButton,
        body: Column(
          children: [
            BrandHeader(
              title: title!,
              subtitle: subtitle,
              trailing: headerTrailing,
              bottom: headerBottom,
            ),
            const OfflineBanner(),
            Expanded(
              child: Padding(
                padding: headerBottom == null
                    ? padding
                    : padding.add(const EdgeInsets.only(top: 40)),
                child: body,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: title == null ? null : Text(title!), actions: actions)
          : null,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: !showAppBar,
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Padding(padding: padding, child: body),
            ),
          ],
        ),
      ),
    );
  }
}
