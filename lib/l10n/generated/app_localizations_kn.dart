// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಬೋರ್‌ವೆಲ್ ಬಿಲ್ ಕ್ಯಾಲ್ಕುಲೇಟರ್';

  @override
  String get appTagline => 'ವೇಗದ, ನಿಖರ ಹಂತ-ಆಧಾರಿತ ಬಿಲ್ಲಿಂಗ್';

  @override
  String get languageTooltip => 'ಭಾಷೆ ಬದಲಾಯಿಸಿ';

  @override
  String get totalDepthLabel => 'ಒಟ್ಟು ಆಳ';

  @override
  String get feetUnit => 'ಅಡಿ';

  @override
  String get depthErrorEmpty => 'ದಯವಿಟ್ಟು ಬೋರ್‌ವೆಲ್ ಆಳವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get depthErrorInvalid => 'ದಯವಿಟ್ಟು ಸರಿಯಾದ ಬೋರ್‌ವೆಲ್ ಆಳವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get depthErrorCustomRate => 'ದಯವಿಟ್ಟು ನಿಗದಿತ ದರವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get billForClientTitle => 'ಗ್ರಾಹಕರಿಗಾಗಿ ಬಿಲ್ ರಚಿಸಿ';

  @override
  String get billForClientSubtitle =>
      'ಹಂಚಿಕೊಂಡ ಅಥವಾ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ PDF ಗೆ ಅವರ ಹೆಸರು/ಸಂಪರ್ಕವನ್ನು ಸೇರಿಸುತ್ತದೆ';

  @override
  String get clientNameLabel => 'ಗ್ರಾಹಕರ ಹೆಸರು';

  @override
  String get clientNameError => 'ದಯವಿಟ್ಟು ಗ್ರಾಹಕರ ಹೆಸರನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get clientPhoneLabel => 'ಫೋನ್ (ಐಚ್ಛಿಕ)';

  @override
  String get clientAddressLabel => 'ವಿಳಾಸ (ಐಚ್ಛಿಕ)';

  @override
  String get rateSlabsHeading => 'ದರ ಹಂತಗಳು';

  @override
  String get rateLabel => 'ದರ';

  @override
  String get customOption => 'ಕಸ್ಟಮ್';

  @override
  String get customRateLabel => 'ಕಸ್ಟಮ್ ದರ';

  @override
  String get calculateBill => 'ಬಿಲ್ ಲೆಕ್ಕಹಾಕಿ';

  @override
  String get reset => 'ಮರುಹೊಂದಿಸಿ';

  @override
  String get copy => 'ನಕಲಿಸಿ';

  @override
  String get share => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get downloadPdf => 'PDF ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get open => 'ತೆರೆಯಿರಿ';

  @override
  String get billCopied => 'ಬಿಲ್ ಅನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ';

  @override
  String get pdfSaved => 'PDF ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get shareFailed =>
      'PDF ಹಂಚಿಕೊಳ್ಳಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadFailed =>
      'PDF ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get billBreakdown => 'ಬಿಲ್ ವಿವರ';

  @override
  String get totalAmount => 'ಒಟ್ಟು ಮೊತ್ತ';

  @override
  String get editDefaultRates => 'ಡೀಫಾಲ್ಟ್ ದರಗಳನ್ನು ಸಂಪಾದಿಸಿ';

  @override
  String get defaultRatesHint =>
      'ಈ ದರಗಳನ್ನು ಅಪ್ಲಿಕೇಶನ್ ತೆರೆಯುವ ಪ್ರತಿ ಬಾರಿ ಬಳಸಲಾಗುತ್ತದೆ.';

  @override
  String get invalidRateForEverySlab =>
      'ದಯವಿಟ್ಟು ಪ್ರತಿ ಹಂತಕ್ಕೂ ಸರಿಯಾದ ದರವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get defaultRatesSaved => 'ಡೀಫಾಲ್ಟ್ ದರಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get pdfTitle => 'ಬೋರ್‌ವೆಲ್ ಬಿಲ್';

  @override
  String pdfGeneratedOn(String date) {
    return '$date ರಂದು ರಚಿಸಲಾಗಿದೆ';
  }

  @override
  String get pdfBillTo => 'ಬಿಲ್ ಸ್ವೀಕರಿಸುವವರು';

  @override
  String pdfTotalDepth(int depth) {
    return 'ಒಟ್ಟು ಆಳ: $depth ಅಡಿ';
  }

  @override
  String get pdfDepthRange => 'ಆಳದ ವ್ಯಾಪ್ತಿ';

  @override
  String get pdfFeet => 'ಅಡಿ';

  @override
  String get pdfRatePerFt => 'ದರ/ಅಡಿ';

  @override
  String get pdfAmount => 'ಮೊತ್ತ';

  @override
  String get pdfTotalAmount => 'ಒಟ್ಟು ಮೊತ್ತ';
}
