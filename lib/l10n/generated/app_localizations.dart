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
  /// **'Fast, accurate borewell billing'**
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

  /// No description provided for @depthErrorCasingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter casing feet.'**
  String get depthErrorCasingEmpty;

  /// No description provided for @depthErrorInvalidCasing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid casing depth.'**
  String get depthErrorInvalidCasing;

  /// No description provided for @depthErrorMissingCasingRate.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter a valid casing rate.'**
  String get depthErrorMissingCasingRate;

  /// No description provided for @depthErrorInvalidBaseRate.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter a valid base rate.'**
  String get depthErrorInvalidBaseRate;

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

  /// No description provided for @drillingHeading.
  ///
  /// In en, this message translates to:
  /// **'Drilling Rate'**
  String get drillingHeading;

  /// No description provided for @baseRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Base Rate'**
  String get baseRateLabel;

  /// No description provided for @selectRateHint.
  ///
  /// In en, this message translates to:
  /// **'Select rate'**
  String get selectRateHint;

  /// No description provided for @casingHeading.
  ///
  /// In en, this message translates to:
  /// **'Casing'**
  String get casingHeading;

  /// No description provided for @casingFeetLabel.
  ///
  /// In en, this message translates to:
  /// **'Casing Feet'**
  String get casingFeetLabel;

  /// No description provided for @casingRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Casing Rate (GI)'**
  String get casingRateLabel;

  /// No description provided for @selectCasingRateHint.
  ///
  /// In en, this message translates to:
  /// **'Select casing rate'**
  String get selectCasingRateHint;

  /// No description provided for @customOption.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customOption;

  /// No description provided for @customRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Rate (₹/ft)'**
  String get customRateLabel;

  /// No description provided for @additionalChargesHeading.
  ///
  /// In en, this message translates to:
  /// **'Additional Charges'**
  String get additionalChargesHeading;

  /// No description provided for @collarQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Collar'**
  String get collarQtyLabel;

  /// No description provided for @weldingQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Welding'**
  String get weldingQtyLabel;

  /// No description provided for @cuttingQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get cuttingQtyLabel;

  /// No description provided for @capQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Cap'**
  String get capQtyLabel;

  /// No description provided for @perUnitSuffix.
  ///
  /// In en, this message translates to:
  /// **'/unit'**
  String get perUnitSuffix;

  /// No description provided for @piecesUnit.
  ///
  /// In en, this message translates to:
  /// **'Nos'**
  String get piecesUnit;

  /// No description provided for @customQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Quantity'**
  String get customQtyLabel;

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

  /// No description provided for @fixedChargeDetail.
  ///
  /// In en, this message translates to:
  /// **'Fixed charge'**
  String get fixedChargeDetail;

  /// No description provided for @editFixedCharges.
  ///
  /// In en, this message translates to:
  /// **'Edit Rates'**
  String get editFixedCharges;

  /// No description provided for @defaultRatesHeading.
  ///
  /// In en, this message translates to:
  /// **'Default Rates'**
  String get defaultRatesHeading;

  /// No description provided for @defaultRatesHint.
  ///
  /// In en, this message translates to:
  /// **'These are pre-selected on the home screen for every new bill.'**
  String get defaultRatesHint;

  /// No description provided for @defaultBaseRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Base Rate'**
  String get defaultBaseRateLabel;

  /// No description provided for @defaultCasingRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Casing Rate'**
  String get defaultCasingRateLabel;

  /// No description provided for @invalidDefaultRates.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter a valid rate for both defaults.'**
  String get invalidDefaultRates;

  /// No description provided for @itemRatesHeading.
  ///
  /// In en, this message translates to:
  /// **'Item Rates'**
  String get itemRatesHeading;

  /// No description provided for @fixedChargesHint.
  ///
  /// In en, this message translates to:
  /// **'Set the per-unit rate for each item. On the bill, this rate is multiplied by the quantity you enter.'**
  String get fixedChargesHint;

  /// No description provided for @collarLabel.
  ///
  /// In en, this message translates to:
  /// **'Collar (per unit)'**
  String get collarLabel;

  /// No description provided for @weldingLabel.
  ///
  /// In en, this message translates to:
  /// **'Welding (per unit)'**
  String get weldingLabel;

  /// No description provided for @cuttingLabel.
  ///
  /// In en, this message translates to:
  /// **'Cutting (per unit)'**
  String get cuttingLabel;

  /// No description provided for @capLabel.
  ///
  /// In en, this message translates to:
  /// **'Cap (per unit)'**
  String get capLabel;

  /// No description provided for @invalidFixedCharges.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount for every charge.'**
  String get invalidFixedCharges;

  /// No description provided for @fixedChargesSaved.
  ///
  /// In en, this message translates to:
  /// **'Rates saved'**
  String get fixedChargesSaved;

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

  /// No description provided for @pdfBaseRate.
  ///
  /// In en, this message translates to:
  /// **'Base Rate: {rate}/ft'**
  String pdfBaseRate(String rate);

  /// No description provided for @pdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pdfDescription;

  /// No description provided for @pdfDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get pdfDetail;

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

  /// No description provided for @historyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Report history'**
  String get historyTooltip;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved reports yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generated bills will appear here once you share or download a PDF.'**
  String get historyEmptySubtitle;

  /// No description provided for @historyDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDeleteTooltip;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Report deleted'**
  String get historyDeleted;

  /// No description provided for @walkInClient.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer'**
  String get walkInClient;
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
