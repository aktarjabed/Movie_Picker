import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'core/di/dependency_injection.dart';
import 'core/logging/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'core/services/haptic_service.dart';
import 'ui/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase (uncomment if you have firebase_options.dart)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize logger
  AppLogger.init();

  // Create and configure DI container
  final container = await configureDI();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MoviePickerApp(),
    ),
  );
}

class MoviePickerApp extends ConsumerWidget {
  const MoviePickerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CINE.PROTOCOL',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      restorationScopeId: 'app',
      builder: (context, child) {
        // Global error handling
        if (child == null) return const SizedBox.shrink();

        return Banner(
          message: kDebugMode ? 'DEBUG' : 'RELEASE',
          location: BannerLocation.topStart,
          child: child,
        );
      },
    );
  }
}
