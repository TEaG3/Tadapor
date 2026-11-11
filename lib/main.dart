import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tadapor/app.dart';
import 'package:tadapor/core/services/notification_service.dart';
import 'package:tadapor/core/services/prayer_service.dart';
import 'package:tadapor/core/services/location_service.dart';
import 'package:tadapor/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // اتجاه الشاشة عمودي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة الخدمات
  await NotificationService.instance.init();
  await LocationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerService()),
        ChangeNotifierProvider(create: (_) => LocationService.instance),
      ],
      child: const TadaporApp(),
    ),
  );
}
