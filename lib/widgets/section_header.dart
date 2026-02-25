import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A styled section header with an optional subtitle.
///
/// Used at the top of each SDK section to provide visual hierarchy
/// and guide the user through the demo flow.
///
/// Example:
/// ```dart
/// SectionHeader(
///   title: 'Identity Scanning',
///   subtitle: 'Select a document type to scan.',
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// Primary heading text.
  final String title;

  /// Optional secondary descriptor beneath the title.
  final String? subtitle;

  /// Optional leading icon displayed above the title.
  final IconData? icon;

  /// Accent colour for the icon background bubble.
  final Color? iconColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primary).withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor ?? AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onBackgroundMuted,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
