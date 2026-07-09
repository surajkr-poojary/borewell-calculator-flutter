import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';

/// A plain text toggle ("EN" / "KN") in the app bar for switching the
/// app's language. Uses ISO-style two-letter codes rather than native
/// script so it reads unambiguously regardless of the current language.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isKannada = currentCode == 'kn';

    return IconButton(
      tooltip: l10n.languageTooltip,
      onPressed: () => context.read<LocaleProvider>().setLocale(
            Locale(isKannada ? 'en' : 'kn'),
          ),
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language_rounded, size: 20),
          const SizedBox(width: 4),
          Text(
            isKannada ? 'KN' : 'EN',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
