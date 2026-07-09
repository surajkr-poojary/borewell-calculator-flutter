import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes [bytes] to a temporary file and opens the native share sheet so
/// the PDF can be sent via WhatsApp, email, etc.
Future<void> sharePdfBytes(Uint8List bytes, String fileName, String subject) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
    subject: subject,
  );
}

/// Saves [bytes] to a persistent, app-accessible location on disk and
/// returns the resulting file path.
///
/// On Android this uses the app's external "Download" directory (no
/// runtime storage permission required). On iOS this uses the app's
/// Documents directory, which is exposed in the Files app because
/// `UIFileSharingEnabled` / `LSSupportsOpeningDocumentsInPlace` are set in
/// Info.plist. Other platforms fall back to the application documents
/// directory.
Future<String> downloadPdfBytes(Uint8List bytes, String fileName) async {
  Directory? dir;
  if (!kIsWeb && Platform.isAndroid) {
    dir = await getDownloadsDirectory();
  }
  dir ??= await getApplicationDocumentsDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Opens a previously saved file with the platform's default PDF viewer.
/// Failures are swallowed: the caller already has the saved file path to
/// show the user, opening it is a convenience, not a requirement.
Future<void> openSavedFile(String path) async {
  try {
    await OpenFilex.open(path);
  } catch (_) {
    // No viewer available on this platform/device; the file is still saved.
  }
}
