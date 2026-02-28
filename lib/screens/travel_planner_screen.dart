import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class TravelPlannerScreen extends StatefulWidget {
  const TravelPlannerScreen({super.key});

  @override
  State<TravelPlannerScreen> createState() => _TravelPlannerScreenState();
}

class _TravelPlannerScreenState extends State<TravelPlannerScreen> {
  final _cityController = TextEditingController();
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecastData;
  bool _isLoading = false;
  String? _error;
  String _destination = '';

  Future<void> _searchDestination() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _destination = city;
    });

    try {
      final results = await Future.wait([
        WeatherService.fetchCurrentWeather(city),
        WeatherService.fetchForecast(city),
      ]);
      _currentWeather = results[0];
      _forecastData = results[1];
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Travel Planner',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      const Icon(Icons.flight_takeoff_rounded,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Where are you traveling?',
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.white30, fontSize: 15),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _searchDestination(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search_rounded,
                            color: Colors.white54),
                        onPressed: _searchDestination,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Colors.white54),
                  ))
                else if (_error != null)
                  GlassContainer(
                    child: Text(_error!,
                        style: GoogleFonts.poppins(
                            color: Colors.redAccent, fontSize: 14)),
                  )
                else if (_currentWeather != null) ...[
                  _buildCurrentConditions(),
                  const SizedBox(height: 20),
                  _buildForecastSection(),
                  const SizedBox(height: 20),
                  _buildPackingSuggestions(),
                ] else
                  _buildPlaceholder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.luggage_rounded,
                size: 80, color: Colors.white.withOpacity(0.12)),
            const SizedBox(height: 16),
            Text('Plan your trip',
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 18)),
            Text(
              'Search a destination to see the\n5-day forecast and packing tips',
              style: GoogleFonts.poppins(
                  color: Colors.white24, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentConditions() {
    final w = _currentWeather!;
    final tempC =
        ((w['main']['temp'] as num).toDouble() - 273.15).round();
    final condition = w['weather'][0]['main'] as String;
    final desc = WeatherUtils.capitalizeWords(
        w['weather'][0]['description'] ?? '');
    final icon = WeatherUtils.getWeatherIcon(condition);
    final country = w['sys']?['country'] ?? '';
    final gradient = WeatherUtils.getWeatherGradient(condition, false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [gradient.first.withOpacity(0.6), gradient.last.withOpacity(0.3)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.white60, size: 18),
              const SizedBox(width: 6),
              Text(
                '$_destination, $country',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, size: 52, color: Colors.white),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$tempC°C',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w300)),
                  Text('Currently: $desc',
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    if (_forecastData == null) return const SizedBox.shrink();
    final grouped = WeatherUtils.groupForecastByDay(
        _forecastData!['list'] as List<dynamic>);
    final days = grouped.entries.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text('5-Day Forecast',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        GlassContainer(
          child: Column(
            children: days.asMap().entries.map((entry) {
              final dayData = entry.value.value;
              final date = DateTime.parse(entry.value.key);
              final dayName = entry.key == 0
                  ? 'Today'
                  : DateFormat.EEEE().format(date);

              double high = -999, low = 999;
              String mainCond = dayData[0]['weather'][0]['main'];
              double totalPop = 0;

              for (var item in dayData) {
                double temp = (item['main']['temp'] as num).toDouble();
                if (temp > high) high = temp;
                if (temp < low) low = temp;
                totalPop += ((item['pop'] ?? 0) as num).toDouble();
              }
              double avgPop = totalPop / dayData.length;
              final icon = WeatherUtils.getWeatherIcon(mainCond);
              final highC = (high - 273.15).round();
              final lowC = (low - 273.15).round();

              return Column(
                children: [
                  if (entry.key > 0)
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(dayName.length > 6 ? dayName.substring(0, 3) : dayName,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 13)),
                        ),
                        Icon(icon, color: Colors.white60, size: 20),
                        const SizedBox(width: 8),
                        if (avgPop > 0.1)
                          Text('${(avgPop * 100).round()}%',
                              style: GoogleFonts.poppins(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 11)),
                        const Spacer(),
                        Text('$lowC°',
                            style: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 13)),
                        const SizedBox(width: 6),
                        Text('$highC°',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPackingSuggestions() {
    if (_forecastData == null) return const SizedBox.shrink();

    final list = _forecastData!['list'] as List<dynamic>;
    final suggestions = <Map<String, dynamic>>[];

    bool hasRain = false, hasCold = false, hasHot = false;
    bool hasSun = false, hasSnow = false, hasWind = false;

    for (var item in list) {
      final cond = item['weather'][0]['main'].toString().toLowerCase();
      final temp = (item['main']['temp'] as num).toDouble() - 273.15;
      final wind = (item['wind']['speed'] as num).toDouble();

      if (cond == 'rain' || cond == 'drizzle' || cond == 'thunderstorm') {
        hasRain = true;
      }
      if (cond == 'snow') hasSnow = true;
      if (cond == 'clear') hasSun = true;
      if (temp < 10) hasCold = true;
      if (temp > 30) hasHot = true;
      if (wind > 8) hasWind = true;
    }

    if (hasRain) {
      suggestions.add({
        'icon': Icons.umbrella_rounded,
        'text': 'Pack an umbrella and waterproof jacket',
      });
    }
    if (hasSnow) {
      suggestions.add({
        'icon': Icons.ac_unit_rounded,
        'text': 'Pack warm boots and thermal layers',
      });
    }
    if (hasCold) {
      suggestions.add({
        'icon': Icons.checkroom_rounded,
        'text': 'Bring warm clothing — jacket, scarf, gloves',
      });
    }
    if (hasHot) {
      suggestions.add({
        'icon': Icons.wb_sunny_rounded,
        'text': 'Pack light clothing and stay hydrated',
      });
    }
    if (hasSun) {
      suggestions.add({
        'icon': Icons.beach_access_rounded,
        'text': 'Bring sunscreen, sunglasses, and a hat',
      });
    }
    if (hasWind) {
      suggestions.add({
        'icon': Icons.air_rounded,
        'text': 'Expect windy conditions — pack a windbreaker',
      });
    }
    if (suggestions.isEmpty) {
      suggestions.add({
        'icon': Icons.check_circle_outline,
        'text': 'Mild weather expected — pack comfortable clothing',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.luggage_rounded,
                color: Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text('Packing Suggestions',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s['icon'] as IconData,
                          color: Colors.white60, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s['text'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
