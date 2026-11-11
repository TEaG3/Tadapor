import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:tadapor/core/constants/app_constants.dart';
import 'package:tadapor/core/services/prayer_service.dart';
import 'package:tadapor/core/services/location_service.dart';
import 'package:tadapor/core/services/notification_service.dart';
import 'package:tadapor/core/services/adhan_service.dart';
import 'package:tadapor/core/theme/app_theme.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Consumer2<PrayerService, LocationService>(
        builder: (context, prayer, location, _) {
          if (location.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prayer.prayerTimes == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('لم يتم تحديد الموقع بعد'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pos = await location.getCurrentLocation();
                      if (pos != null) {
                        prayer.setLocation(pos.latitude, pos.longitude);
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('تحديد موقعي'),
                  ),
                  if (location.error != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        location.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          final times = prayer.allTimes;
          final next = prayer.nextPrayer;
          final hijri = HijriCalendar.now();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // بطاقة التاريخ والصلاة التالية
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.deepGreen],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now()),
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      if (next != null) ...[
                        Text(
                          'الصلاة التالية',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayer.getPrayerName(next),
                          style: const TextStyle(
                            color: AppTheme.secondaryGold,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(prayer.nextPrayerTime!),
                          style: const TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // قائمة المواقيت
                ...times.entries.map((entry) {
                  final isNext = entry.key == next;
                  return _PrayerTimeCard(
                    name: prayer.getPrayerName(entry.key),
                    time: entry.value,
                    isNext: isNext,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final prayer = context.read<PrayerService>();
    final notif = NotificationService.instance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الإعدادات',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // تفعيل الإشعارات
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('تنبيهات الأذان', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('إشعار صوتي عند حلول وقت الصلاة'),
                      value: notif.notificationsEnabled,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (value) async {
                        await notif.setNotificationsEnabled(value);
                        setModalState(() {});
                        if (value) {
                          await notif.scheduleAllPrayers(prayer, days: 7);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تفعيل وجدولة التنبيهات')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(),

                    const Text('طريقة الحساب (مذاهب أهل السنة)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: prayer.methodKey,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: AppConstants.calculationMethods.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          await prayer.setMethod(v);
                          await notif.scheduleAllPrayers(prayer, days: 7);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('المذهب الفقهي', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: prayer.madhabKey,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: AppConstants.madhabs.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          await prayer.setMadhab(v);
                          await notif.scheduleAllPrayers(prayer, days: 7);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // أزرار الاختبار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await AdhanService.instance.play();
                            },
                            icon: const Icon(Icons.volume_up),
                            label: const Text('تجربة الأذان'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await notif.showTestAdhanNotification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم إرسال إشعار تجريبي')),
                                );
                              }
                            },
                            icon: const Icon(Icons.notifications_active),
                            label: const Text('تجربة الإشعار'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await notif.scheduleAllPrayers(prayer, days: 7);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت إعادة جدولة التنبيهات لـ 7 أيام')),
                            );
                          }
                        },
                        icon: const Icon(Icons.schedule),
                        label: const Text('إعادة جدولة التنبيهات الآن'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ملاحظة: ضع ملف adhan.mp3 في assets/audio/\nوعلى أندرويد انسخه إلى android/app/src/main/res/raw/adhan.mp3',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  final String name;
  final DateTime time;
  final bool isNext;

  const _PrayerTimeCard({
    required this.name,
    required this.time,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNext ? AppTheme.primaryGreen : AppTheme.secondaryGold.withOpacity(0.3),
          width: isNext ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: isNext ? AppTheme.primaryGreen : AppTheme.secondaryGold,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext ? AppTheme.primaryGreen : null,
              ),
            ),
          ),
          Text(
            DateFormat('hh:mm a').format(time),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isNext ? AppTheme.primaryGreen : null,
            ),
          ),
        ],
      ),
    );
  }
}
