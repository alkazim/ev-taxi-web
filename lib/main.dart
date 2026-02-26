import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/theme/app_theme.dart';
import 'src/home/home_page.dart';
import 'src/services/supabase_service.dart';

/// Global notifier — true = V2 theme (green primary + yellow accent), false = Classic theme.
final ValueNotifier<bool> useV2Theme = ValueNotifier(true);

/// Global notifier — true = fully-yellow primary theme (for client preview).
final ValueNotifier<bool> useYellowTheme = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-warm GoogleFonts so fonts are fetched & cached BEFORE any widget
  // builds. Without this, fonts load mid-render causing a visible layout shift.
  GoogleFonts.poppins();
  GoogleFonts.inter();

  // Initialize Supabase
  // Note: This will fail without valid keys.
  // It's commented out/handled gracefully in service for now to allow UI demo.
  try {
    await SupabaseService().initialize();
  } catch (e) {
    debugPrint('Supabase init skipped/failed: $e');
  }

  // Precache the hero images into Flutter's image cache before the first frame.
  // This ensures the full-bleed background renders instantly without any flicker.
  final binding = WidgetsBinding.instance;
  // We need a temporary BuildContext-like environment — use a PictureRecorder approach
  // by scheduling precache after the first frame.
  binding.addPostFrameCallback((_) async {
    final context = binding.rootElement;
    if (context != null) {
      await Future.wait([
        precacheImage(
          const AssetImage('assets/images/cars/green_taxi_homescreen.webp'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/cars/yellow_taxi_homescreen.webp'),
          context,
        ),
      ]);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: useYellowTheme,
      builder: (context, isYellow, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: useV2Theme,
          builder: (context, isV2, _) {
            ThemeData activeTheme;
            if (isYellow) {
              activeTheme = AppYellowTheme.lightTheme;
            } else if (isV2) {
              activeTheme = AppThemeV2.lightTheme;
            } else {
              activeTheme = AppTheme.lightTheme;
            }
            return MaterialApp(
              title: 'E-CABBZ TAXI',
              debugShowCheckedModeBanner: false,
              theme: activeTheme,
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}
