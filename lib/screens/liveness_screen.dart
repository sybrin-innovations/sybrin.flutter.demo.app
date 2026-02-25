import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_result_provider.dart';
import '../services/sybrin_channel.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/section_header.dart';
import 'result_screen.dart';

/// Screen for the Sybrin Passive Liveness Detection SDK feature.
class LivenessScreen extends StatelessWidget {
  const LivenessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanResultProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Liveness Detection')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CI: Biometrics uses Sybrin Blue (#3264FA)
                const SectionHeader(
                  icon: Icons.face_retouching_natural,
                  iconColor: AppTheme.primary,
                  title: 'Passive Liveness Detection',
                  subtitle:
                      'Confirms that the person in front of the camera is a '
                      'live human – not a photo, screen, or mask. '
                      'No gestures required.',
                ),
                const SizedBox(height: 28),

                // ── How it works ────────────────────────────────────
                _InfoCard(
                  items: const [
                    _InfoItem(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera launches automatically',
                      detail:
                          'The Sybrin SDK opens its own camera activity on Android.',
                    ),
                    _InfoItem(
                      icon: Icons.analytics_outlined,
                      title: 'AI analyses the video stream',
                      detail:
                          'Frame-by-frame analysis determines liveness without '
                          'requiring user cooperation.',
                    ),
                    _InfoItem(
                      icon: Icons.check_circle_outline,
                      title: 'Confidence score returned',
                      detail:
                          'A score between 0.0 (spoof) and 1.0 (live) is produced, '
                          'along with a selfie image.',
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Version info card ───────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.onBackgroundMuted,
                                height: 1.4),
                            children: [
                              TextSpan(text: 'SDK version: '),
                              TextSpan(
                                text: 'SybrinLivenessVersion.LIVENESS_V3',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                  text:
                                      '. Uses the latest passive detection model.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Start button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: scanProvider.isLoading
                        ? null
                        : () => _startLiveness(context),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Start Liveness Check'),
                  ),
                ),
              ],
            ),
          ),

          if (scanProvider.isLoading)
            const LoadingOverlay(message: 'Running liveness detection…'),
        ],
      ),
    );
  }

  Future<void> _startLiveness(BuildContext context) async {
    final scanProvider = context.read<ScanResultProvider>();
    scanProvider.beginScan();

    try {
      final result = await SybrinChannel.instance.startLiveness();
      scanProvider.onSuccess(result);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    } on SybrinException catch (e) {
      scanProvider.onError();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CI Blue icon tint
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(items[i].icon,
                        size: 18, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onBackground,
                            )),
                        const SizedBox(height: 2),
                        Text(items[i].detail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.onBackgroundMuted,
                              height: 1.4,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String detail;
  const _InfoItem(
      {required this.icon, required this.title, required this.detail});
}
