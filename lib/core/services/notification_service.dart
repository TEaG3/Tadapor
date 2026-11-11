import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadapor/core/services/adhan_service.dart';
import 'package:tadapor/core/services/prayer_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  // معرفات الإشعارات لكل صلاة
  static const Map<Prayer, int> _prayerIds = {
    Prayer.fajr: 1001,
    Prayer.dhuhr: 1002,
    Prayer.asr: 1003,
    Prayer.maghrib: 1004,
    Prayer.isha: 1005,
  };

  Future<void> init() async {
    if (_initialized) return;

    // تهيئة المناطق الزمنية
    tz_data.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Timezone error: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // قناة الإشعارات الخاصة بالصلاة (أندرويد)
    const androidChannel = AndroidNotificationChannel(
      'prayer_adhan_channel',
      'الأذان ومواقيت الصلاة',
      description: 'تنبيهات صوتية عند حلول وقت الصلاة',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      // اسم الملف بدون امتداد من res/raw/
      sound: RawResourceAndroidNotificationSound('adhan'),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // طلب الأذونات
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // طلب إذن الإشعارات الدقيقة (Exact Alarms) على أندرويد 12+
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    await AdhanService.instance.init();

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    // يعمل في الخلفية
  }

  void _onNotificationTapped(NotificationResponse response) {
    // عند الضغط على الإشعار: تشغيل الأذان داخل التطبيق
    if (response.payload != null && response.payload!.startsWith('prayer_')) {
      AdhanService.instance.play();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (!enabled) {
      await cancelAllPrayerNotifications();
    }
  }

  /// جدولة إشعارات كل الصلوات لعدد أيام قادمة
  Future<void> scheduleAllPrayers(PrayerService prayerService, {int days = 7}) async {
    if (!_notificationsEnabled) return;
    if (prayerService.coordinates == null) return;

    await cancelAllPrayerNotifications();

    final now = DateTime.now();
    final prayersToNotify = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    for (int dayOffset = 0; dayOffset < days; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final dateComponents = DateComponents.from(date);

      // حساب المواقيت لهذا اليوم
      final params = _getParams(prayerService);
      final times = PrayerTimes(
        prayerService.coordinates!,
        dateComponents,
        params,
      );

      for (final prayer in prayersToNotify) {
        final time = times.timeForPrayer(prayer);
        if (time == null) continue;

        // تخطي الأوقات الماضية
        if (time.isBefore(now)) continue;

        final id = _prayerIds[prayer]! + (dayOffset * 10);
        final name = prayerService.getPrayerName(prayer);

        await _scheduleSingle(
          id: id,
          title: 'حان وقت صلاة $name',
          body: 'حي على الصلاة، حي على الفلاح',
          scheduledTime: time,
          payload: 'prayer_${prayer.name}',
        );
      }
    }

    debugPrint('تم جدولة إشعارات الصلاة لـ $days أيام');
  }

  CalculationParameters _getParams(PrayerService service) {
    // نعيد استخدام نفس منطق PrayerService عبر القيم المحفوظة
    // للتبسيط نستخدم الطريقة الافتراضية إن لم نتمكن من الوصول المباشر
    CalculationParameters params;
    switch (service.methodKey) {
      case 'Egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'Karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'UmmAlQura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'NorthAmerica':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'Dubai':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'Qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'Kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'Turkey':
        params = CalculationMethod.turkey.getParameters();
        break;
      default:
        params = CalculationMethod.muslim_world_league.getParameters();
    }
    params.madhab = service.madhabKey == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;
    return params;
  }

  Future<void> _scheduleSingle({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_adhan_channel',
      'الأذان ومواقيت الصلاة',
      channelDescription: 'تنبيهات صوتية عند حلول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      // الملف يجب أن يكون في android/app/src/main/res/raw/adhan.mp3
      sound: const RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(body),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan.aiff', // ضع الملف في ios/Runner إذا أردت صوتاً مخصصاً
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('فشل جدولة الإشعار $id: $e');
    }
  }

  Future<void> cancelAllPrayerNotifications() async {
    // إلغاء نطاق المعرفات المستخدمة
    for (int day = 0; day < 14; day++) {
      for (final baseId in _prayerIds.values) {
        await _plugin.cancel(baseId + (day * 10));
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// إشعار فوري للاختبار
  Future<void> showTestAdhanNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_adhan_channel',
      'الأذان ومواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      9999,
      'اختبار الأذان',
      'هذا إشعار تجريبي لصوت الأذان',
      details,
      payload: 'prayer_test',
    );

    // تشغيل الصوت داخل التطبيق أيضاً
    await AdhanService.instance.play();
  }
}
