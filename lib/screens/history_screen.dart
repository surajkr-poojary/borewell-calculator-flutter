import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/report_record.dart';
import '../services/pdf_export_service.dart';
import '../services/report_history_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/responsive_center.dart';
import 'phone_sign_in_view.dart';

/// Lists previously generated bills (saved automatically whenever a PDF is
/// shared or downloaded), pulled live from Firestore. Each entry can be
/// re-shared, re-downloaded, or deleted. Shows [PhoneSignInView] instead
/// until the user signs in with their phone number.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = ReportHistoryService.instance;
  String? _busyId;

  Future<void> _share(ReportRecord record, AppLocalizations l10n) async {
    setState(() => _busyId = record.id);
    try {
      await sharePdfBytes(record.pdfBytes, _fileName(record), l10n.pdfTitle);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _download(ReportRecord record, AppLocalizations l10n) async {
    setState(() => _busyId = record.id);
    try {
      final path = await downloadPdfBytes(record.pdfBytes, _fileName(record));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfSaved),
          action: SnackBarAction(
            label: l10n.open,
            onPressed: () => openSavedFile(path),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.downloadFailed)));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _delete(ReportRecord record, AppLocalizations l10n) async {
    if (record.id == null) return;
    await _service.deleteReport(record.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.historyDeleted)));
  }

  String _fileName(ReportRecord record) {
    final name = record.clientName?.trim() ?? '';
    final safeName = name.isEmpty
        ? 'borewell_bill'
        : 'borewell_bill_${name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}';
    return '$safeName.pdf';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          StreamBuilder<User?>(
            stream: _service.authState,
            builder: (context, snapshot) {
              if (snapshot.data == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: l10n.signOutTooltip,
                onPressed: _service.signOut,
              );
            },
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: StreamBuilder<User?>(
          stream: _service.authState,
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (authSnapshot.data == null) {
              return const Center(child: PhoneSignInView());
            }
            return _ReportList(
              service: _service,
              busyId: _busyId,
              onShare: (r) => _share(r, l10n),
              onDownload: (r) => _download(r, l10n),
              onDelete: (r) => _delete(r, l10n),
            );
          },
        ),
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  final ReportHistoryService service;
  final String? busyId;
  final ValueChanged<ReportRecord> onShare;
  final ValueChanged<ReportRecord> onDownload;
  final ValueChanged<ReportRecord> onDelete;

  const _ReportList({
    required this.service,
    required this.busyId,
    required this.onShare,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return StreamBuilder<List<ReportRecord>>(
      stream: service.streamReports(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.historyEmpty,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.historyEmptySubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final record = reports[index];
            final isBusy = busyId == record.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.clientName?.trim().isNotEmpty == true
                                ? record.clientName!.trim()
                                : l10n.walkInClient,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(record.totalAmount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(record.createdAt)} · ${record.totalDepth} ${l10n.feetUnit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: l10n.historyDeleteTooltip,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: isBusy ? null : () => onDelete(record),
                        ),
                        IconButton(
                          tooltip: l10n.share,
                          icon: const Icon(Icons.share_outlined),
                          onPressed: isBusy ? null : () => onShare(record),
                        ),
                        IconButton(
                          tooltip: l10n.downloadPdf,
                          icon: isBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download_outlined),
                          onPressed: isBusy ? null : () => onDownload(record),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
