import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/scan_result.dart';

/// Wraps every Sybrin SDK call behind a clean Dart API using a
/// Flutter [MethodChannel].
///
/// ## Architecture
///
/// ```
/// Flutter (Dart)          Android (Kotlin)
/// ─────────────────       ──────────────────────────
/// SybrinChannel      ←→   SybrinPlugin.kt (MethodChannel handler)
///   .scanGreenBook()  →   SybrinIdentity.scanGreenBook()
///   .scanPassport()   →   SybrinIdentity.scanPassport()
///   .scanIdCard()     →   SybrinIdentity.scanIDCard()
///   .startLiveness()  →   SybrinLivenessDetection.openPassiveLivenessDetection()
///   .compareFaces()   →   SybrinFacialComparison.compareFaces()
/// ```
///
/// All methods are `async` and throw a [SybrinException] on failure
/// instead of returning raw [PlatformException]s, so callers only need
/// to catch one exception type.
class SybrinChannel {
  SybrinChannel._();

  /// The single shared instance – initialised once per app lifecycle.
  static final SybrinChannel instance = SybrinChannel._();

  /// Channel name must match the one registered in [SybrinPlugin.kt].
  static const MethodChannel _channel =
      MethodChannel('com.demo.bioid/sybrin');

  // ------------------------------------------------------------------
  // Identity SDK – Document Scanning
  // ------------------------------------------------------------------

  /// Scans a **South African Green Book** (old ID book).
  ///
  /// Returns a [ScanResult] with [ScanResultType.greenBook].
  /// The [ScanResult.fields] map contains OCR-extracted fields such as
  /// "Surname", "Name", "Date of Birth", "ID Number".
  ///
  /// Throws [SybrinException] if the SDK returns an error or the user
  /// cancels the scan.
  Future<ScanResult> scanGreenBook() async {
    try {
      final result = await _channel.invokeMethod<Map>('scanGreenBook');
      return _parseIdentityResult(ScanResultType.greenBook, result);
    } on PlatformException catch (e) {
      throw SybrinException._fromPlatform(e);
    }
  }

  /// Scans a **South African Passport**.
  ///
  /// Returns a [ScanResult] with [ScanResultType.passport].
  /// The [ScanResult.portraitBytes] field contains the portrait photo
  /// extracted from the passport biographic page.
  ///
  /// Throws [SybrinException] on failure or cancellation.
  Future<ScanResult> scanPassport() async {
    try {
      final result = await _channel.invokeMethod<Map>('scanPassport');
      return _parseIdentityResult(ScanResultType.passport, result);
    } on PlatformException catch (e) {
      throw SybrinException._fromPlatform(e);
    }
  }

  /// Scans a **South African Smart ID Card**.
  ///
  /// Returns a [ScanResult] with [ScanResultType.idCard].
  /// Both the front and back chip-page data are extracted by the SDK.
  ///
  /// Throws [SybrinException] on failure or cancellation.
  Future<ScanResult> scanIdCard() async {
    try {
      final result = await _channel.invokeMethod<Map>('scanIdCard');
      return _parseIdentityResult(ScanResultType.idCard, result);
    } on PlatformException catch (e) {
      throw SybrinException._fromPlatform(e);
    }
  }

  // ------------------------------------------------------------------
  // Biometrics SDK – Liveness & Face Compare
  // ------------------------------------------------------------------

  /// Runs the **Passive Liveness Detection** check.
  ///
  /// Launches the Sybrin liveness UI (no user gestures required –
  /// the SDK analyses a live video feed). On success:
  /// - [ScanResult.confidence] contains the liveness confidence (0.0–1.0).
  /// - [ScanResult.portraitBytes] contains the captured selfie image.
  ///
  /// Throws [SybrinException] on failure or cancellation.
  Future<ScanResult> startLiveness() async {
    try {
      final result = await _channel.invokeMethod<Map>('startLiveness');
      final confidence =
          (result?['confidence'] as num?)?.toDouble() ?? 0.0;
      final portraitBytes =
          result?['portraitBytes'] as Uint8List?;

      return ScanResult(
        type: ScanResultType.liveness,
        confidence: confidence,
        portraitBytes: portraitBytes,
      );
    } on PlatformException catch (e) {
      throw SybrinException._fromPlatform(e);
    }
  }

  /// Compares [targetFace] against every image in [faces] using the
  /// **Sybrin Facial Comparison SDK**.
  ///
  /// - [targetFace]: the reference portrait (e.g. from a passport scan).
  /// - [faces]: one or more selfie images captured via liveness detection.
  ///
  /// Returns a [ScanResult] with [ScanResultType.faceCompare] where
  /// [ScanResult.confidence] is the average similarity score (0.0–1.0).
  ///
  /// Throws [SybrinException] if no faces are provided, or on SDK failure.
  Future<ScanResult> compareFaces({
    required Uint8List targetFace,
    required List<Uint8List> faces,
  }) async {
    if (faces.isEmpty) {
      throw const SybrinException(
        code: 'NO_FACES',
        message:
            'No captured faces to compare. Please run Liveness Detection first.',
      );
    }
    try {
      final result = await _channel.invokeMethod<Map>('compareFaces', {
        'targetFace': targetFace,
        'faces': faces,
      });
      final confidence =
          (result?['averageConfidence'] as num?)?.toDouble() ?? 0.0;

      return ScanResult(
        type: ScanResultType.faceCompare,
        confidence: confidence,
      );
    } on PlatformException catch (e) {
      throw SybrinException._fromPlatform(e);
    }
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------

  /// Converts the raw [Map] returned by the platform channel into a
  /// typed [ScanResult] for identity scan operations.
  ScanResult _parseIdentityResult(ScanResultType type, Map? raw) {
    final fields = <String, String>{};

    // Every key that is not 'portraitBytes' is treated as an OCR field.
    raw?.forEach((key, value) {
      if (key != 'portraitBytes' && value != null) {
        fields[key.toString()] = value.toString();
      }
    });

    final portraitBytes = raw?['portraitBytes'] as Uint8List?;

    return ScanResult(
      type: type,
      fields: fields,
      portraitBytes: portraitBytes,
    );
  }
}

// ---------------------------------------------------------------------------
// Exception type
// ---------------------------------------------------------------------------

/// Typed exception surfaced by [SybrinChannel] for all SDK failures.
///
/// Wraps a [PlatformException] from the native layer into a Dart-idiomatic
/// exception with a human-readable [message] and an SDK-specific [code].
class SybrinException implements Exception {
  /// Machine-readable error code (e.g. "SCAN_CANCELLED", "SDK_INIT_FAILED").
  final String code;

  /// Human-readable description of what went wrong.
  final String message;

  const SybrinException({required this.code, required this.message});

  factory SybrinException._fromPlatform(PlatformException e) =>
      SybrinException(
        code: e.code,
        message: e.message ?? 'An unexpected SDK error occurred.',
      );

  @override
  String toString() => 'SybrinException($code): $message';
}
