import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_result_provider.dart';
import '../models/scan_result.dart';
import '../theme/app_theme.dart';
import '../widgets/result_field_tile.dart';
import '../widgets/section_header.dart';

/// Displays the result of the most recent SDK operation in a rich,
/// readable format.
///
/// - For identity scans: lists all OCR-extracted fields and shows the
///   portrait photo if available.
/// - For liveness: shows the selfie and confidence score with a gauge.
/// - For face compare: shows the average confidence with colour coding.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.read<ScanResultProvider>().lastResult;

    // Guard – should never be reached in normal flow.
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No result available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(result.type.displayName),
        actions: [
          // Clear result and pop so the user starts fresh.
          TextButton.icon(
            onPressed: () {
              context.read<ScanResultProvider>().onError();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            icon: const Icon(Icons.refresh, size: 18, color: AppTheme.primary),
            label: const Text('New Scan',
                style: TextStyle(color: AppTheme.primary, fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Success banner ──────────────────────────────────────
            _SuccessBanner(type: result.type),
            const SizedBox(height: 24),

            // ── Portrait image (if available) ───────────────────────
            if (result.hasPortrait) ...[
              _PortraitCard(bytes: result.portraitBytes!),
              const SizedBox(height: 24),
            ],

            // ── Liveness verdict (pass / fail) ────────────────────
            if (result.isAlive != null) ...[
              _LivenessVerdict(isAlive: result.isAlive!),
              const SizedBox(height: 24),
            ],

            // ── Confidence gauge (face compare only) ────────────────
            if (result.type == ScanResultType.faceCompare && result.hasConfidence) ...[
              _ConfidenceCard(
                  confidence: result.confidence!,
                  type: result.type),
              const SizedBox(height: 24),
            ],

            // ── OCR field list (identity scans) ─────────────────────
            if (result.fields.isNotEmpty) ...[
              const SectionHeader(
                title: 'Extracted Fields',
                subtitle: 'Fields returned by the Sybrin Identity SDK.',
              ),
              const SizedBox(height: 12),
              ...result.fields.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ResultFieldTile(
                    fieldName: e.key,
                    value: e.value,
                  ),
                ),
              ),
            ],

            // ── Timestamp ───────────────────────────────────────────
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Completed at ${_formatTime(result.timestamp)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.onBackgroundMuted),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SuccessBanner extends StatelessWidget {
  final ScanResultType type;
  const _SuccessBanner({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.success.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.success.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppTheme.success, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Successful',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${type.displayName} completed without errors.',
                  style: const TextStyle(
                    color: AppTheme.onBackgroundMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LivenessVerdict extends StatelessWidget {
  final bool isAlive;
  const _LivenessVerdict({required this.isAlive});

  @override
  Widget build(BuildContext context) {
    final color = isAlive ? AppTheme.success : AppTheme.error;
    final icon = isAlive ? Icons.check_circle : Icons.cancel;
    final label = isAlive ? 'Live Person' : 'Not Live';
    final desc = isAlive
        ? 'The SDK confirmed this is a real, live person.'
        : 'The SDK determined this is not a live person.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color,
                )),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(
                  fontSize: 12, color: AppTheme.onBackgroundMuted, height: 1.4,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitCard extends StatelessWidget {
  final Uint8List bytes;
  const _PortraitCard({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portrait Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.onBackground,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.outline),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final double confidence;
  final ScanResultType type;
  const _ConfidenceCard({required this.confidence, required this.type});

  Color get _color {
    if (confidence >= 0.8) return AppTheme.success;
    if (confidence >= 0.5) return AppTheme.warning;
    return AppTheme.error;
  }

  String get _label {
    if (confidence >= 0.8) return 'High Confidence';
    if (confidence >= 0.5) return 'Medium Confidence';
    return 'Low Confidence';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + label
          Row(
            children: [
              Icon(Icons.verified_outlined, color: _color, size: 20),
              const SizedBox(width: 8),
              Text(
                _label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Large percentage figure
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: _color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // Full-width linear bar — nothing clips the number
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: _color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Average facial similarity score between the two images.',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.onBackgroundMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
