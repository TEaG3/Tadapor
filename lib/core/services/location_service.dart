import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  static final LocationService instance = LocationService._();
  LocationService._();

  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  Future<void> init() async {
    // لا نطلب الموقع تلقائياً عند البدء لتجنب مشاكل الأذونات
  }

  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<Position?> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'خدمة الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'تم رفض إذن الموقع.';
          _isLoading = false;
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _isLoading = false;
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _error = 'فشل الحصول على الموقع: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
