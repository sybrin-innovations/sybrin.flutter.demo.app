import 'dart:typed_data';

/// Enumerates every SDK operation that can produce a result.
enum ScanResultType {
  /// Any Sybrin Identity document scan (dynamic — covers all countries & doc types).
  identity,

  /// Passive Liveness Detection check.
  liveness,

  /// Facial Comparison between two biometric images.
  faceCompare,

  // Legacy values kept for any existing references.
  greenBook,
  passport,
  idCard,
}

/// Extension to convert [ScanResultType] to a display-friendly label.
extension ScanResultTypeLabel on ScanResultType {
  String get displayName {
    switch (this) {
      case ScanResultType.identity:
        return 'Identity Scan';
      case ScanResultType.liveness:
        return 'Liveness Detection';
      case ScanResultType.faceCompare:
        return 'Face Comparison';
      case ScanResultType.greenBook:
        return 'Green Book';
      case ScanResultType.passport:
        return 'Passport';
      case ScanResultType.idCard:
        return 'ID Card';
    }
  }
}

/// Represents the result of any Sybrin SDK operation.
class ScanResult {
  final ScanResultType type;

  /// The Java enum name of the scanned document (e.g. "SouthAfricaPassport").
  /// Populated for [ScanResultType.identity] results only.
  final String? documentEnum;

  /// OCR-extracted key/value pairs from a document scan.
  final Map<String, String> fields;

  /// Raw JPEG bytes of the portrait/selfie image, if available.
  final Uint8List? portraitBytes;

  /// Whether the SDK determined the subject is a live person.
  /// Populated for [ScanResultType.liveness] results only.
  final bool? isAlive;

  /// Confidence score in [0.0, 1.0] — face compare only.
  final double? confidence;

  final DateTime timestamp;

  ScanResult({
    required this.type,
    this.documentEnum,
    this.fields = const {},
    this.portraitBytes,
    this.isAlive,
    this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasPortrait    => portraitBytes != null;
  bool get hasConfidence  => confidence != null;

  String get confidencePercent =>
      confidence != null ? '${(confidence! * 100).toStringAsFixed(1)}%' : '—';
}
