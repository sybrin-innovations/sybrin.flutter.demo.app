import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/scan_result_provider.dart';
import '../services/sybrin_channel.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/section_header.dart';
import 'result_screen.dart';

/// Screen for the Sybrin Facial Comparison SDK feature.
///
/// The user picks two images (target face and a selfie/comparison face)
/// independently from camera or gallery. Once both are selected the
/// "Compare Faces" button becomes active and sends both byte arrays to the
/// native Sybrin Facial Comparison SDK via [SybrinChannel].
class FaceCompareScreen extends StatefulWidget {
  const FaceCompareScreen({super.key});

  @override
  State<FaceCompareScreen> createState() => _FaceCompareScreenState();
}

class _FaceCompareScreenState extends State<FaceCompareScreen> {
  final _picker = ImagePicker();

  Uint8List? _targetBytes;
  Uint8List? _selfieBytes;

  // ── Image picking ──────────────────────────────────────────────────────────

  Future<void> _pick({required bool isTarget}) async {
    final source = await _showSourceSheet();
    if (source == null) return;

    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 92,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();

    setState(() {
      if (isTarget) {
        _targetBytes = bytes;
      } else {
        _selfieBytes = bytes;
      }
    });
  }

  Future<ImageSource?> _showSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppTheme.primary),
              title: const Text('Take a photo',
                  style: TextStyle(color: AppTheme.onBackground)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppTheme.primary),
              title: const Text('Choose from gallery',
                  style: TextStyle(color: AppTheme.onBackground)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Comparison ─────────────────────────────────────────────────────────────

  Future<void> _compare() async {
    final target = _targetBytes;
    final selfie = _selfieBytes;
    if (target == null || selfie == null) return;

    final scanProvider = context.read<ScanResultProvider>();
    scanProvider.beginScan();

    try {
      final result = await SybrinChannel.instance.compareFaces(
        targetFace: target,
        faces: [selfie],
      );
      scanProvider.onSuccess(result);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    } on SybrinException catch (e) {
      scanProvider.onError();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<ScanResultProvider>().isLoading;
    final canCompare =
        _targetBytes != null && _selfieBytes != null && !isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Face Comparison')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  icon: Icons.compare_arrows_rounded,
                  iconColor: AppTheme.primary,
                  title: 'Facial Comparison',
                  subtitle:
                      'Select a reference face and a selfie — from your '
                      'camera or gallery — then tap Compare.',
                ),
                const SizedBox(height: 28),

                // ── Face panels ────────────────────────────────────────
                IntrinsicHeight(
                  child: Row(
                  children: [
                    Expanded(
                      child: _FacePanel(
                        label: 'Reference Face',
                        subtitle: 'ID photo / document portrait',
                        imageBytes: _targetBytes,
                        accentColor: AppTheme.identityCyan,
                        icon: Icons.person_outline,
                        onTap: () => _pick(isTarget: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FacePanel(
                        label: 'Selfie / Probe',
                        subtitle: 'Live face to compare',
                        imageBytes: _selfieBytes,
                        accentColor: AppTheme.primary,
                        icon: Icons.face,
                        onTap: () => _pick(isTarget: false),
                      ),
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Status guidance ────────────────────────────────────
                if (_targetBytes == null || _selfieBytes == null)
                  _Notice(
                    message: _targetBytes == null && _selfieBytes == null
                        ? 'Select both images above to enable comparison.'
                        : _targetBytes == null
                            ? 'Select a reference face to continue.'
                            : 'Select a selfie / probe image to continue.',
                  ),
                const SizedBox(height: 28),

                // ── Compare button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canCompare ? _compare : null,
                    icon: const Icon(Icons.compare),
                    label: const Text('Compare Faces'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Both images are sent directly to the Sybrin SDK for comparison.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            const LoadingOverlay(message: 'Comparing faces…'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

/// Face image panel with tap-to-pick interaction.
class _FacePanel extends StatelessWidget {
  final String label;
  final String subtitle;
  final Uint8List? imageBytes;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _FacePanel({
    required this.label,
    required this.subtitle,
    required this.imageBytes,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasImage ? accentColor.withAlpha(80) : AppTheme.outline,
          ),
        ),
        child: Column(
          children: [
            // Image or placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7)),
              child: hasImage
                  ? AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.memory(
                        imageBytes!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        width: double.infinity,
                        color: accentColor.withAlpha(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon,
                                size: 36,
                                color: accentColor.withAlpha(160)),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select',
                              style: TextStyle(
                                fontSize: 11,
                                color: accentColor.withAlpha(160),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            // Label row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: hasImage
                                ? accentColor
                                : AppTheme.onBackground,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.onBackgroundMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    hasImage
                        ? Icons.check_circle_outline
                        : Icons.add_photo_alternate_outlined,
                    size: 18,
                    color:
                        hasImage ? accentColor : AppTheme.onBackgroundMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String message;
  const _Notice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppTheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.onBackgroundMuted,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
