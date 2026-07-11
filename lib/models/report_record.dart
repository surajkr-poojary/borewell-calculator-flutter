import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// A previously generated bill, saved to Firestore so it can be revisited
/// later. The PDF itself is embedded as base64 in [pdfBase64] rather than
/// stored in Firebase Storage, since a single-page bill PDF is small
/// enough to fit well within Firestore's 1 MiB document limit — this
/// keeps the whole feature on the free Spark plan.
class ReportRecord {
  final String? id;
  final DateTime createdAt;
  final int totalDepth;
  final double totalAmount;
  final String? clientName;
  final String? clientPhone;
  final String? clientAddress;
  final String pdfBase64;

  const ReportRecord({
    this.id,
    required this.createdAt,
    required this.totalDepth,
    required this.totalAmount,
    this.clientName,
    this.clientPhone,
    this.clientAddress,
    required this.pdfBase64,
  });

  Uint8List get pdfBytes => base64Decode(pdfBase64);

  Map<String, dynamic> toJson() => {
        'createdAt': Timestamp.fromDate(createdAt),
        'totalDepth': totalDepth,
        'totalAmount': totalAmount,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'clientAddress': clientAddress,
        'pdfBase64': pdfBase64,
      };

  factory ReportRecord.fromJson(String id, Map<String, dynamic> json) {
    return ReportRecord(
      id: id,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      totalDepth: (json['totalDepth'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      clientName: json['clientName'] as String?,
      clientPhone: json['clientPhone'] as String?,
      clientAddress: json['clientAddress'] as String?,
      pdfBase64: json['pdfBase64'] as String,
    );
  }
}
