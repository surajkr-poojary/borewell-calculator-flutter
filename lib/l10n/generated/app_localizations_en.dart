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
  String get appTagline => 'Fast, accurate borewell billing';

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
  String get depthErrorCasingEmpty => 'Please enter casing feet.';

  @override
  String get depthErrorInvalidCasing => 'Please enter a valid casing depth.';

  @override
  String get depthErrorMissingCasingRate => 'Please select a casing rate.';

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
  String get drillingHeading => 'Drilling Rate';

  @override
  String get baseRateLabel => 'Base Rate';

  @override
  String get selectRateHint => 'Select rate';

  @override
  String get casingHeading => 'Casing';

  @override
  String get casingFeetLabel => 'Casing Feet';

  @override
  String get casingRateLabel => 'Casing Rate (GI)';

  @override
  String get selectCasingRateHint => 'Select casing rate';

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
  String get fixedChargeDetail => 'Fixed charge';

  @override
  String get editFixedCharges => 'Edit Fixed Charges';

  @override
  String get fixedChargesHint => 'These charges are added to every bill.';

  @override
  String get collarLabel => 'Collar';

  @override
  String get weldingLabel => 'Welding';

  @override
  String get cuttingLabel => 'Cutting';

  @override
  String get capLabel => 'Cap';

  @override
  String get invalidFixedCharges =>
      'Please enter a valid amount for every charge.';

  @override
  String get fixedChargesSaved => 'Fixed charges saved';

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
  String pdfBaseRate(String rate) {
    return 'Base Rate: $rate/ft';
  }

  @override
  String get pdfDescription => 'Description';

  @override
  String get pdfDetail => 'Detail';

  @override
  String get pdfAmount => 'Amount';

  @override
  String get pdfTotalAmount => 'Total Amount';

  @override
  String get historyTooltip => 'Report history';

  @override
  String get historyTitle => 'Report History';

  @override
  String get historyEmpty => 'No saved reports yet';

  @override
  String get historyEmptySubtitle =>
      'Generated bills will appear here once you share or download a PDF.';

  @override
  String get historyDeleteTooltip => 'Delete';

  @override
  String get historyDeleted => 'Report deleted';

  @override
  String get walkInClient => 'Walk-in customer';
}
