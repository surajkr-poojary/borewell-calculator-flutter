import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'providers/bill_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BorewellBillCalculatorApp());
}

class BorewellBillCalculatorApp extends StatefulWidget {
  const BorewellBillCalculatorApp({super.key});

  @override
  State<BorewellBillCalculatorApp> createState() =>
      _BorewellBillCalculatorAppState();
}

class _BorewellBillCalculatorAppState extends State<BorewellBillCalculatorApp> {
  final _localeProvider = LocaleProvider();
  final _themeProvider = AppThemeProvider();

  @override
  void initState() {
    super.initState();
    _localeProvider.loadSavedLocale();
    _themeProvider.loadSavedMode();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider.value(value: _localeProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer2<LocaleProvider, AppThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return MaterialApp(
            title: 'Borewell Bill Calculator',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.mode,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.translucent,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
