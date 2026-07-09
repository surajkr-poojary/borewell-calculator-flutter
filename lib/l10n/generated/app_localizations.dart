import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Borewell Bill Calculator'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Fast, accurate slab-wise billing'**
  String get appTagline;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageTooltip;

  /// No description provided for @totalDepthLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DEPTH'**
  String get totalDepthLabel;

  /// No description provided for @feetUnit.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get feetUnit;

  /// No description provided for @depthErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter borewell depth.'**
  String get depthErrorEmpty;

  /// No description provided for @depthErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid borewell depth.'**
  String get depthErrorInvalid;

  /// No description provided for @depthErrorCustomRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter custom rate.'**
  String get depthErrorCustomRate;

  /// No description provided for @billForClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate bill for a client'**
  String get billForClientTitle;

  /// No description provided for @billForClientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds their name/contact to the shared or downloaded PDF'**
  String get billForClientSubtitle;

  /// No description provided for @clientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientNameLabel;

  /// No description provided for @clientNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the client\'s name.'**
  String get clientNameError;

  /// No description provided for @clientPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get clientPhoneLabel;

  /// No description provided for @clientAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get clientAddressLabel;

  /// No description provided for @rateSlabsHeading.
  ///
  /// In en, this message translates to:
  /// **'Rate Slabs'**
  String get rateSlabsHeading;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateLabel;

  /// No description provided for @customOption.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customOption;

  /// No description provided for @customRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Rate'**
  String get customRateLabel;

  /// No description provided for @calculateBill.
  ///
  /// In en, this message translates to:
  /// **'Calculate Bill'**
  String get calculateBill;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @billCopied.
  ///
  /// In en, this message translates to:
  /// **'Bill copied to clipboard'**
  String get billCopied;

  /// No description provided for @pdfSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF saved'**
  String get pdfSaved;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the PDF. Please try again.'**
  String get shareFailed;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the PDF. Please try again.'**
  String get downloadFailed;

  /// No description provided for @billBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Bill Breakdown'**
  String get billBreakdown;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @editDefaultRates.
  ///
  /// In en, this message translates to:
  /// **'Edit Default Rates'**
  String get editDefaultRates;

  /// No description provided for @defaultRatesHint.
  ///
  /// In en, this message translates to:
  /// **'These rates are used every time the app opens.'**
  String get defaultRatesHint;

  /// No description provided for @invalidRateForEverySlab.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid rate for every slab.'**
  String get invalidRateForEverySlab;

  /// No description provided for @defaultRatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Default rates saved'**
  String get defaultRatesSaved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Borewell Bill'**
  String get pdfTitle;

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String pdfGeneratedOn(String date);

  /// No description provided for @pdfBillTo.
  ///
  /// In en, this message translates to:
  /// **'Bill To'**
  String get pdfBillTo;

  /// No description provided for @pdfTotalDepth.
  ///
  /// In en, this message translates to:
  /// **'Total Depth: {depth} ft'**
  String pdfTotalDepth(int depth);

  /// No description provided for @pdfDepthRange.
  ///
  /// In en, this message translates to:
  /// **'Depth Range'**
  String get pdfDepthRange;

  /// No description provided for @pdfFeet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get pdfFeet;

  /// No description provided for @pdfRatePerFt.
  ///
  /// In en, this message translates to:
  /// **'Rate/ft'**
  String get pdfRatePerFt;

  /// No description provided for @pdfAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get pdfAmount;

  /// No description provided for @pdfTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get pdfTotalAmount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
