import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/report_history_service.dart';
import '../widgets/large_button.dart';

/// Phone number + OTP sign-in, shown inline wherever [ReportHistoryService]
/// has no signed-in user (see `HistoryScreen`). Once sign-in completes,
/// [ReportHistoryService.authState] emits the new user and the caller's
/// `StreamBuilder` swaps this out for the real content — this widget never
/// navigates anywhere itself.
class PhoneSignInView extends StatefulWidget {
  const PhoneSignInView({super.key});

  @override
  State<PhoneSignInView> createState() => _PhoneSignInViewState();
}

class _PhoneSignInViewState extends State<PhoneSignInView> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _service = ReportHistoryService.instance;

  String? _verificationId;
  String? _e164Phone;
  bool _isBusy = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context);
    final digits = _phoneController.text.trim();
    if (digits.length != 10 || int.tryParse(digits) == null) {
      setState(() => _errorText = l10n.phoneNumberError);
      return;
    }

    final e164 = '+91$digits';
    setState(() {
      _isBusy = true;
      _errorText = null;
    });

    await _service.sendOtp(
      phoneNumber: e164,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _isBusy = false;
          _verificationId = verificationId;
          _e164Phone = e164;
        });
      },
      onAutoVerified: () {
        if (!mounted) return;
        setState(() => _isBusy = false);
      },
      onError: (message) {
        debugPrint('Phone auth sendOtp failed: $message');
        if (!mounted) return;
        setState(() {
          _isBusy = false;
          _errorText = l10n.otpSendFailed;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context);
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _errorText = l10n.otpError);
      return;
    }

    setState(() {
      _isBusy = true;
      _errorText = null;
    });

    try {
      await _service.verifyOtp(verificationId: _verificationId!, smsCode: code);
    } catch (e) {
      debugPrint('Phone auth verifyOtp failed: $e');
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _errorText = l10n.otpVerifyFailed;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  void _changeNumber() {
    setState(() {
      _verificationId = null;
      _e164Phone = null;
      _otpController.clear();
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final awaitingOtp = _verificationId != null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.cloud_sync_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.phoneSignInTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.phoneSignInSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!awaitingOtp) ...[
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: l10n.phoneNumberLabel,
                hintText: l10n.phoneNumberHint,
                prefixText: '+91 ',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            LargeButton(
              label: l10n.sendOtp,
              isLoading: _isBusy,
              onPressed: _sendOtp,
            ),
          ] else ...[
            Text(
              l10n.otpSubtitle(_e164Phone!),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                labelText: l10n.otpLabel,
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            LargeButton(
              label: l10n.verifyOtp,
              isLoading: _isBusy,
              onPressed: _verifyOtp,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isBusy ? null : _changeNumber,
                  child: Text(l10n.changeNumber),
                ),
                TextButton(
                  onPressed: _isBusy ? null : _sendOtp,
                  child: Text(l10n.resendOtp),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
