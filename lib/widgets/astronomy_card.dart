import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class AstronomyCard extends StatelessWidget {
  final int sunriseTimestamp;
  final int sunsetTimestamp;

  const AstronomyCard({
    super.key,
    required this.sunriseTimestamp,
    required this.sunsetTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final moon = WeatherUtils.getMoonPhaseInfo(DateTime.now());
    final golden =
        WeatherUtils.getGoldenHour(sunriseTimestamp, sunsetTimestamp);
    final dayLength =
        WeatherUtils.getDayLength(sunriseTimestamp, sunsetTimestamp);
    final sunrise = DateTime.fromMillisecondsSinceEpoch(
        sunriseTimestamp * 1000);
    final sunset = DateTime.fromMillisecondsSinceEpoch(
        sunsetTimestamp * 1000);
    final fmt = DateFormat.jm();

    final now = DateTime.now();
    final isBeforeSunrise = now.isBefore(sunrise);
    final isAfterSunset = now.isAfter(sunset);
    String sunCountdown;
    if (isBeforeSunrise) {
      final diff = sunrise.difference(now);
      sunCountdown =
          'Sunrise in ${diff.inHours}h ${diff.inMinutes % 60}m';
    } else if (isAfterSunset) {
      final tomorrow = sunrise.add(const Duration(days: 1));
      final diff = tomorrow.difference(now);
      sunCountdown =
          'Sunrise in ${diff.inHours}h ${diff.inMinutes % 60}m';
    } else {
      final diff = sunset.difference(now);
      sunCountdown =
          'Sunset in ${diff.inHours}h ${diff.inMinutes % 60}m';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Astronomy',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        GlassContainer(
          child: Column(
            children: [
              // Sun row
              Row(
                children: [
                  _buildInfoBlock(
                    Icons.wb_twilight_rounded,
                    'Sunrise',
                    fmt.format(sunrise),
                    Colors.orangeAccent,
                  ),
                  _buildInfoBlock(
                    Icons.nights_stay_outlined,
                    'Sunset',
                    fmt.format(sunset),
                    Colors.indigoAccent,
                  ),
                  _buildInfoBlock(
                    Icons.schedule_rounded,
                    'Day Length',
                    dayLength,
                    Colors.cyanAccent,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAfterSunset || isBeforeSunrise
                          ? Icons.wb_twilight_rounded
                          : Icons.nights_stay_outlined,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(sunCountdown,
                        style: GoogleFonts.poppins(
                            color: Colors.amber, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Moon phase
        GlassContainer(
          child: Row(
            children: [
              Text(moon['emoji'] as String,
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(moon['name'] as String,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(
                      '${moon['illumination']}% illuminated',
                      style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildMoonPhaseBar(moon['phase'] as double),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Golden hour
        GlassContainer(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.camera_alt_rounded,
                      color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 8),
                  Text('Golden Hour',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _goldenHourSlot(
                      'Morning',
                      '${golden['morningStart']} - ${golden['morningEnd']}',
                      Icons.wb_sunny_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _goldenHourSlot(
                      'Evening',
                      '${golden['eveningStart']} - ${golden['eveningEnd']}',
                      Icons.wb_twilight_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 10)),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMoonPhaseBar(double phase) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: _MoonPhasePainter(phase),
      ),
    );
  }

  Widget _goldenHourSlot(
      String label, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: Colors.orangeAccent.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 16),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white54, fontSize: 10)),
          Text(time,
              style: GoogleFonts.poppins(
                  color: Colors.orangeAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MoonPhasePainter extends CustomPainter {
  final double phase;
  _MoonPhasePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Dark side
    canvas.drawCircle(
        center, radius, Paint()..color = Colors.white12);

    // Illuminated portion
    final path = Path();
    final illumination = phase <= 0.5 ? phase * 2 : (1 - phase) * 2;
    final curveOffset = radius * (1 - illumination * 2).abs();

    if (phase <= 0.5) {
      // Waxing: right side illuminated
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        3.1416,
      );
      path.arcTo(
        Rect.fromCenter(
            center: center,
            width: curveOffset * 2,
            height: radius * 2),
        1.5708,
        phase < 0.25 ? 3.1416 : -3.1416,
        false,
      );
    } else {
      // Waning: left side illuminated
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        1.5708,
        3.1416,
      );
      path.arcTo(
        Rect.fromCenter(
            center: center,
            width: curveOffset * 2,
            height: radius * 2),
        -1.5708,
        phase > 0.75 ? 3.1416 : -3.1416,
        false,
      );
    }

    canvas.drawPath(
      path,
      Paint()..color = Colors.white.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _MoonPhasePainter old) =>
      old.phase != phase;
}
