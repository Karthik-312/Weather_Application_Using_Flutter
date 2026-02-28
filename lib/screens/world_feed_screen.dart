import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class WorldFeedScreen extends StatefulWidget {
  const WorldFeedScreen({super.key});

  @override
  State<WorldFeedScreen> createState() => _WorldFeedScreenState();
}

class _WorldFeedScreenState extends State<WorldFeedScreen> {
  final List<String> _worldCities = [
    'London', 'New York', 'Tokyo', 'Paris', 'Dubai',
    'Sydney', 'Singapore', 'Moscow', 'Cairo', 'Toronto',
    'Mumbai', 'Seoul',
  ];

  final Map<String, Map<String, dynamic>> _weatherData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllWeather();
  }

  Future<void> _fetchAllWeather() async {
    setState(() => _isLoading = true);
    for (var city in _worldCities) {
      try {
        final data = await WeatherService.fetchCurrentWeather(city);
        if (mounted) {
          setState(() => _weatherData[city] = data);
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('World Weather',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _weatherData.clear();
              _fetchAllWeather();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading && _weatherData.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white54))
              : RefreshIndicator(
                  onRefresh: () async {
                    _weatherData.clear();
                    await _fetchAllWeather();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _worldCities.length,
                    itemBuilder: (context, index) {
                      final city = _worldCities[index];
                      final weather = _weatherData[city];
                      return _buildCityCard(city, weather);
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCityCard(String city, Map<String, dynamic>? weather) {
    if (weather == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(city,
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 15)),
              const Spacer(),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white30),
              ),
            ],
          ),
        ),
      );
    }

    final tempC =
        ((weather['main']['temp'] as num).toDouble() - 273.15).round();
    final condition = weather['weather'][0]['main'] as String;
    final desc = WeatherUtils.capitalizeWords(
        weather['weather'][0]['description'] ?? '');
    final icon = WeatherUtils.getWeatherIcon(condition);
    final country = weather['sys']?['country'] ?? '';
    final humidity = weather['main']['humidity'];
    final wind = weather['wind']['speed'];
    final gradient = WeatherUtils.getWeatherGradient(condition, false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              gradient.first.withOpacity(0.5),
              gradient.last.withOpacity(0.3),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 44, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$city, $country',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(desc,
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.white38, size: 12),
                      const SizedBox(width: 3),
                      Text('$humidity%',
                          style: GoogleFonts.poppins(
                              color: Colors.white38, fontSize: 11)),
                      const SizedBox(width: 10),
                      Icon(Icons.air, color: Colors.white38, size: 12),
                      const SizedBox(width: 3),
                      Text('$wind m/s',
                          style: GoogleFonts.poppins(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$tempC°',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
