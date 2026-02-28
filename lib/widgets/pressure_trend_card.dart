import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class PressureTrendCard extends StatelessWidget {
  final int currentPressure;
  final double pressureChange;

  const PressureTrendCard({
    super.key,
    required this.currentPressure,
    required this.pressureChange,
  });

  @override
  Widget build(BuildContext context) {
    final label = WeatherUtils.getPressureTrendLabel(pressureChange);
    final icon = WeatherUtils.getPressureTrendIcon(pressureChange);
    final color = WeatherUtils.getPressureTrendColor(pressureChange);

    String forecast;
    if (pressureChange > 2) {
      forecast = 'Clear skies likely ahead';
    } else if (pressureChange > 0.5) {
      forecast = 'Weather improving';
    } else if (pressureChange < -2) {
      forecast = 'Storms or rain likely approaching';
    } else if (pressureChange < -0.5) {
      forecast = 'Clouds or rain may develop';
    } else {
      forecast = 'Conditions likely to stay the same';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Pressure Trend',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('$currentPressure hPa',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(label,
                          style: GoogleFonts.poppins(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                    if (pressureChange.abs() > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${pressureChange > 0 ? '+' : ''}${pressureChange.round()} hPa',
                        style: GoogleFonts.poppins(
                            color: Colors.white30, fontSize: 10),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(forecast,
                    style: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
