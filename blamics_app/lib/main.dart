import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage for offline caching
  await Hive.initFlutter();
  await Hive.openBox('blamics_cache');

  runApp(
    const ProviderScope(
      child: BlamicsApp(),
    ),
  );
}

class BlamicsApp extends StatelessWidget {
  const BlamicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLAMICS Terminal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
