// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Borewell Bill Calculator';

  @override
  String get appTagline => 'Fast, accurate slab-wise billing';

  @override
  String get languageTooltip => 'Change language';

  @override
  String get totalDepthLabel => 'TOTAL DEPTH';

  @override
  String get feetUnit => 'ft';

  @override
  String get depthErrorEmpty => 'Please enter borewell depth.';

  @override
  String get depthErrorInvalid => 'Please enter a valid borewell depth.';

  @override
  String get depthErrorCustomRate => 'Please enter custom rate.';

  @override
  String get billForClientTitle => 'Generate bill for a client';

  @override
  String get billForClientSubtitle =>
      'Adds their name/contact to the shared or downloaded PDF';

  @override
  String get clientNameLabel => 'Client Name';

  @override
  String get clientNameError => 'Please enter the client\'s name.';

  @override
  String get clientPhoneLabel => 'Phone (optional)';

  @override
  String get clientAddressLabel => 'Address (optional)';

  @override
  String get rateSlabsHeading => 'Rate Slabs';

  @override
  String get rateLabel => 'Rate';

  @override
  String get customOption => 'Custom';

  @override
  String get customRateLabel => 'Custom Rate';

  @override
  String get calculateBill => 'Calculate Bill';

  @override
  String get reset => 'Reset';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get open => 'Open';

  @override
  String get billCopied => 'Bill copied to clipboard';

  @override
  String get pdfSaved => 'PDF saved';

  @override
  String get shareFailed => 'Could not share the PDF. Please try again.';

  @override
  String get downloadFailed => 'Could not save the PDF. Please try again.';

  @override
  String get billBreakdown => 'Bill Breakdown';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get editDefaultRates => 'Edit Default Rates';

  @override
  String get defaultRatesHint =>
      'These rates are used every time the app opens.';

  @override
  String get invalidRateForEverySlab =>
      'Please enter a valid rate for every slab.';

  @override
  String get defaultRatesSaved => 'Default rates saved';

  @override
  String get save => 'Save';

  @override
  String get pdfTitle => 'Borewell Bill';

  @override
  String pdfGeneratedOn(String date) {
    return 'Generated on $date';
  }

  @override
  String get pdfBillTo => 'Bill To';

  @override
  String pdfTotalDepth(int depth) {
    return 'Total Depth: $depth ft';
  }

  @override
  String get pdfDepthRange => 'Depth Range';

  @override
  String get pdfFeet => 'Feet';

  @override
  String get pdfRatePerFt => 'Rate/ft';

  @override
  String get pdfAmount => 'Amount';

  @override
  String get pdfTotalAmount => 'Total Amount';
}
