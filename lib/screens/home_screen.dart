import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';
import 'package:weather_app/widgets/temperature_chart.dart';
import 'package:weather_app/screens/air_quality_screen.dart';
import 'package:weather_app/screens/favorites_screen.dart';
import 'package:weather_app/screens/settings_screen.dart';
import 'package:weather_app/screens/weather_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _searchCity(WeatherProvider provider) {
    final city = _searchController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }
    provider.searchCity(city);
    setState(() => _showSearch = false);
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final gradient = provider.weatherGradient;
        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: provider.isLoading
                  ? _buildLoadingSkeleton()
                  : provider.error != null
                      ? _buildError(provider)
                      : RefreshIndicator(
                          onRefresh: () => provider.fetchWeather(),
                          color: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: SingleChildScrollView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildAppBar(provider),
                                  if (_showSearch)
                                    _buildSearchBar(provider),
                                  const SizedBox(height: 16),
                                  _buildCurrentWeather(provider),
                                  const SizedBox(height: 28),
                                  _buildHourlyForecast(provider),
                                  const SizedBox(height: 28),
                                  _buildDailyForecast(provider),
                                  const SizedBox(height: 28),
                                  _buildWeatherDetails(provider),
                                  const SizedBox(height: 28),
                                  _buildAirQuality(provider),
                                  const SizedBox(height: 28),
                                  _buildTempChart(provider),
                                  const SizedBox(height: 28),
                                  _buildSuggestions(provider),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }

  // ── App Bar ──
  Widget _buildAppBar(WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                provider.currentCity,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.my_location_rounded,
                color: Colors.white, size: 22),
            onPressed: () => provider.useCurrentLocation(),
            tooltip: 'Use GPS location',
          ),
          IconButton(
            icon: Icon(
              provider.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color:
                  provider.isFavorite ? Colors.redAccent : Colors.white,
              size: 22,
            ),
            onPressed: () => provider.toggleFavorite(),
            tooltip: 'Toggle favorite',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: const Color(0xFF1e1e2e),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'favorites') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FavoritesScreen()));
              } else if (value == 'settings') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (context) => [
              _buildPopupItem(Icons.favorite_rounded, 'Favorite Cities',
                  'favorites'),
              _buildPopupItem(
                  Icons.settings_rounded, 'Settings', 'settings'),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
      IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ── Search Bar ──
  Widget _buildSearchBar(WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        borderRadius: 30,
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white54, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  hintStyle:
                      GoogleFonts.poppins(color: Colors.white38, fontSize: 15),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _searchCity(provider),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white70),
              onPressed: () => _searchCity(provider),
            ),
          ],
        ),
      ),
    );
  }

  // ── Current Weather ──
  Widget _buildCurrentWeather(WeatherProvider provider) {
    final weather = provider.currentWeather!;
    final temp =
        provider.formatTemp((weather['main']['temp'] as num).toDouble());
    final feelsLike = provider
        .formatTemp((weather['main']['feels_like'] as num).toDouble());
    final high = provider
        .formatTemp((weather['main']['temp_max'] as num).toDouble());
    final low = provider
        .formatTemp((weather['main']['temp_min'] as num).toDouble());
    final condition = weather['weather'][0]['main'] as String;
    final description =
        WeatherUtils.capitalizeWords(weather['weather'][0]['description'] ?? '');
    final icon =
        WeatherUtils.getWeatherIcon(condition, isNight: provider.isNight);

    return Center(
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.5 + value * 0.5,
                  child: child,
                ),
              );
            },
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 4),
          Text(
            temp,
            style: GoogleFonts.poppins(
              fontSize: 76,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoChip(Icons.thermostat_outlined, 'Feels $feelsLike'),
              const SizedBox(width: 12),
              _infoChip(Icons.arrow_upward_rounded, 'H: $high'),
              const SizedBox(width: 12),
              _infoChip(Icons.arrow_downward_rounded, 'L: $low'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white60, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Hourly Forecast ──
  Widget _buildHourlyForecast(WeatherProvider provider) {
    final hourly = provider.hourlyForecast;
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Hourly Forecast', Icons.access_time_rounded),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final item = hourly[index];
              final time = DateFormat.Hm().format(
                DateTime.fromMillisecondsSinceEpoch(
                    (item['dt'] as num).toInt() * 1000),
              );
              final temp = provider
                  .formatTemp((item['main']['temp'] as num).toDouble());
              final condition = item['weather'][0]['main'] as String;
              final icon = WeatherUtils.getWeatherIcon(condition);
              final isFirst = index == 0;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GlassContainer(
                  opacity: isFirst ? 0.25 : 0.12,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isFirst ? 'Now' : time,
                        style: GoogleFonts.poppins(
                          color: isFirst ? Colors.white : Colors.white60,
                          fontSize: 13,
                          fontWeight:
                              isFirst ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Icon(icon, color: Colors.white, size: 28),
                      const SizedBox(height: 10),
                      Text(
                        temp,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 5-Day Forecast ──
  Widget _buildDailyForecast(WeatherProvider provider) {
    final daily = provider.dailyForecast;
    if (daily.isEmpty) return const SizedBox.shrink();

    final entries = daily.entries.skip(1).take(5).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('5-Day Forecast', Icons.calendar_month_rounded),
        const SizedBox(height: 12),
        GlassContainer(
          child: Column(
            children: entries.asMap().entries.map((entry) {
              final dayData = entry.value.value;
              final date = DateTime.parse(entry.value.key);
              final dayName = DateFormat.EEEE().format(date);

              double high = -999, low = 999;
              String mainCondition = dayData[0]['weather'][0]['main'];
              double totalPop = 0;

              for (var item in dayData) {
                double temp = (item['main']['temp'] as num).toDouble();
                if (temp > high) high = temp;
                if (temp < low) low = temp;
                totalPop += ((item['pop'] ?? 0) as num).toDouble();
              }
              double avgPop = totalPop / dayData.length;
              final icon = WeatherUtils.getWeatherIcon(mainCondition);

              return Column(
                children: [
                  if (entry.key > 0)
                    Divider(
                        color: Colors.white.withOpacity(0.08), height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 85,
                          child: Text(
                            entry.key == 0 ? 'Tomorrow' : dayName.substring(0, 3),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(icon, color: Colors.white70, size: 22),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          child: avgPop > 0.1
                              ? Text(
                                  '${(avgPop * 100).round()}%',
                                  style: GoogleFonts.poppins(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 11,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const Spacer(),
                        Text(
                          provider.formatTemp(low),
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: _buildTemperatureBar(low, high, provider),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.formatTemp(high),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildTemperatureBar(
      double low, double high, WeatherProvider provider) {
    final lowC = WeatherUtils.convertTemp(low, 'C');
    final highC = WeatherUtils.convertTemp(high, 'C');
    final color1 = lowC < 10
        ? const Color(0xFF64B5F6)
        : lowC < 20
            ? const Color(0xFF81C784)
            : const Color(0xFFFFB74D);
    final color2 = highC > 30
        ? const Color(0xFFE57373)
        : highC > 20
            ? const Color(0xFFFFB74D)
            : const Color(0xFF81C784);

    return Container(
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(colors: [color1, color2]),
      ),
    );
  }

  // ── Weather Details Grid ──
  Widget _buildWeatherDetails(WeatherProvider provider) {
    final weather = provider.currentWeather!;
    final humidity = weather['main']['humidity'];
    final windSpeed = weather['wind']['speed'];
    final windDeg = ((weather['wind']?['deg'] ?? 0) as num).toInt();
    final pressure = weather['main']['pressure'];
    final visibility =
        ((weather['visibility'] ?? 10000) as num).toDouble() / 1000;
    final sunrise = DateTime.fromMillisecondsSinceEpoch(
        (weather['sys']['sunrise'] as num).toInt() * 1000);
    final sunset = DateTime.fromMillisecondsSinceEpoch(
        (weather['sys']['sunset'] as num).toInt() * 1000);

    final details = [
      {
        'icon': Icons.water_drop_outlined,
        'label': 'Humidity',
        'value': '$humidity%'
      },
      {
        'icon': Icons.air_rounded,
        'label': 'Wind',
        'value': '$windSpeed m/s ${WeatherUtils.getWindDirection(windDeg)}'
      },
      {
        'icon': Icons.speed_rounded,
        'label': 'Pressure',
        'value': '$pressure hPa'
      },
      {
        'icon': Icons.visibility_rounded,
        'label': 'Visibility',
        'value': '${visibility.toStringAsFixed(1)} km'
      },
      {
        'icon': Icons.wb_twilight_rounded,
        'label': 'Sunrise',
        'value': DateFormat.jm().format(sunrise)
      },
      {
        'icon': Icons.nights_stay_outlined,
        'label': 'Sunset',
        'value': DateFormat.jm().format(sunset)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Weather Details', Icons.dashboard_rounded),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: details.length,
          itemBuilder: (context, index) {
            final d = details[index];
            return GlassContainer(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(d['icon'] as IconData,
                          color: Colors.white54, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        d['label'] as String,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d['value'] as String,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Air Quality ──
  Widget _buildAirQuality(WeatherProvider provider) {
    final aqi = provider.aqi;
    if (aqi == 0) return const SizedBox.shrink();

    final color = WeatherUtils.getAQIColor(aqi);
    final label = WeatherUtils.getAQILabel(aqi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Air Quality', Icons.air_rounded),
        const SizedBox(height: 12),
        GlassContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.15),
                      border: Border.all(color: color, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        '$aqi',
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          WeatherUtils.getAQIDescription(aqi),
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: aqi / 5,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.info_outline_rounded, size: 18),
                      label: Text('Details',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side:
                            BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AirQualityScreen(
                              airQualityData: provider.aqiComponents,
                              aqi: aqi,
                              cityName: provider.currentCity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text('Weather Map',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side:
                            BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        if (provider.lat != null && provider.lon != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WeatherMapScreen(
                                lat: provider.lat!,
                                lon: provider.lon!,
                                cityName: provider.currentCity,
                              ),
                            ),
                          );
                        }
                      },
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

  // ── Temperature Chart ──
  Widget _buildTempChart(WeatherProvider provider) {
    final hourly = provider.hourlyForecast;
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Temperature Trend', Icons.show_chart_rounded),
        const SizedBox(height: 12),
        GlassContainer(
          child: TemperatureChart(
            hourlyData: hourly,
            unit: provider.temperatureUnit,
          ),
        ),
      ],
    );
  }

  // ── Suggestions ──
  Widget _buildSuggestions(WeatherProvider provider) {
    final weather = provider.currentWeather!;
    final tempC =
        (weather['main']['temp'] as num).toDouble() - 273.15;
    final condition = weather['weather'][0]['main'] as String;
    final suggestions =
        WeatherUtils.getWeatherSuggestions(condition, tempC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Suggestions', Icons.tips_and_updates_rounded),
        const SizedBox(height: 12),
        ...suggestions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassContainer(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s['icon'] as IconData,
                        color: Colors.white70, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      s['text'] as String,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Loading Skeleton ──
  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.18),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _shimmerBox(200, 30),
            const SizedBox(height: 40),
            _shimmerCircle(100),
            const SizedBox(height: 20),
            _shimmerBox(150, 60),
            const SizedBox(height: 10),
            _shimmerBox(100, 20),
            const SizedBox(height: 40),
            _shimmerBox(double.infinity, 130),
            const SizedBox(height: 24),
            _shimmerBox(double.infinity, 280),
            const SizedBox(height: 24),
            _shimmerBox(double.infinity, 200),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  // ── Error State ──
  Widget _buildError(WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Unknown error',
              style: GoogleFonts.poppins(
                  color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Try Again', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
              onPressed: () => provider.fetchWeather(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
