import 'screens/splash_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Force path_provider registration
    await getApplicationDocumentsDirectory();
    await Hive.initFlutter();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PortfolioProvider()..init()),
        ],
        child: const Juzdan360App(),
      ),
    );
  } catch (e) {
    debugPrint('Initialization error: $e');
    // Fallback if Hive fails
    runApp(const Juzdan360App());
  }
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
