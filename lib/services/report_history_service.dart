import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report_record.dart';

/// Saves and retrieves generated bills from Cloud Firestore, scoped to
/// whichever phone number is currently signed in — so every device signed
/// in with the same number shares the same bill history (see
/// `firestore.rules` in the repo root for the matching rule).
///
/// Sign-in is user-initiated via [sendOtp]/[verifyOtp] (see
/// [PhoneSignInView]); until then, [saveReport] and [streamReports] are
/// no-ops rather than failures. Once signed in, calls are still
/// best-effort: a contractor generating a bill in the field with no
/// signal should never be blocked by a failed cloud write, so
/// [saveReport] swallows its own errors (Firestore still queues the write
/// offline and syncs later automatically).
class ReportHistoryService {
  ReportHistoryService._();

  static final ReportHistoryService instance = ReportHistoryService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Emits the signed-in [User], or null when signed out.
  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Starts phone-number verification: Firebase sends an SMS OTP to
  /// [phoneNumber] (E.164 format, e.g. "+919876543210").
  ///
  /// On Android, Firebase may auto-retrieve and complete sign-in without
  /// the user ever typing the code, in which case [onAutoVerified] fires
  /// directly. Otherwise [onCodeSent] fires with a verification ID the
  /// caller must pass back into [verifyOtp] along with the code the user
  /// typed.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    required void Function() onAutoVerified,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        onAutoVerified();
      },
      verificationFailed: (e) => onError(e.message ?? 'Verification failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Completes sign-in with the OTP the user typed. Throws a
  /// [FirebaseAuthException] on an invalid/expired code so the UI can show
  /// a specific message.
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports');
  }

  /// Saves [bytes] as a new history entry. No-ops silently while signed
  /// out or on failure.
  Future<void> saveReport({
    required Uint8List bytes,
    required int totalDepth,
    required double totalAmount,
    String? clientName,
    String? clientPhone,
    String? clientAddress,
  }) async {
    final collection = _collection;
    if (collection == null) return;

    final record = ReportRecord(
      createdAt: DateTime.now(),
      totalDepth: totalDepth,
      totalAmount: totalAmount,
      clientName: clientName,
      clientPhone: clientPhone,
      clientAddress: clientAddress,
      pdfBase64: base64Encode(bytes),
    );

    try {
      await collection.add(record.toJson());
    } catch (_) {
      // Best-effort: the bill was already shared/downloaded locally, so a
      // failed cloud save shouldn't surface as an error to the user.
    }
  }

  /// Streams saved reports, most recent first. Emits an empty list while
  /// signed out.
  Stream<List<ReportRecord>> streamReports() {
    final collection = _collection;
    if (collection == null) return Stream.value(const []);
    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReportRecord.fromJson(doc.id, doc.data()))
              .toList(),
        )
        .handleError((_) {});
  }

  Future<void> deleteReport(String id) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(id).delete();
  }
}
