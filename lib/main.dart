import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'screens/intro_disclaimer_screen.dart';
import 'screens/home_shell_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/history_screen.dart';
import 'providers/analysis_provider.dart';
import 'features/palmistry/providers/palmistry_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
          '/home': (context) => HomeShellScreen(key: homeShellKey),
          '/category_selection': (context) => const CategorySelectionScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}
