import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import 'identity_screen.dart';
import 'liveness_screen.dart';
import 'face_compare_screen.dart';
import 'guided_demo_screen.dart';
import 'settings_screen.dart';

/// Home screen – main landing page of the BioID demo.
///
/// Design follows Sybrin CI Guide 2025 v3.2:
///   - Flat, solid header (no gradients) with white vertical logo
///   - CI accent colours: Cyan for Identity, Blue for Biometrics
///   - Roboto typography, 8 px radius, Dark Grey card surfaces
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final flags = settings.flags;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.background,
            // Flat solid colour – no gradient (CI brief prohibits gradients)
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.background,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // White vertical Sybrin logo
                    Image(
                      image: AssetImage('assets/images/logo_vertical_white.png'),
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SDK Demo',
                      style: TextStyle(
                        color: AppTheme.onBackgroundMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            // Bottom hairline divider when pinned
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppTheme.outline, height: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppTheme.onBackground),
                tooltip: 'Settings',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),

          // ── Section title ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SDK Features',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap a card to launch the corresponding Sybrin SDK module.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.onBackgroundMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Feature cards ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Full KYC Demo (guided flow) ────────────────────
                _GuidedDemoCard(),
                const SizedBox(height: 28),

                // Identity Scanning — single card opens country/document picker
                const _GroupHeader(label: 'Identity Scanning'),
                const SizedBox(height: 10),
                _FeatureCard(
                  icon: Icons.document_scanner_outlined,
                  title: 'Identity Document',
                  description:
                      'Scan passports, ID cards, and other documents from multiple countries.',
                  enabled: true,
                  accentColor: AppTheme.identityCyan,
                  delay: 0,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IdentityScreen()),
                  ),
                ),
                const SizedBox(height: 28),

                // Biometrics
                const _GroupHeader(label: 'Biometrics'),
                const SizedBox(height: 10),
                _FeatureCard(
                  icon: Icons.face_retouching_natural,
                  title: 'Liveness Detection',
                  description:
                      'Passive liveness check – no gestures required. Detects a live person in front of the camera.',
                  enabled: flags.enableLiveness,
                  accentColor: AppTheme.primary,
                  delay: 50,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LivenessScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.compare_arrows_rounded,
                  title: 'Face Comparison',
                  description:
                      'Compares a portrait from a document against selfies captured via Liveness Detection.',
                  enabled: flags.enableFaceCompare,
                  accentColor: AppTheme.primary,
                  delay: 100,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FaceCompareScreen()),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

/// Section group label – minimal, uppercase, muted.
class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.onBackgroundMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(height: 1, color: AppTheme.outline)),
      ],
    );
  }
}

/// Prominent entry point into the end-to-end guided KYC flow.
class _GuidedDemoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 350.ms),
        SlideEffect(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
            duration: 350.ms),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuidedDemoScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.route_outlined,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full KYC Demo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Guided end-to-end flow: Document scan, liveness check, and face comparison.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onBackgroundMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.play_circle_outline_rounded,
                    color: AppTheme.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feature card – flat surface, CI accent colour, subtle animation.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final Color accentColor;
  final int delay;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.accentColor,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 350.ms, delay: delay.ms),
        SlideEffect(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
            duration: 350.ms,
            delay: delay.ms),
      ],
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Flat Dark Grey surface – no gradient
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                // Border only when disabled (signals inactivity)
                border: enabled
                    ? null
                    : Border.all(color: AppTheme.outline, width: 1),
              ),
              child: Row(
                children: [
                  // Icon container – flat tinted square
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onBackgroundMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (enabled) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        color: AppTheme.onBackgroundMuted, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
