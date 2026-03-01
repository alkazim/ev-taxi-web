import 'package:flutter/material.dart';
import 'src/theme/app_theme.dart';
import 'src/home/home_page.dart';
import 'src/services/firebase_service.dart';

/// Global notifier — true = V2 theme (green primary + yellow accent), false = Classic theme.
final ValueNotifier<bool> useV2Theme = ValueNotifier(true);

/// Global notifier — true = fully-yellow primary theme (for client preview).
final ValueNotifier<bool> useYellowTheme = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase in the background.
  FirebaseService().initialize().catchError(
    (e) => debugPrint('Firebase init failed: $e'),
  );

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
