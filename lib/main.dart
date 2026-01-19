import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/intro_disclaimer_screen.dart';
import 'screens/home_shell_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/analysis_provider.dart';
import 'features/palmistry/providers/palmistry_provider.dart';
import 'services/auth_service.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // System UI yapılandırması
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EloaApp());
}

class EloaApp extends StatelessWidget {
  const EloaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PurchaseService()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => PalmistryProvider()..loadData()),
      ],
      child: MaterialApp(
        title: 'Eloa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        home: const IntroDisclaimerScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => HomeShellScreen(key: homeShellKey),
          '/category_selection': (context) => const CategorySelectionScreen(),
          '/history': (context) => const HistoryScreen(),
          '/premium': (context) => const PremiumScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
