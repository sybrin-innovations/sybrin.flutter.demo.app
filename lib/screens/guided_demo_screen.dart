import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/identity_catalog.dart';
import '../services/sybrin_channel.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';

/// End-to-end guided KYC verification flow.
///
/// Three sequential steps:
///  1. **Scan ID document** – extracts portrait from passport / ID card / green book
///  2. **Liveness Detection** – verifies a real person and captures a selfie
///  3. **Face Comparison** – auto-compares the document portrait against the selfie
///
/// Data flows automatically between steps (no manual image selection needed).
class GuidedDemoScreen extends StatefulWidget {
  const GuidedDemoScreen({super.key});

  @override
  State<GuidedDemoScreen> createState() => _GuidedDemoScreenState();
}

class _GuidedDemoScreenState extends State<GuidedDemoScreen> {
  // ── Step tracking ──────────────────────────────────────────────────
  int _currentStep = 0; // 0 = identity, 1 = liveness, 2 = face compare
  bool _isLoading = false;
  String _loadingMessage = '';

  // ── Document type selection (from catalog) ────────────────────────
  CountryEntry _country = kIdentityCatalog.first;
  late DocEntry _doc = kIdentityCatalog.first.documents.first;

  // ── Captured data flowing between steps ────────────────────────────
  Uint8List? _documentPortrait; // from identity scan
  Map<String, String> _ocrFields = {};
  Uint8List? _selfieBytes; // from liveness
  double? _livenessConfidence;
  double? _faceCompareConfidence;

  static const _steps = [
    'Scan Document',
    'Liveness Check',
    'Face Comparison',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full KYC Demo'),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progress indicator ─────────────────────────────
                _StepIndicator(
                  steps: _steps,
                  currentStep: _currentStep,
                  completedStep: _currentStep > 0 ? _currentStep - 1 : -1,
                ),
                const SizedBox(height: 28),

                // ── Step content ───────────────────────────────────
                if (_currentStep == 0) _buildIdentityStep(),
                if (_currentStep == 1) _buildLivenessStep(),
                if (_currentStep == 2) _buildFaceCompareStep(),
                if (_currentStep == 3) _buildSummary(),
              ],
            ),
          ),
          if (_isLoading) LoadingOverlay(message: _loadingMessage),
        ],
      ),
    );
  }

  // ====================================================================
  // Step 1 — Identity Document Scanning
  // ====================================================================
  Widget _buildIdentityStep() {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(begin: const Offset(0.05, 0), end: Offset.zero, duration: 300.ms),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            step: 1,
            title: 'Scan your ID document',
            subtitle: 'Choose a country and document type. The SDK will extract personal data and a portrait.',
            accentColor: AppTheme.identityCyan,
          ),
          const SizedBox(height: 20),

          // Country picker (simple dropdown for step context)
          _GuidedCountryRow(
            country: _country,
            onChanged: (c) => setState(() { _country = c; _doc = c.documents.first; }),
          ),
          const SizedBox(height: 12),

          // Document chips
          Wrap(
            spacing: 10, runSpacing: 8,
            children: _country.documents.map((d) => GestureDetector(
              onTap: () => setState(() => _doc = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _doc.docEnum == d.docEnum ? AppTheme.identityCyan.withAlpha(25) : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _doc.docEnum == d.docEnum ? AppTheme.identityCyan : AppTheme.outline,
                    width: _doc.docEnum == d.docEnum ? 1.5 : 1,
                  ),
                ),
                child: Text(d.label, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _doc.docEnum == d.docEnum ? AppTheme.identityCyan : AppTheme.onBackgroundMuted,
                )),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _scanDocument,
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text('Scan ${_doc.label}'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDocument() async {
    setState(() { _isLoading = true; _loadingMessage = 'Scanning document…'; });
    try {
      final result = await SybrinChannel.instance.scanDocument(_doc.docEnum);
      setState(() {
        _documentPortrait = result.portraitBytes;
        _ocrFields = result.fields;
        _isLoading = false;
        _currentStep = 1;
      });
    } on SybrinException catch (e) {
      setState(() => _isLoading = false);
      _showError(e.message);
    }
  }

  // ====================================================================
  // Step 2 — Liveness Detection
  // ====================================================================
  Widget _buildLivenessStep() {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(begin: const Offset(0.05, 0), end: Offset.zero, duration: 300.ms),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            step: 2,
            title: 'Verify liveness',
            subtitle:
                'The SDK will open the camera and confirm the person in front '
                'of the device is real — no gestures required.',
            accentColor: AppTheme.primary,
          ),
          const SizedBox(height: 16),

          // Show extracted portrait as confirmation
          if (_documentPortrait != null)
            _DataPreview(
              label: 'Portrait extracted from document',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(_documentPortrait!, height: 120, fit: BoxFit.contain),
              ),
            ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _runLiveness,
              icon: const Icon(Icons.face_retouching_natural),
              label: const Text('Start Liveness Check'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runLiveness() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Running liveness detection…';
    });
    try {
      final result = await SybrinChannel.instance.startLiveness();
      setState(() {
        _selfieBytes = result.portraitBytes;
        _livenessConfidence = result.confidence;
        _isLoading = false;
        _currentStep = 2; // advance to face compare
      });
    } on SybrinException catch (e) {
      setState(() => _isLoading = false);
      _showError(e.message);
    }
  }

  // ====================================================================
  // Step 3 — Face Comparison (auto)
  // ====================================================================
  Widget _buildFaceCompareStep() {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(begin: const Offset(0.05, 0), end: Offset.zero, duration: 300.ms),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            step: 3,
            title: 'Compare faces',
            subtitle:
                'The document portrait and liveness selfie will be '
                'compared automatically using the Sybrin Facial Comparison SDK.',
            accentColor: AppTheme.primary,
          ),
          const SizedBox(height: 16),

          // Show both images side by side
          Row(
            children: [
              Expanded(
                child: _ImageTile(
                  label: 'Document',
                  bytes: _documentPortrait,
                  accent: AppTheme.identityCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImageTile(
                  label: 'Selfie',
                  bytes: _selfieBytes,
                  accent: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_documentPortrait != null && _selfieBytes != null)
                  ? _compareFaces
                  : null,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: const Text('Compare Faces'),
            ),
          ),

          // Show warning if portrait is missing
          if (_documentPortrait == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warning.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No portrait was extracted from the document scan. '
                      'Face comparison requires both images.',
                      style: TextStyle(color: AppTheme.warning, fontSize: 12, height: 1.4),
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

  Future<void> _compareFaces() async {
    if (_documentPortrait == null || _selfieBytes == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Comparing faces…';
    });
    try {
      final result = await SybrinChannel.instance.compareFaces(
        targetFace: _documentPortrait!,
        faces: [_selfieBytes!],
      );
      setState(() {
        _faceCompareConfidence = result.confidence;
        _isLoading = false;
        _currentStep = 3; // advance to summary
      });
    } on SybrinException catch (e) {
      setState(() => _isLoading = false);
      _showError(e.message);
    }
  }

  // ====================================================================
  // Summary — combined result
  // ====================================================================
  Widget _buildSummary() {
    final pct = ((_faceCompareConfidence ?? 0) * 100).toStringAsFixed(1);
    final livenessPct = ((_livenessConfidence ?? 0) * 100).toStringAsFixed(1);
    final matchColor = (_faceCompareConfidence ?? 0) >= 0.8
        ? AppTheme.success
        : (_faceCompareConfidence ?? 0) >= 0.5
            ? AppTheme.warning
            : AppTheme.error;
    final livenessColor = (_livenessConfidence ?? 0) >= 0.8
        ? AppTheme.success
        : (_livenessConfidence ?? 0) >= 0.5
            ? AppTheme.warning
            : AppTheme.error;

    return Animate(
      effects: [
        FadeEffect(duration: 400.ms),
        SlideEffect(begin: const Offset(0, 0.05), end: Offset.zero, duration: 400.ms),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Success banner ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.success.withAlpha(18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.success.withAlpha(80)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppTheme.success, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KYC Verification Complete',
                          style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 15)),
                      SizedBox(height: 2),
                      Text('All three steps completed successfully.',
                          style: TextStyle(color: AppTheme.onBackgroundMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Face images side by side ────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ImageTile(label: 'Document Portrait', bytes: _documentPortrait, accent: AppTheme.identityCyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImageTile(label: 'Liveness Selfie', bytes: _selfieBytes, accent: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Score cards ─────────────────────────────────────────
          _ScoreCard(
            icon: Icons.face_retouching_natural,
            label: 'Liveness Confidence',
            value: '$livenessPct%',
            color: livenessColor,
            description: 'Probability the subject is a live person.',
          ),
          const SizedBox(height: 12),
          _ScoreCard(
            icon: Icons.compare_arrows_rounded,
            label: 'Face Match',
            value: '$pct%',
            color: matchColor,
            description: 'Similarity between document portrait and selfie.',
          ),
          const SizedBox(height: 12),

          // ── OCR fields (collapsed) ─────────────────────────────
          if (_ocrFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                collapsedBackgroundColor: AppTheme.surface,
                backgroundColor: AppTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: Text(
                  'Extracted Fields (${_ocrFields.length})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onBackground),
                ),
                children: [
                  for (final entry in _ocrFields.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 12, color: AppTheme.onBackgroundMuted)),
                          const Spacer(),
                          Flexible(
                            child: Text(entry.value,
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onBackground)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ── Restart button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _currentStep = 0;
                _documentPortrait = null;
                _ocrFields = {};
                _selfieBytes = null;
                _livenessConfidence = null;
                _faceCompareConfidence = null;
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Start New Verification'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// =====================================================================
// Private widgets
// =====================================================================

/// Horizontal step indicator with numbered circles and connecting lines.
class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final int completedStep;
  const _StepIndicator({required this.steps, required this.currentStep, required this.completedStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= currentStep ? AppTheme.primary : AppTheme.outline,
              ),
            ),
          _StepDot(
            index: i,
            label: steps[i],
            isActive: i == currentStep,
            isCompleted: i < currentStep,
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;
  const _StepDot({required this.index, required this.label, required this.isActive, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppTheme.success
        : isActive
            ? AppTheme.primary
            : AppTheme.onBackgroundMuted;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.success : (isActive ? AppTheme.primary : AppTheme.surface),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : color),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final Color accentColor;
  const _StepHeader({required this.step, required this.title, required this.subtitle, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP $step',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: accentColor),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onBackground)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.onBackgroundMuted, height: 1.5)),
      ],
    );
  }
}


class _DataPreview extends StatelessWidget {
  final String label;
  final Widget child;
  const _DataPreview({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.onBackgroundMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Center(child: child),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final Color accent;
  const _ImageTile({required this.label, required this.bytes, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bytes != null ? accent.withAlpha(80) : AppTheme.outline),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            child: bytes != null
                ? AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.memory(bytes!, width: double.infinity, fit: BoxFit.cover),
                  )
                : AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      color: accent.withAlpha(12),
                      child: Icon(Icons.image_not_supported_outlined, size: 28, color: accent.withAlpha(100)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String description;
  const _ScoreCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 11, color: AppTheme.onBackgroundMuted, height: 1.3)),
              ],
            ),
          ),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

/// Compact country row for the guided demo step 1.
class _GuidedCountryRow extends StatelessWidget {
  final CountryEntry country;
  final ValueChanged<CountryEntry> onChanged;
  const _GuidedCountryRow({required this.country, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showModalBottomSheet<CountryEntry>(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: kIdentityCatalog.map((c) => ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(c.name, style: TextStyle(
                    fontWeight: c.name == country.name ? FontWeight.w700 : FontWeight.w400,
                    color: c.name == country.name ? AppTheme.identityCyan : AppTheme.onBackground,
                  )),
                  trailing: c.name == country.name ? const Icon(Icons.check, color: AppTheme.identityCyan, size: 18) : null,
                  onTap: () { Navigator.pop(context); onChanged(c); },
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.identityCyan.withAlpha(80)),
        ),
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(country.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onBackground))),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.onBackgroundMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
