import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Visual chip indicating whether a feature is currently enabled or disabled.
///
/// Enabled  → CI Digital Onboarding Green (#28DC78)
/// Disabled → CI Grey (#B2B2BC)
class StatusBadge extends StatelessWidget {
  final bool enabled;
  const StatusBadge({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final colour = enabled ? AppTheme.success : AppTheme.onBackgroundMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colour.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colour.withAlpha(90), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colour),
          ),
          const SizedBox(width: 5),
          Text(
            enabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colour,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
