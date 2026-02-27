import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/identity_catalog.dart';
import '../providers/scan_result_provider.dart';
import '../services/sybrin_channel.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';
import 'result_screen.dart';

/// Dynamic identity document scanner.
///
/// Step 1: pick a country (with flag emoji).
/// Step 2: pick a document from that country's supported list.
/// Step 3: scan.
class IdentityScreen extends StatefulWidget {
  /// Pass a pre-selected document enum to skip straight to the scan button.
  final String? preselectedDocEnum;

  const IdentityScreen({super.key, this.preselectedDocEnum, int initialTab = 0});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  late CountryEntry _country;
  late DocEntry _doc;

  @override
  void initState() {
    super.initState();
    // Default: South Africa → ID Card
    _country = kIdentityCatalog.first;

    if (widget.preselectedDocEnum != null) {
      // Find the country + doc matching the preselected enum
      for (final c in kIdentityCatalog) {
        final match = c.documents.where((d) => d.docEnum == widget.preselectedDocEnum).firstOrNull;
        if (match != null) {
          _country = c;
          _doc = match;
          return;
        }
      }
    }
    _doc = _country.documents.first;
  }

  void _onCountryChanged(CountryEntry c) {
    setState(() {
      _country = c;
      _doc = c.documents.first;
    });
  }

  Future<void> _scan(BuildContext context) async {
    final scanProvider = context.read<ScanResultProvider>();
    scanProvider.beginScan();
    try {
      final result = await SybrinChannel.instance.scanDocument(_doc.docEnum);
      scanProvider.onSuccess(result);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
      }
    } on SybrinException catch (e) {
      scanProvider.onError();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ScanResultProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Identity Scanning')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Country picker ──────────────────────────────────
                _Label('Country'),
                const SizedBox(height: 8),
                _CountryPicker(
                  selected: _country,
                  onChanged: _onCountryChanged,
                ),
                const SizedBox(height: 20),

                // ── Document picker ─────────────────────────────────
                _Label('Document Type'),
                const SizedBox(height: 8),
                _DocPicker(
                  country: _country,
                  selected: _doc,
                  onChanged: (d) => setState(() => _doc = d),
                ),
                const SizedBox(height: 28),

                // ── Scan button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : () => _scan(context),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text('Scan ${_doc.label}'),
                  ),
                ),
              ].animate(interval: 60.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0),
            ),
          ),
          if (isLoading) const LoadingOverlay(message: 'Scanning document…'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700,
      letterSpacing: 1.5, color: AppTheme.onBackgroundMuted,
    ),
  );
}

/// Tappable card that opens a bottom-sheet country list.
class _CountryPicker extends StatelessWidget {
  final CountryEntry selected;
  final ValueChanged<CountryEntry> onChanged;
  const _CountryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.identityCyan.withAlpha(80)),
        ),
        child: Row(
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(selected.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.onBackground)),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.onBackgroundMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet<CountryEntry>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _CountrySheet(selected: selected, onSelected: (c) { Navigator.pop(context); onChanged(c); }),
    );
  }
}

class _CountrySheet extends StatelessWidget {
  final CountryEntry selected;
  final ValueChanged<CountryEntry> onSelected;
  const _CountrySheet({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Country', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.onBackgroundMuted)),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: kIdentityCatalog.map((c) {
              final isSelected = c.name == selected.name;
              return ListTile(
                leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                title: Text(c.name, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? AppTheme.identityCyan : AppTheme.onBackground)),
                trailing: isSelected ? const Icon(Icons.check, color: AppTheme.identityCyan, size: 18) : null,
                onTap: () => onSelected(c),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Grid of document type chips.
class _DocPicker extends StatelessWidget {
  final CountryEntry country;
  final DocEntry selected;
  final ValueChanged<DocEntry> onChanged;
  const _DocPicker({required this.country, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: country.documents.map((doc) {
        final isSelected = doc.docEnum == selected.docEnum;
        return GestureDetector(
          onTap: () => onChanged(doc),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.identityCyan.withAlpha(25) : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.identityCyan : AppTheme.outline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              doc.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.identityCyan : AppTheme.onBackgroundMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
