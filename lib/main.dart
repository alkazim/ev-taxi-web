import 'package:flutter/material.dart';
import 'src/theme/app_theme.dart';
import 'src/home/home_page.dart';
import 'src/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  // Note: This will fail without valid keys. 
  // It's commented out/handled gracefully in service for now to allow UI demo.
  try {
    await SupabaseService().initialize();
  } catch (e) {
    debugPrint('Supabase init skipped/failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kerala Taxi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
