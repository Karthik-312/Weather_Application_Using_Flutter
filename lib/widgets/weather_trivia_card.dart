import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class WeatherTriviaCard extends StatefulWidget {
  const WeatherTriviaCard({super.key});

  @override
  State<WeatherTriviaCard> createState() => _WeatherTriviaCardState();
}

class _WeatherTriviaCardState extends State<WeatherTriviaCard> {
  String _currentFact = WeatherUtils.getRandomTrivia();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() => _currentFact = WeatherUtils.getRandomTrivia());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          setState(() => _currentFact = WeatherUtils.getRandomTrivia()),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb_outline_rounded,
                  color: Colors.amber, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Did You Know?',
                      style: GoogleFonts.poppins(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _currentFact,
                      key: ValueKey(_currentFact),
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Tap for another fact',
                      style: GoogleFonts.poppins(
                          color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
