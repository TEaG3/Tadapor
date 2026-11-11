import 'package:flutter/material.dart';
import 'package:tadapor/core/theme/app_theme.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  // قائمة السور (يمكن استبدالها لاحقاً بمصدر كامل)
  static const List<Map<String, dynamic>> surahs = [
    {'number': 1, 'name': 'الفاتحة', 'ayahs': 7, 'type': 'مكية'},
    {'number': 2, 'name': 'البقرة', 'ayahs': 286, 'type': 'مدنية'},
    {'number': 3, 'name': 'آل عمران', 'ayahs': 200, 'type': 'مدنية'},
    {'number': 4, 'name': 'النساء', 'ayahs': 176, 'type': 'مدنية'},
    {'number': 5, 'name': 'المائدة', 'ayahs': 120, 'type': 'مدنية'},
    {'number': 6, 'name': 'الأنعام', 'ayahs': 165, 'type': 'مكية'},
    {'number': 7, 'name': 'الأعراف', 'ayahs': 206, 'type': 'مكية'},
    {'number': 8, 'name': 'الأنفال', 'ayahs': 75, 'type': 'مدنية'},
    {'number': 9, 'name': 'التوبة', 'ayahs': 129, 'type': 'مدنية'},
    {'number': 10, 'name': 'يونس', 'ayahs': 109, 'type': 'مكية'},
    {'number': 18, 'name': 'الكهف', 'ayahs': 110, 'type': 'مكية'},
    {'number': 36, 'name': 'يس', 'ayahs': 83, 'type': 'مكية'},
    {'number': 55, 'name': 'الرحمن', 'ayahs': 78, 'type': 'مدنية'},
    {'number': 67, 'name': 'الملك', 'ayahs': 30, 'type': 'مكية'},
    {'number': 78, 'name': 'النبأ', 'ayahs': 40, 'type': 'مكية'},
    {'number': 112, 'name': 'الإخلاص', 'ayahs': 4, 'type': 'مكية'},
    {'number': 113, 'name': 'الفلق', 'ayahs': 5, 'type': 'مكية'},
    {'number': 114, 'name': 'الناس', 'ayahs': 6, 'type': 'مكية'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
      ),
      body: Column(
        children: [
          // شريط البحث السريع
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      child: Text(
                        '${surah['number']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      surah['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('${surah['ayahs']} آية • ${surah['type']}'),
                    trailing: const Icon(Icons.play_circle_outline, color: AppTheme.primaryGreen),
                    onTap: () {
                      // لاحقاً: فتح صفحة السورة مع النص والصوت
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('قريباً: عرض سورة ${surah['name']} مع التلاوة'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // ملاحظة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppTheme.secondaryGold.withOpacity(0.15),
            child: const Text(
              'ملاحظة: يمكن ربط التطبيق بمكتبة قرآن نصية وصوتية موثوقة (مثل everyayah أو API quran.com) لاحقاً',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
