import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class ActivitySuggestionsCard extends StatelessWidget {
  final String condition;
  final double tempC;
  final double windSpeed;
  final double humidity;
  final bool isNight;

  const ActivitySuggestionsCard({
    super.key,
    required this.condition,
    required this.tempC,
    required this.windSpeed,
    required this.humidity,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = WeatherUtils.getActivitySuggestions(
        condition, tempC, windSpeed, humidity, isNight);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Ideas',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final s = suggestions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: (s['color'] as Color).withOpacity(0.15),
                      border: Border.all(
                        color: (s['color'] as Color).withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (s['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(s['icon'] as IconData,
                              color: s['color'] as Color, size: 18),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            s['text'] as String,
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
