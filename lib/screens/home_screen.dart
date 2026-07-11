import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/company_info.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/drilling_rate_band.dart';
import '../providers/bill_provider.dart';
import '../services/pdf_export_service.dart';
import '../services/pdf_service.dart';
import '../services/report_history_service.dart';
import '../widgets/depth_input_card.dart';
import '../widgets/language_switcher.dart';
import '../widgets/large_button.dart';
import '../widgets/rate_picker_field.dart';
import '../widgets/responsive_center.dart';
import '../widgets/result_card.dart';
import '../widgets/theme_switcher.dart';
import '../widgets/wave_app_bar_bottom.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _depthController = TextEditingController();
  final _casingFeetController = TextEditingController();
  final _resultKey = GlobalKey();

  bool _billForClient = false;
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientAddressController = TextEditingController();
  String? _clientNameError;
  bool _isSharing = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BillProvider>();
    if (!provider.isLoaded) {
      provider.loadDefaults();
    }
  }

  @override
  void dispose() {
    _depthController.dispose();
    _casingFeetController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    super.dispose();
  }

  bool get _isExporting => _isSharing || _isDownloading;

  String? _depthErrorText(AppLocalizations l10n, DepthError? error) {
    switch (error) {
      case DepthError.empty:
        return l10n.depthErrorEmpty;
      case DepthError.invalid:
        return l10n.depthErrorInvalid;
      case DepthError.casingEmpty:
      case DepthError.invalidCasing:
      case DepthError.missingCasingRate:
      case null:
        return null;
    }
  }

  String? _casingErrorText(AppLocalizations l10n, DepthError? error) {
    switch (error) {
      case DepthError.casingEmpty:
        return l10n.depthErrorCasingEmpty;
      case DepthError.invalidCasing:
        return l10n.depthErrorInvalidCasing;
      case DepthError.missingCasingRate:
        return l10n.depthErrorMissingCasingRate;
      case DepthError.empty:
      case DepthError.invalid:
      case null:
        return null;
    }
  }

  void _onCalculate(BillProvider provider) {
    FocusScope.of(context).unfocus();
    provider.calculate(_depthController.text, _casingFeetController.text);
    if (provider.result != null) {
      HapticFeedback.mediumImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final resultContext = _resultKey.currentContext;
        if (resultContext != null) {
          Scrollable.ensureVisible(
            resultContext,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0,
          );
        }
      });
    }
  }

  void _onReset(BillProvider provider) {
    FocusScope.of(context).unfocus();
    _depthController.clear();
    _casingFeetController.clear();
    _clientNameController.clear();
    _clientPhoneController.clear();
    _clientAddressController.clear();
    setState(() {
      _billForClient = false;
      _clientNameError = null;
    });
    provider.reset();
  }

  Future<void> _onCopy(BillProvider provider, AppLocalizations l10n) async {
    final text = provider.buildSummaryText(l10n);
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.billCopied)));
  }

  /// Validates the client name (required only when billing another client)
  /// and returns the PDF bytes for the current result, or null if invalid.
  Future<Uint8List?> _buildPdfIfValid(
    BillProvider provider,
    AppLocalizations l10n,
  ) async {
    final result = provider.result;
    if (result == null) return null;

    if (_billForClient && _clientNameController.text.trim().isEmpty) {
      setState(() => _clientNameError = l10n.clientNameError);
      return null;
    }
    setState(() => _clientNameError = null);

    final bytes = await PdfService.generateBillPdf(
      result: result,
      locale: Localizations.localeOf(context),
      clientName: _billForClient ? _clientNameController.text : null,
      clientPhone: _billForClient ? _clientPhoneController.text : null,
      clientAddress: _billForClient ? _clientAddressController.text : null,
    );

    // Fire-and-forget: ReportHistoryService already swallows its own
    // errors, so a flaky connection never blocks the share/download the
    // user is actually waiting on.
    unawaited(
      ReportHistoryService.instance.saveReport(
        bytes: bytes,
        totalDepth: result.totalDepth,
        totalAmount: result.totalAmount,
        clientName: _billForClient ? _clientNameController.text.trim() : null,
        clientPhone: _billForClient ? _clientPhoneController.text.trim() : null,
        clientAddress: _billForClient
            ? _clientAddressController.text.trim()
            : null,
      ),
    );

    return bytes;
  }

  String _pdfFileName() {
    final name = _billForClient ? _clientNameController.text.trim() : '';
    final safeName = name.isEmpty
        ? 'borewell_bill'
        : 'borewell_bill_${name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}';
    return '$safeName.pdf';
  }

  Future<void> _onSharePdf(BillProvider provider, AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    setState(() => _isSharing = true);
    try {
      final bytes = await _buildPdfIfValid(provider, l10n);
      if (bytes == null) return;
      await sharePdfBytes(bytes, _pdfFileName(), l10n.pdfTitle);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _onDownloadPdf(
    BillProvider provider,
    AppLocalizations l10n,
  ) async {
    FocusScope.of(context).unfocus();
    setState(() => _isDownloading = true);
    try {
      final bytes = await _buildPdfIfValid(provider, l10n);
      if (bytes == null) return;
      final path = await downloadPdfBytes(bytes, _pdfFileName());
      if (!mounted) return;
      HapticFeedback.mediumImpact();
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
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop_rounded, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(l10n.appTitle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          const ThemeSwitcher(),
          const LanguageSwitcher(),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.historyTooltip,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.editFixedCharges,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
        bottom: const WaveAppBarBottom(),
      ),
      body: Consumer<BillProvider>(
        builder: (context, provider, _) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        kCompanyName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.appTagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                DepthInputCard(
                  controller: _depthController,
                  label: l10n.totalDepthLabel,
                  unit: l10n.feetUnit,
                  errorText: _depthErrorText(l10n, provider.depthError),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.plumbing_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.casingHeading,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          key: ValueKey('casing_feet_${provider.version}'),
                          controller: _casingFeetController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.casingFeetLabel,
                            suffixText: l10n.feetUnit,
                            prefixIcon: const Icon(Icons.straighten_rounded),
                            errorText: _casingErrorText(
                              l10n,
                              provider.depthError,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        RatePickerField(
                          key: ValueKey('casing_rate_${provider.version}'),
                          label: l10n.casingRateLabel,
                          icon: Icons.sell_outlined,
                          options: casingRateOptions,
                          value: provider.casingRate,
                          placeholder: l10n.selectCasingRateHint,
                          onSelected: provider.selectCasingRate,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          secondary: Icon(
                            Icons.person_outline_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.billForClientTitle),
                          subtitle: Text(l10n.billForClientSubtitle),
                          value: _billForClient,
                          onChanged: (value) =>
                              setState(() => _billForClient = value),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: !_billForClient
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    8,
                                    12,
                                  ),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _clientNameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: InputDecoration(
                                          labelText: l10n.clientNameLabel,
                                          errorText: _clientNameError,
                                          prefixIcon: const Icon(
                                            Icons.badge_outlined,
                                          ),
                                        ),
                                        onChanged: (_) {
                                          if (_clientNameError != null) {
                                            setState(
                                              () => _clientNameError = null,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _clientPhoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          labelText: l10n.clientPhoneLabel,
                                          prefixIcon: const Icon(
                                            Icons.phone_outlined,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _clientAddressController,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          labelText: l10n.clientAddressLabel,
                                          prefixIcon: const Icon(
                                            Icons.location_on_outlined,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.speed_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.drillingHeading,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RatePickerField(
                      key: ValueKey('base_rate_${provider.version}'),
                      label: l10n.baseRateLabel,
                      icon: Icons.sell_outlined,
                      options: baseDrillingRateOptions,
                      value: provider.baseRate,
                      placeholder: l10n.selectRateHint,
                      onSelected: provider.selectBaseRate,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                LargeButton(
                  label: l10n.calculateBill,
                  icon: Icons.calculate_outlined,
                  onPressed: () => _onCalculate(provider),
                ),
                const SizedBox(height: 12),
                LargeButton(
                  label: l10n.reset,
                  icon: Icons.refresh,
                  isPrimary: false,
                  onPressed: () => _onReset(provider),
                ),
                if (provider.result != null) ...[
                  const SizedBox(height: 24),
                  ResultCard(
                    key: _resultKey,
                    result: provider.result!,
                    breakdownLabel: l10n.billBreakdown,
                    totalLabel: l10n.totalAmount,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LargeButton(
                          label: l10n.copy,
                          icon: Icons.copy_outlined,
                          isPrimary: false,
                          onPressed: _isExporting
                              ? null
                              : () => _onCopy(provider, l10n),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LargeButton(
                          label: l10n.share,
                          icon: Icons.share_outlined,
                          isPrimary: false,
                          isLoading: _isSharing,
                          onPressed: _isExporting
                              ? null
                              : () => _onSharePdf(provider, l10n),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LargeButton(
                    label: l10n.downloadPdf,
                    icon: Icons.download_outlined,
                    isLoading: _isDownloading,
                    onPressed: _isExporting
                        ? null
                        : () => _onDownloadPdf(provider, l10n),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
