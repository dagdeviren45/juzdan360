import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'providers/portfolio_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent google_fonts from making network requests - use bundled fonts only
  GoogleFonts.config.allowRuntimeFetching = false;

  // Catch all Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  // Catch all uncaught async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformError: $error');
    debugPrint('Stack: $stack');
    return true; // Prevent crash
  };

  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortfolioProvider()..init()),
      ],
      child: const Juzdan360App(),
    ),
  );
}

class Juzdan360App extends StatelessWidget {
  const Juzdan360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juzdan360',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
