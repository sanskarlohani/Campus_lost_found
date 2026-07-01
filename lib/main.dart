import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/firebase_options.dart';
import 'package:unilink/navigation/app_router.dart';
import 'package:unilink/providers/theme_provider.dart';
import 'package:unilink/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show Flutter errors in UI on web to avoid a blank screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Flutter error:\n\n'
              '${details.exceptionAsString()}\n\n'
              '${details.stack}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  };

  try {
    // Initialize Firebase for all platforms (including web)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      const ProviderScope(
        child: UniLinkApp(),
      ),
    );
  } catch (e, st) {
    // If initialization fails, render a minimal error screen instead of a blank page
    // and also log to console.
    // ignore: avoid_print
    print('Firebase initialization failed: $e\n$st');
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Startup error')), 
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                'Firebase initialization failed:\n\n$e\n\n$st',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class UniLinkApp extends ConsumerWidget {
  const UniLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'UniLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
