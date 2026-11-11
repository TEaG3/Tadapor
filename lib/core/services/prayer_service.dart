import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadapor/core/constants/app_constants.dart';

class PrayerService extends ChangeNotifier {
  Coordinates? _coordinates;
  CalculationParameters? _params;
  PrayerTimes? _prayerTimes;
  String _methodKey = 'MuslimWorldLeague';
  String _madhabKey = 'Shafi';
  DateTime _selectedDate = DateTime.now();

  Coordinates? get coordinates => _coordinates;
  PrayerTimes? get prayerTimes => _prayerTimes;
  String get methodKey => _methodKey;
  String get madhabKey => _madhabKey;
  DateTime get selectedDate => _selectedDate;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _methodKey = prefs.getString('calc_method') ?? 'MuslimWorldLeague';
    _madhabKey = prefs.getString('madhab') ?? 'Shafi';

    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    if (lat != null && lng != null) {
      setLocation(lat, lng);
    }
  }

  void setLocation(double latitude, double longitude) {
    _coordinates = Coordinates(latitude, longitude);
    _recalculate();
    _saveLocation(latitude, longitude);
  }

  Future<void> setMethod(String methodKey) async {
    _methodKey = methodKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calc_method', methodKey);
    _recalculate();
  }

  Future<void> setMadhab(String madhabKey) async {
    _madhabKey = madhabKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('madhab', madhabKey);
    _recalculate();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    _recalculate();
  }

  void _recalculate() {
    if (_coordinates == null) return;

    _params = _getCalculationParameters(_methodKey);
    _params!.madhab = _madhabKey == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;

    final date = DateComponents.from(_selectedDate);
    _prayerTimes = PrayerTimes(_coordinates!, date, _params!);
    notifyListeners();
  }

  CalculationParameters _getCalculationParameters(String key) {
    switch (key) {
      case 'MuslimWorldLeague':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'Egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'Karachi':
        return CalculationMethod.karachi.getParameters();
      case 'UmmAlQura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'NorthAmerica':
        return CalculationMethod.north_america.getParameters();
      case 'Dubai':
        return CalculationMethod.dubai.getParameters();
      case 'Qatar':
        return CalculationMethod.qatar.getParameters();
      case 'Kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'MoonsightingCommittee':
        return CalculationMethod.moon_sighting_committee.getParameters();
      case 'Singapore':
        return CalculationMethod.singapore.getParameters();
      case 'Turkey':
        return CalculationMethod.turkey.getParameters();
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  Future<void> _saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', lat);
    await prefs.setDouble('lng', lng);
  }

  // الحصول على وقت الصلاة التالية
  Prayer? get nextPrayer {
    if (_prayerTimes == null) return null;
    return _prayerTimes!.nextPrayer();
  }

  DateTime? get nextPrayerTime {
    if (_prayerTimes == null) return null;
    final next = nextPrayer;
    if (next == null) return null;
    return _prayerTimes!.timeForPrayer(next);
  }

  Map<Prayer, DateTime> get allTimes {
    if (_prayerTimes == null) return {};
    return {
      Prayer.fajr: _prayerTimes!.fajr,
      Prayer.sunrise: _prayerTimes!.sunrise,
      Prayer.dhuhr: _prayerTimes!.dhuhr,
      Prayer.asr: _prayerTimes!.asr,
      Prayer.maghrib: _prayerTimes!.maghrib,
      Prayer.isha: _prayerTimes!.isha,
    };
  }

  String getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }
}
