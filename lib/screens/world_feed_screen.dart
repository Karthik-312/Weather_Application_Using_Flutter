import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
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
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAllWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().length < 2) {
        setState(() => _suggestions = []);
        return;
      }
      final results = await WeatherService.searchCities(query);
      if (mounted) setState(() => _suggestions = results);
    });
  }

  void _addSearchedCity(String cityName) {
    if (_worldCities.contains(cityName)) return;
    setState(() {
      _worldCities.insert(0, cityName);
      _suggestions = [];
      _searchController.clear();
    });
    _fetchCityWeather(cityName);
  }

  Future<void> _fetchCityWeather(String city) async {
    try {
      final data = await WeatherService.fetchCurrentWeather(city);
      if (mounted) setState(() => _weatherData[city] = data);
    } catch (_) {}
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
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('World Weather',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: provider.primaryTextColor)),
          actions: [
            Semantics(
              label: 'Refresh world weather',
              child: IconButton(
                icon: Icon(Icons.refresh_rounded,               color: provider.primaryTextColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _weatherData.clear();
                  _fetchAllWeather();
                },
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: provider.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        child: SafeArea(
          child: _isLoading && _weatherData.isEmpty
              ? _buildSkeletonList()
              : RefreshIndicator(
                  onRefresh: () async {
                    _weatherData.clear();
                    await _fetchAllWeather();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlassContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                borderRadius: 16,
                                child: Row(
                                  children: [
                                    const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                        decoration: InputDecoration(
                                          hintText: 'Search city (e.g. Lon, New, Tok...)',
                                          hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: _onSearchChanged,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_suggestions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Column(
                                    children: _suggestions.map((s) {
                                      final name = s['name'] ?? '';
                                      final country = s['country'] ?? '';
                                      final state = s['state'] ?? '';
                                      final subtitle = [if (state.toString().isNotEmpty) state, country].join(', ');
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.location_on_outlined, color: Colors.white38, size: 18),
                                        title: Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                                        subtitle: subtitle.isNotEmpty
                                            ? Text(subtitle, style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11))
                                            : null,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _addSearchedCity(name);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final city = _worldCities[index];
                            final weather = _weatherData[city];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: _buildCityCard(city, weather),
                            );
                          },
                          childCount: _worldCities.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
        ),
      ),
    ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: _WorldSkeletonCard(),
      ),
    );
  }

  Widget _buildCityCard(String city, Map<String, dynamic>? weather) {
    if (weather == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _WorldSkeletonCard(),
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

    return Semantics(
      label: '$city weather: $tempC degrees, $desc',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<WeatherProvider>().searchCity(city);
          },
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
        ),
      ),
    );
  }
}

class _WorldSkeletonCard extends StatefulWidget {
  const _WorldSkeletonCard();

  @override
  State<_WorldSkeletonCard> createState() => _WorldSkeletonCardState();
}

class _WorldSkeletonCardState extends State<_WorldSkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.15, end: 0.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Colors.white.withOpacity(_anim.value);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: c,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_anim.value * 1.5),
                      shape: BoxShape.circle)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 100, height: 14,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(_anim.value * 1.5),
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(
                        width: 70, height: 10,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(_anim.value),
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              Container(
                  width: 48, height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_anim.value * 1.5),
                      borderRadius: BorderRadius.circular(6))),
            ],
          ),
        );
      },
    );
  }
}
