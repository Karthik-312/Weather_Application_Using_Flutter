import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class AirQualityScreen extends StatelessWidget {
  final Map<String, dynamic> airQualityData;
  final int aqi;
  final String cityName;

  const AirQualityScreen({
    super.key,
    required this.airQualityData,
    required this.aqi,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final color = WeatherUtils.getAQIColor(aqi);
    final label = WeatherUtils.getAQILabel(aqi);

    final pollutants = {
      'pm2_5': {'name': 'PM2.5', 'max': 75.0, 'unit': 'μg/m³'},
      'pm10': {'name': 'PM10', 'max': 150.0, 'unit': 'μg/m³'},
      'o3': {'name': 'Ozone (O₃)', 'max': 180.0, 'unit': 'μg/m³'},
      'no2': {'name': 'NO₂', 'max': 200.0, 'unit': 'μg/m³'},
      'so2': {'name': 'SO₂', 'max': 350.0, 'unit': 'μg/m³'},
      'co': {'name': 'CO', 'max': 15000.0, 'unit': 'μg/m³'},
      'nh3': {'name': 'NH₃', 'max': 200.0, 'unit': 'μg/m³'},
      'no': {'name': 'NO', 'max': 100.0, 'unit': 'μg/m³'},
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Air Quality',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    border: Border.all(color: color, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$aqi',
                          style: GoogleFonts.poppins(
                            color: color,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                              color: color, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cityName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    WeatherUtils.getAQIDescription(aqi),
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pollutant Breakdown',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...pollutants.entries.map((entry) {
                  final key = entry.key;
                  final info = entry.value;
                  final value =
                      (airQualityData[key] ?? 0 as num).toDouble();
                  final maxVal = info['max'] as double;
                  final progress = (value / maxVal).clamp(0.0, 1.0);

                  Color barColor;
                  if (progress < 0.25) {
                    barColor = const Color(0xFF4CAF50);
                  } else if (progress < 0.5) {
                    barColor = const Color(0xFFFFC107);
                  } else if (progress < 0.75) {
                    barColor = const Color(0xFFFF9800);
                  } else {
                    barColor = const Color(0xFFF44336);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                info['name'] as String,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${value.toStringAsFixed(1)} ${info['unit']}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  Colors.white.withOpacity(0.08),
                              color: barColor,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety_rounded,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Health Recommendations',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ..._getHealthRecommendations(aqi).map(
                        (rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(rec['icon'] as IconData,
                                  color: Colors.white54, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  rec['text'] as String,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getHealthRecommendations(int aqi) {
    switch (aqi) {
      case 1:
        return [
          {'icon': Icons.directions_run, 'text': 'Air quality is ideal for outdoor activities.'},
          {'icon': Icons.window, 'text': 'Open your windows to let in fresh air.'},
        ];
      case 2:
        return [
          {'icon': Icons.directions_walk, 'text': 'Moderate outdoor activities are fine for most people.'},
          {'icon': Icons.masks, 'text': 'Sensitive individuals may consider wearing a mask.'},
        ];
      case 3:
        return [
          {'icon': Icons.warning_amber, 'text': 'Reduce prolonged outdoor exertion.'},
          {'icon': Icons.masks, 'text': 'Consider wearing a mask outdoors.'},
          {'icon': Icons.child_care, 'text': 'Children and elderly should limit outdoor time.'},
        ];
      case 4:
        return [
          {'icon': Icons.home, 'text': 'Avoid outdoor activities when possible.'},
          {'icon': Icons.masks, 'text': 'Wear an N95 mask if you must go outside.'},
          {'icon': Icons.air, 'text': 'Use an air purifier indoors.'},
        ];
      case 5:
        return [
          {'icon': Icons.dangerous, 'text': 'Stay indoors with all windows closed.'},
          {'icon': Icons.air, 'text': 'Use an air purifier if available.'},
          {'icon': Icons.local_hospital, 'text': 'Seek medical help if you experience symptoms.'},
        ];
      default:
        return [
          {'icon': Icons.info_outline, 'text': 'No specific recommendations available.'},
        ];
    }
  }
}
