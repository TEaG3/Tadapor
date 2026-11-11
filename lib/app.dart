import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tadapor/core/theme/app_theme.dart';
import 'package:tadapor/features/home/home_screen.dart';

class TadaporApp extends StatelessWidget {
  const TadaporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تَدَبُّر',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
