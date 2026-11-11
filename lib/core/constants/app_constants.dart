class AppConstants {
  static const String appName = 'تَدَبُّر';
  static const String appNameEn = 'Tadapor';

  // طرق حساب المواقيت (مذاهب أهل السنة والجماعة فقط)
  static const Map<String, String> calculationMethods = {
    'MuslimWorldLeague': 'رابطة العالم الإسلامي',
    'Egyptian': 'الهيئة المصرية العامة للمساحة',
    'Karachi': 'جامعة العلوم الإسلامية كراتشي',
    'UmmAlQura': 'جامعة أم القرى - مكة',
    'NorthAmerica': 'الجمعية الإسلامية لشمال أمريكا (ISNA)',
    'Dubai': 'دبي',
    'Qatar': 'قطر',
    'Kuwait': 'الكويت',
    'MoonsightingCommittee': 'لجنة رؤية الهلال',
    'Singapore': 'سنغافورة',
    'Turkey': 'تركيا (ديانت)',
  };

  // المذاهب الفقهية السنية
  static const Map<String, String> madhabs = {
    'Shafi': 'الشافعي',
    'Hanafi': 'الحنفي',
  };

  // أسماء الصلوات
  static const List<String> prayerNames = [
    'الفجر',
    'الشروق',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  static const List<String> prayerNamesEn = [
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];
}
