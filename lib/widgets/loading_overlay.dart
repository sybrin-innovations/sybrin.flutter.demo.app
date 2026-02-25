import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A loading overlay that dims the screen and shows a centred progress
/// indicator while an SDK call is in-flight.
///
/// Wrap any widget that may trigger a long-running operation:
///
/// ```dart
/// Stack(children: [
///   MyContent(),
///   if (isLoading) const LoadingOverlay(message: 'Scanning document…'),
/// ])
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Optional message displayed beneath the spinner.
  final String message;

  const LoadingOverlay({
    super.key,
    this.message = 'Processing…',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(153), // ~60% opacity
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onBackground,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
