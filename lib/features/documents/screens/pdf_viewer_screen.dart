import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/contacts.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/documents_repository.dart';
import '../../../domain/pdf_assembler.dart';
import '../../../shared/widgets/widgets.dart';
import '../document_ui.dart';

/// Pratinjau PDF (PRD F-05.2–F-05.3): unduh dengan progres, pratinjau di
/// aplikasi, bagikan/simpan dengan nama file asli.
class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({super.key, required this.request});
  final PdfViewRequest request;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  File? _file;
  PdfControllerPinch? _controller;
  Object? _error;
  int _done = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _file = null;
      _done = 0;
      _total = 0;
    });
    try {
      final file = await ref
          .read(documentsRepositoryProvider)
          .fetchPdf(
            widget.request.document,
            onProgress: (d, t) {
              if (mounted) {
                setState(() {
                  _done = d;
                  _total = t;
                });
              }
            },
          );
      final bytes = await file.readAsBytes();
      if (!PdfAssembler.looksLikePdf(bytes)) {
        await file.delete();
        throw const PdfIncompleteException(0, 0);
      }
      _controller?.dispose();
      _controller = PdfControllerPinch(document: PdfDocument.openData(bytes));
      if (mounted) setState(() => _file = file);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final f = _file;
    if (f == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            f.path,
            name: widget.request.document.fileName,
            mimeType: 'application/pdf',
          ),
        ],
        subject: widget.request.document.fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: widget.request.title,
      padding: EdgeInsets.zero,
      actions: [
        if (_file != null)
          IconButton(
            tooltip: l10n.docShare,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _share,
          ),
      ],
      body: _error != null
          ? _buildError(l10n)
          : _controller == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLoader(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.docDownloading, style: t.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: 220,
                      child: LinearProgressIndicator(
                        value: _total == 0 ? null : _done / _total,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    if (_total > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.docProgress(_done, _total),
                          style: t.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: AppColors.border,
                    child: PdfViewPinch(controller: _controller!),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      label: l10n.docShare,
                      icon: Icons.ios_share_rounded,
                      onPressed: _share,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    if (_error is PdfLegacyException) {
      return EmptyState(
        icon: Icons.history_rounded,
        title: l10n.docLegacyTitle,
        message: l10n.docLegacyBody,
        actionLabel: l10n.docOpenPortal,
        onAction: () => launchUrl(
          Uri.parse(IsmContacts.website),
          mode: LaunchMode.externalApplication,
        ),
      );
    }
    final incomplete = _error is PdfIncompleteException;
    return ErrorState(
      title: incomplete ? l10n.docIncompleteTitle : null,
      message: incomplete ? l10n.docIncompleteBody : l10n.docErrorBody,
      onRetry: _load,
    );
  }
}
