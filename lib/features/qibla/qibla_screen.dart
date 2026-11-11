import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'package:tadapor/core/services/location_service.dart';
import 'package:tadapor/core/theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  double? _heading;

  // إحداثيات الكعبة المشرفة
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
    FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
  }

  void _calculateQibla() {
    final location = context.read<LocationService>();
    final lat = location.latitude;
    final lng = location.longitude;

    if (lat == null || lng == null) return;

    final userLat = _toRadians(lat);
    final userLng = _toRadians(lng);
    final kaabaLatRad = _toRadians(kaabaLat);
    final kaabaLngRad = _toRadians(kaabaLng);

    final deltaLng = kaabaLngRad - userLng;

    final y = math.sin(deltaLng);
    final x = math.cos(userLat) * math.tan(kaabaLatRad) -
        math.sin(userLat) * math.cos(deltaLng);

    var bearing = math.atan2(y, x);
    bearing = _toDegrees(bearing);
    bearing = (bearing + 360) % 360;

    setState(() {
      _qiblaDirection = bearing;
    });
  }

  double _toRadians(double deg) => deg * math.pi / 180;
  double _toDegrees(double rad) => rad * 180 / math.pi;

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
      ),
      body: location.latitude == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('يلزم تحديد الموقع أولاً'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await location.getCurrentLocation();
                      _calculateQibla();
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('تحديد موقعي'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  _qiblaDirection != null
                      ? 'اتجاه القبلة: ${_qiblaDirection!.toStringAsFixed(1)}°'
                      : 'جاري الحساب...',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'موقعك: ${location.latitude!.toStringAsFixed(4)}, ${location.longitude!.toStringAsFixed(4)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // البوصلة
                        Transform.rotate(
                          angle: ((_heading ?? 0) * (math.pi / 180) * -1),
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryGreen, width: 4),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: CompassPainter(),
                            ),
                          ),
                        ),
                        // سهم القبلة
                        if (_qiblaDirection != null && _heading != null)
                          Transform.rotate(
                            angle: ((_qiblaDirection! - _heading!) * (math.pi / 180)),
                            child: const Icon(
                              Icons.navigation,
                              size: 64,
                              color: AppTheme.secondaryGold,
                            ),
                          ),
                        // نقطة المركز
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'وجّه السهم الذهبي نحو الكعبة المشرفة.\nتأكد من وضع الهاتف بشكل أفقي بعيداً عن المعادن.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ),
              ],
            ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final paint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // علامات الاتجاهات
    final textPainter = TextPainter(textDirection: TextDirection.rtl);
    final directions = ['ش', 'ش ق', 'ق', 'ج ق', 'ج', 'ج غ', 'غ', 'ش غ'];
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];

    for (var i = 0; i < directions.length; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * 0.75 * math.sin(angle);
      final y = center.dy - radius * 0.75 * math.cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? AppTheme.secondaryGold : AppTheme.primaryGreen,
          fontSize: i == 0 ? 20 : 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
