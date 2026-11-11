import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tadapor/core/services/prayer_service.dart';
import 'package:tadapor/core/services/location_service.dart';
import 'package:tadapor/core/services/notification_service.dart';
import 'package:tadapor/core/theme/app_theme.dart';
import 'package:tadapor/features/prayer_times/prayer_times_screen.dart';
import 'package:tadapor/features/athkar/athkar_screen.dart';
import 'package:tadapor/features/qibla/qibla_screen.dart';
import 'package:tadapor/features/quran/quran_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _notificationsScheduled = false;

  final List<Widget> _screens = const [
    PrayerTimesScreen(),
    AthkarScreen(),
    QuranScreen(),
    QiblaScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initLocationAndPrayers();
  }

  Future<void> _initLocationAndPrayers() async {
    final locationService = context.read<LocationService>();
    final prayerService = context.read<PrayerService>();

    await prayerService.init();

    final position = await locationService.getCurrentLocation();
    if (position != null) {
      prayerService.setLocation(position.latitude, position.longitude);
      await _scheduleNotifications(prayerService);
    }
  }

  Future<void> _scheduleNotifications(PrayerService prayerService) async {
    if (_notificationsScheduled) return;
    if (prayerService.prayerTimes == null) return;

    await NotificationService.instance.scheduleAllPrayers(prayerService, days: 7);
    _notificationsScheduled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled),
              label: 'المواقيت',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'الأذكار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories),
              label: 'القرآن',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'القبلة',
            ),
          ],
        ),
      ),
    );
  }
}
