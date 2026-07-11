import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report_record.dart';

/// Saves and retrieves generated bills from Cloud Firestore, scoped to an
/// anonymous per-device identity so each install only ever sees its own
/// history (see `firestore.rules` in the repo root for the matching rule).
///
/// All calls are best-effort: a contractor generating a bill in the field
/// with no signal should never be blocked by a failed cloud write, so
/// [saveReport] swallows its own errors (Firestore still queues the write
/// offline and syncs later automatically).
class ReportHistoryService {
  ReportHistoryService._();

  static final ReportHistoryService instance = ReportHistoryService._();

  String? _uid;

  /// Signs in anonymously if needed. Safe to call repeatedly; a no-op once
  /// signed in. Returns false (rather than throwing) if Firebase isn't
  /// reachable/configured, so callers can degrade gracefully.
  Future<bool> ensureSignedIn() async {
    if (_uid != null) return true;
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      _uid = user?.uid;
      return _uid != null;
    } catch (_) {
      return false;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports');
  }

  /// Saves [bytes] as a new history entry. Returns silently on failure.
  Future<void> saveReport({
    required Uint8List bytes,
    required int totalDepth,
    required double totalAmount,
    String? clientName,
    String? clientPhone,
    String? clientAddress,
  }) async {
    if (!await ensureSignedIn()) return;
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

  /// Streams saved reports, most recent first. Emits an empty list if
  /// Firebase isn't configured/reachable rather than throwing.
  Stream<List<ReportRecord>> streamReports() async* {
    if (!await ensureSignedIn()) {
      yield const [];
      return;
    }
    final collection = _collection;
    if (collection == null) {
      yield const [];
      return;
    }
    yield* collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportRecord.fromJson(doc.id, doc.data()))
            .toList())
        .handleError((_) {});
  }

  Future<void> deleteReport(String id) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(id).delete();
  }
}
