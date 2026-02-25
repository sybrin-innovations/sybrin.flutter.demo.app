import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Displays a single OCR field extracted from a document scan.
///
/// Used in the result screen to build a readable list of all
/// extracted identity fields (e.g. "Surname → Smith").
class ResultFieldTile extends StatelessWidget {
  /// The field name as returned by the Sybrin SDK (e.g. "Surname").
  final String fieldName;

  /// The extracted value (e.g. "Smith").
  final String value;

  const ResultFieldTile({
    super.key,
    required this.fieldName,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              fieldName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.onBackgroundMuted,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
