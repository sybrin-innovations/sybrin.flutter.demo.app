import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/scan_result.dart';

/// Holds the state of the most recent SDK operation.
///
/// Screens watch this provider to display results without passing
/// data through constructors. Cleared automatically before each new scan
/// so stale data never shows through.
class ScanResultProvider extends ChangeNotifier {
  /// The most recent successful [ScanResult], or `null` if no scan
  /// has completed yet / the result has been cleared.
  ScanResult? _lastResult;

  /// Raw portrait bytes accumulated from identity scans and liveness
  /// checks. Used by the Face Comparison feature as the "faces" list.
  ///
  /// Multiple scans append to this list so [FaceCompare] can contrast
  /// the target against all previously captured selfies.
  final List<Uint8List> capturedFaces = [];

  /// The "target" face that Face Compare should match against.
  ///
  /// Set automatically from the most recent identity scan that produced
  /// a portrait, or from the most recent liveness selfie.
  Uint8List? targetFace;

  /// Whether an SDK call is currently in-flight.
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// The last successful scan result (may be `null`).
  ScanResult? get lastResult => _lastResult;

  /// `true` while an SDK call is executing.
  bool get isLoading => _isLoading;

  /// `true` if there is at least one prior scan result.
  bool get hasResult => _lastResult != null;

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Signals that an SDK call has started. Clears the previous result
  /// and triggers a loading indicator in the UI.
  void beginScan() {
    _isLoading = true;
    _lastResult = null;
    notifyListeners();
  }

  /// Called on a successful SDK response.
  ///
  /// Stores [result] for display and accumulates portrait images for
  /// future face-compare operations.
  void onSuccess(ScanResult result) {
    _isLoading = false;
    _lastResult = result;

    // Keep track of portrait images for face comparison.
    if (result.portraitBytes != null) {
      // The most recently scanned portrait becomes the comparison target.
      targetFace = result.portraitBytes;
      capturedFaces.add(result.portraitBytes!);
    }

    notifyListeners();
  }

  /// Called when an SDK call fails or is cancelled.
  ///
  /// Clears the loading state without setting a result. The error
  /// message is typically handled by a SnackBar in the calling screen.
  void onError() {
    _isLoading = false;
    notifyListeners();
  }

  /// Clears all state (result, loading flag, accumulated faces).
  void reset() {
    _isLoading = false;
    _lastResult = null;
    capturedFaces.clear();
    targetFace = null;
    notifyListeners();
  }
}
