import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/portfolio_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
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
