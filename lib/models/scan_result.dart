import 'dart:typed_data';

/// Enumerates every SDK operation that can produce a result.
enum ScanResultType {
  /// South African Green Book (old ID book) scan.
  greenBook,

  /// South African Passport scan.
  passport,

  /// South African Smart ID Card scan.
  idCard,

  /// Passive Liveness Detection check.
  liveness,

  /// Facial Comparison between two biometric images.
  faceCompare,
}

/// Extension to convert [ScanResultType] to a display-friendly label.
extension ScanResultTypeLabel on ScanResultType {
  String get displayName {
    switch (this) {
      case ScanResultType.greenBook:
        return 'Green Book';
      case ScanResultType.passport:
        return 'Passport';
      case ScanResultType.idCard:
        return 'ID Card';
      case ScanResultType.liveness:
        return 'Liveness Detection';
      case ScanResultType.faceCompare:
        return 'Face Comparison';
    }
  }
}

/// Represents the result of any Sybrin SDK operation.
///
/// After a successful SDK call, this model carries:
/// - The [type] of scan that produced it.
/// - A dictionary of [fields] extracted by OCR (for identity scans).
/// - Optional raw [portraitBytes] of the cropped face image.
/// - A [confidence] value (0.0–1.0) for liveness/face compare results.
class ScanResult {
  /// Which SDK feature produced this result.
  final ScanResultType type;

  /// OCR-extracted key/value pairs from a document scan.
  ///
  /// Keys are human-readable field names (e.g. "Surname", "ID Number").
  /// Empty for liveness/face-compare results.
  final Map<String, String> fields;

  /// Raw PNG bytes of the extracted portrait/selfie image, if available.
  ///
  /// - Identity scans: portrait cropped from the document.
  /// - Liveness: the selfie captured during the check.
  /// - Face compare / OCR-only: `null`.
  final Uint8List? portraitBytes;

  /// Confidence score in the range [0.0, 1.0].
  ///
  /// - Liveness: how confident the SDK is the subject is live.
  /// - Face compare: average similarity across the provided faces.
  /// - Identity scans: `null`.
  final double? confidence;

  /// Human-readable timestamp when this result was produced.
  final DateTime timestamp;

  ScanResult({
    required this.type,
    this.fields = const {},
    this.portraitBytes,
    this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether this result contains a portrait image.
  bool get hasPortrait => portraitBytes != null;

  /// Whether this result has a confidence score (liveness / face compare).
  bool get hasConfidence => confidence != null;

  /// Returns the confidence as a percentage string, e.g. "87.3%".
  String get confidencePercent =>
      confidence != null ? '${(confidence! * 100).toStringAsFixed(1)}%' : '—';
}
