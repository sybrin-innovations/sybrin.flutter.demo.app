import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/scan_result_provider.dart';
import '../services/sybrin_channel.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/section_header.dart';
import 'result_screen.dart';

/// Screen for all three identity document scanning operations.
///
/// Presents buttons for:
/// - Green Book (SA old ID book)
/// - Passport
/// - Smart ID Card
///
/// Each button is shown or hidden based on [AppSettingsProvider] feature flags
/// and the [initialTab] determines which document type is pre-highlighted
/// when navigating here from the home screen card.
class IdentityScreen extends StatefulWidget {
  /// Which tab to visually highlight on first show:
  /// - 0 → Green Book
  /// - 1 → Passport
  /// - 2 → ID Card
  final int initialTab;

  const IdentityScreen({super.key, this.initialTab = 0});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final flags = context.watch<AppSettingsProvider>().flags;
    final scanProvider = context.watch<ScanResultProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Scanning'),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  icon: Icons.document_scanner_outlined,
                  title: 'Document Scanning',
                  subtitle:
                      'Select a document type below. The Sybrin Identity SDK '
                      'will launch the camera, detect the document, and extract '
                      'all readable fields automatically.',
                ),
                const SizedBox(height: 28),

                // ── Document type selector chips ────────────────────
                Row(
                  children: [
                    if (flags.enableGreenBook)
                      _TypeChip(
                        label: 'Green Book',
                        icon: Icons.book_outlined,
                        selected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    if (flags.enablePassport) ...[
                      const SizedBox(width: 10),
                      _TypeChip(
                        label: 'Passport',
                        icon: Icons.travel_explore_outlined,
                        selected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ],
                    if (flags.enableIdCard) ...[
                      const SizedBox(width: 10),
                      _TypeChip(
                        label: 'ID Card',
                        icon: Icons.credit_card_outlined,
                        selected: _selectedTab == 2,
                        onTap: () => setState(() => _selectedTab = 2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                // ── Description card ────────────────────────────────
                _DocumentDescription(tab: _selectedTab),
                const SizedBox(height: 28),

                // ── Scan button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: scanProvider.isLoading
                        ? null
                        : () => _startScan(context),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Start Scanning'),
                  ),
                ),
                const SizedBox(height: 12),

                // ── If no relevant features are enabled ─────────────
                if (!flags.enableGreenBook &&
                    !flags.enablePassport &&
                    !flags.enableIdCard)
                  _DisabledNotice(
                    message:
                        'All identity scanning features are disabled. '
                        'Enable them in Settings.',
                  ),
              ],
            ),
          ),

          // Loading overlay while SDK is active
          if (scanProvider.isLoading)
            const LoadingOverlay(message: 'Scanning document…'),
        ],
      ),
    );
  }

  /// Determines which SDK call to make based on the selected tab and
  /// dispatches via [SybrinChannel]. Navigates to [ResultScreen] on success,
  /// or shows a [SnackBar] on failure/cancellation.
  Future<void> _startScan(BuildContext context) async {
    final scanProvider = context.read<ScanResultProvider>();
    final channel = SybrinChannel.instance;

    // Signal to the provider that a scan is starting (clears old result).
    scanProvider.beginScan();

    try {
      final result = switch (_selectedTab) {
        0 => await channel.scanGreenBook(),
        1 => await channel.scanPassport(),
        _ => await channel.scanIdCard(),
      };

      scanProvider.onSuccess(result);

      if (context.mounted) {
        // Navigate to the result screen once the state is updated.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    } on SybrinException catch (e) {
      scanProvider.onError();
      if (context.mounted) {
        _showError(context, e.message);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.identityCyan.withAlpha(25)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.identityCyan : AppTheme.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? AppTheme.identityCyan : AppTheme.onBackgroundMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.identityCyan : AppTheme.onBackgroundMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentDescription extends StatelessWidget {
  final int tab;
  const _DocumentDescription({required this.tab});

  // All identity document types use CI Identity Verification Cyan (#32C8FA)
  static const _data = [
    (
      title: 'South African Green Book',
      description:
          'The original South African identity document (before 2013). '
          'The SDK uses OCR to extract the name, surname, ID number, date '
          'of birth, sex, and citizenship status from both pages.',
      icon: Icons.book_outlined,
      color: AppTheme.identityCyan,
    ),
    (
      title: 'South African Passport',
      description:
          'Reads the Machine Readable Zone (MRZ) on the biographic data page '
          'and extracts the portrait photograph. Works with both new and '
          'older SA passport booklets.',
      icon: Icons.travel_explore_outlined,
      color: AppTheme.identityCyan,
    ),
    (
      title: 'Smart ID Card',
      description:
          'The modern South African green-chip card. The SDK captures both '
          'the front and back faces, reading the chip data and extracting '
          'the biometric portrait embedded in the card.',
      icon: Icons.credit_card_outlined,
      color: AppTheme.identityCyan,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final d = _data[tab.clamp(0, 2)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: d.color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: d.color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(d.icon, color: d.color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onBackgroundMuted,
                    height: 1.5,
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

class _DisabledNotice extends StatelessWidget {
  final String message;
  const _DisabledNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppTheme.warning,
                    fontSize: 13,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
