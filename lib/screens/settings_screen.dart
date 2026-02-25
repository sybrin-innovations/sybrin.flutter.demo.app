import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';

/// Settings screen allowing the user to enable or disable individual
/// SDK features at runtime.
///
/// Changes take effect immediately (reflected on the home screen) and
/// are persisted across app restarts via [SharedPreferences].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final flags = settings.flags;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Identity section ────────────────────────────────────
          const _SectionLabel(label: 'Identity Scanning'),
          _FeatureToggle(
            icon: Icons.book_outlined,
            // CI: Identity Verification → Cyan
            iconColor: AppTheme.identityCyan,
            title: 'Green Book',
            description:
                'Enable scanning of the South African old green ID book.',
            value: flags.enableGreenBook,
            onChanged: settings.setGreenBook,
          ),
          _FeatureToggle(
            icon: Icons.travel_explore_outlined,
            iconColor: AppTheme.identityCyan,
            title: 'Passport',
            description: 'Enable South African passport MRZ reading.',
            value: flags.enablePassport,
            onChanged: settings.setPassport,
          ),
          _FeatureToggle(
            icon: Icons.credit_card_outlined,
            iconColor: AppTheme.identityCyan,
            title: 'ID Card',
            description: 'Enable South African Smart ID Card scanning.',
            value: flags.enableIdCard,
            onChanged: settings.setIdCard,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32),
          ),

          // ── Biometrics section ──────────────────────────────────
          const _SectionLabel(label: 'Biometrics'),
          _FeatureToggle(
            icon: Icons.face_retouching_natural,
            // CI: Biometrics → primary Blue
            iconColor: AppTheme.primary,
            title: 'Liveness Detection',
            description:
                'Enable passive liveness detection (no gesture required). '
                'Determines if a real person is present.',
            value: flags.enableLiveness,
            onChanged: settings.setLiveness,
          ),
          _FeatureToggle(
            icon: Icons.compare_arrows_rounded,
            iconColor: AppTheme.primary,
            title: 'Face Comparison',
            description:
                'Enable facial comparison between document portraits and '
                'selfies captured by liveness detection.',
            value: flags.enableFaceCompare,
            onChanged: settings.setFaceCompare,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32),
          ),

          // ── Info footer ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.onBackgroundMuted, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Disabled features are greyed out on the home screen. '
                      'Settings are saved automatically and persist between app launches.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onBackgroundMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── SDK version info ────────────────────────────────────
          const _SectionLabel(label: 'SDK Versions'),
          const _VersionTile(
            label: 'Sybrin Identity SDK',
            version: '2.3.2',
            packageId: 'com.github.sybrin-innovations:sybrin-android-sdk-identity',
          ),
          const _VersionTile(
            label: 'Sybrin Liveness Detection',
            version: '1.6.1',
            packageId:
                'com.github.sybrin-innovations.sybrin-android-sdk-biometrics:livenessdetection',
          ),
          const _VersionTile(
            label: 'Sybrin Facial Comparison',
            version: '1.6.1',
            packageId:
                'com.github.sybrin-innovations.sybrin-android-sdk-biometrics:facialcomparison',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.onBackgroundMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _FeatureToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _FeatureToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.onBackground,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.onBackgroundMuted,
          height: 1.4,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _VersionTile extends StatelessWidget {
  final String label;
  final String version;
  final String packageId;

  const _VersionTile({
    required this.label,
    required this.version,
    required this.packageId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onBackground)),
                  const SizedBox(height: 2),
                  Text(packageId,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.onBackgroundMuted,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.primary.withAlpha(60)),
              ),
              child: Text(
                'v$version',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
