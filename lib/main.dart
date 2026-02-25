import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/scan_result_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// Entry point for the BioID Flutter demo application.
///
/// Bootstraps the two [ChangeNotifier] providers and applies the premium
/// dark theme before rendering [HomeScreen].
void main() async {
  // Ensure Flutter binding is initialised before calling platform channels
  // or async code in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted feature flags from SharedPreferences.
  final settingsProvider = AppSettingsProvider();
  await settingsProvider.load();

  runApp(BioIDApp(settingsProvider: settingsProvider));
}

/// Root widget of the BioID Flutter demo.
///
/// Uses [MultiProvider] to make [AppSettingsProvider] and
/// [ScanResultProvider] available to the entire widget tree.
class BioIDApp extends StatelessWidget {
  final AppSettingsProvider settingsProvider;

  const BioIDApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Feature flag state – controls which UI elements are visible.
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: settingsProvider,
        ),
        // SDK scan result state – shared across all feature screens.
        ChangeNotifierProvider<ScanResultProvider>(
          create: (_) => ScanResultProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'BioID – Sybrin SDK Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}
