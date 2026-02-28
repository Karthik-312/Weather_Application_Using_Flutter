import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/utils/weather_utils.dart';

class WeatherMapScreen extends StatefulWidget {
  final double lat;
  final double lon;
  final String cityName;

  const WeatherMapScreen({
    super.key,
    required this.lat,
    required this.lon,
    required this.cityName,
  });

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  String _activeLayer = 'temp_new';
  Map<String, dynamic>? _tappedWeather;
  LatLng? _tappedLocation;
  String? _tappedAddress;
  bool _isLoadingWeather = false;
  bool _showHint = true;
  late MapController _mapController;

  final Map<String, Map<String, dynamic>> _layers = {
    'temp_new': {'name': 'Temperature', 'icon': Icons.thermostat_rounded},
    'precipitation_new': {'name': 'Rain', 'icon': Icons.water_drop_rounded},
    'clouds_new': {'name': 'Clouds', 'icon': Icons.cloud_rounded},
    'wind_new': {'name': 'Wind', 'icon': Icons.air_rounded},
    'pressure_new': {'name': 'Pressure', 'icon': Icons.speed_rounded},
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  Future<void> _fetchWeatherAtLocation(LatLng point) async {
    setState(() {
      _tappedLocation = point;
      _tappedAddress = null;
      _isLoadingWeather = true;
      _showHint = false;
    });

    try {
      // Fetch weather and reverse geocode in parallel
      final results = await Future.wait([
        http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather'
          '?lat=${point.latitude}&lon=${point.longitude}'
          '&appid=$openWeatherAPIKey',
        )),
        http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${point.latitude}&lon=${point.longitude}'
          '&format=json&addressdetails=1&zoom=18',
        ), headers: {'User-Agent': 'WeatherApp/2.0'}),
      ]);

      final weatherData = jsonDecode(results[0].body);

      // Parse street address from Nominatim
      String? address;
      if (results[1].statusCode == 200) {
        final geoData = jsonDecode(results[1].body);
        final addr = geoData['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final parts = <String>[];
          final road = addr['road'] ?? addr['street'] ?? addr['pedestrian'];
          final neighbourhood = addr['neighbourhood'] ?? addr['suburb'];
          final city = addr['city'] ?? addr['town'] ?? addr['village'];
          if (road != null) parts.add(road.toString());
          if (neighbourhood != null) parts.add(neighbourhood.toString());
          if (city != null) parts.add(city.toString());
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      }

      if (weatherData['cod'] == 200 && mounted) {
        setState(() {
          _tappedWeather = weatherData;
          _tappedAddress = address;
          _isLoadingWeather = false;
        });
        _showWeatherBottomSheet();
      } else {
        if (mounted) setState(() => _isLoadingWeather = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  void _showWeatherBottomSheet() {
    if (_tappedWeather == null || _tappedLocation == null) return;

    final w = _tappedWeather!;
    final tempC = (w['main']['temp'] as num).toDouble() - 273.15;
    final feelsLike = (w['main']['feels_like'] as num).toDouble() - 273.15;
    final high = (w['main']['temp_max'] as num).toDouble() - 273.15;
    final low = (w['main']['temp_min'] as num).toDouble() - 273.15;
    final humidity = w['main']['humidity'];
    final windSpeed = w['wind']['speed'];
    final windDeg = ((w['wind']?['deg'] ?? 0) as num).toInt();
    final pressure = w['main']['pressure'];
    final visibility = ((w['visibility'] ?? 10000) as num).toDouble() / 1000;
    final condition = w['weather'][0]['main'] as String;
    final description =
        WeatherUtils.capitalizeWords(w['weather'][0]['description'] ?? '');
    final locationName = w['name'] ?? 'Unknown';
    final country = w['sys']?['country'] ?? '';
    final displayName = _tappedAddress ?? '$locationName${country.isNotEmpty ? ', $country' : ''}';
    final icon = WeatherUtils.getWeatherIcon(condition);
    final gradientColors = WeatherUtils.getWeatherGradient(condition, false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors.first.withOpacity(0.95),
              const Color(0xFF1a1a2e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header: icon + name + temp
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: _tappedAddress != null ? 14 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${tempC.round()}°C',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'H:${high.round()}° L:${low.round()}°',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Detail grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _detailTile(Icons.thermostat_outlined,
                            'Feels Like', '${feelsLike.round()}°C'),
                        _detailTile(Icons.water_drop_outlined,
                            'Humidity', '$humidity%'),
                        _detailTile(Icons.air_rounded, 'Wind',
                            '$windSpeed m/s ${WeatherUtils.getWindDirection(windDeg)}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _detailTile(Icons.speed_rounded, 'Pressure',
                            '$pressure hPa'),
                        _detailTile(Icons.visibility_rounded,
                            'Visibility',
                            '${visibility.toStringAsFixed(1)} km'),
                        _detailTile(
                          Icons.location_on_outlined,
                          'Coordinates',
                          '${_tappedLocation!.latitude.toStringAsFixed(3)}, '
                              '${_tappedLocation!.longitude.toStringAsFixed(3)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sunrise / sunset if available
              if (w['sys']?['sunrise'] != null &&
                  w['sys']?['sunset'] != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconLabel(
                        Icons.wb_twilight_rounded,
                        'Sunrise',
                        DateFormat.jm().format(
                          DateTime.fromMillisecondsSinceEpoch(
                              (w['sys']['sunrise'] as num).toInt() * 1000),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white12,
                      ),
                      _iconLabel(
                        Icons.nights_stay_outlined,
                        'Sunset',
                        DateFormat.jm().format(
                          DateTime.fromMillisecondsSinceEpoch(
                              (w['sys']['sunset'] as num).toInt() * 1000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 11)),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        elevation: 0,
        title: Text(
          'Weather Map — ${widget.cityName}',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.my_location_rounded, color: Colors.white),
            tooltip: 'Re-center',
            onPressed: () {
              _mapController.move(
                  LatLng(widget.lat, widget.lon), 12);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.lat, widget.lon),
              initialZoom: 10,
              onTap: (tapPos, latLng) =>
                  _fetchWeatherAtLocation(latLng),
            ),
            children: [
              // CartoDB dark base tiles (free, clean)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                tileProvider: NetworkTileProvider(),
              ),

              // OpenWeatherMap weather overlay (free)
              TileLayer(
                key: ValueKey(_activeLayer),
                urlTemplate:
                    'https://tile.openweathermap.org/map/$_activeLayer/{z}/{x}/{y}.png?appid=$openWeatherAPIKey',
                tileProvider: NetworkTileProvider(),
                tileBuilder: (context, tileWidget, tile) {
                  return Opacity(opacity: 0.75, child: tileWidget);
                },
              ),

              // Markers
              MarkerLayer(
                markers: [
                  Marker(
                    width: 50,
                    height: 50,
                    point: LatLng(widget.lat, widget.lon),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.cityName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.location_on_rounded,
                            color: Colors.deepPurpleAccent, size: 28),
                      ],
                    ),
                  ),
                  if (_tappedLocation != null)
                    Marker(
                      width: _tappedAddress != null ? 160 : 40,
                      height: _tappedAddress != null ? 55 : 40,
                      point: _tappedLocation!,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_tappedAddress != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _tappedAddress!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          const Icon(Icons.place_rounded,
                              color: Colors.redAccent, size: 30),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Tap hint ──
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showHint ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tap anywhere for street-level weather',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Loading indicator ──
          if (_isLoadingWeather)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ),

          // ── Layer selector chips ──
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _layers.entries.map((entry) {
                  final isActive = _activeLayer == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _activeLayer = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.deepPurple
                              : Colors.black87,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isActive
                                ? Colors.deepPurpleAccent
                                : Colors.white24,
                            width: 1.5,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurple
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.value['icon'] as IconData,
                              size: 16,
                              color: isActive
                                  ? Colors.white
                                  : Colors.white60,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              entry.value['name'] as String,
                              style: GoogleFonts.poppins(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Active layer legend ──
          Positioned(
            bottom: 80,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _layers[_activeLayer]!['icon'] as IconData,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _layers[_activeLayer]!['name'] as String,
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  _buildLegendBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBar() {
    List<Color> colors;
    String low, high;

    switch (_activeLayer) {
      case 'temp_new':
        colors = [
          Colors.blue.shade900,
          Colors.blue,
          Colors.cyan,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ];
        low = '-40°';
        high = '40°';
        break;
      case 'precipitation_new':
        colors = [
          Colors.transparent,
          Colors.lightBlue.shade200,
          Colors.blue,
          Colors.indigo,
          Colors.deepPurple,
        ];
        low = '0mm';
        high = '14mm';
        break;
      case 'clouds_new':
        colors = [
          Colors.transparent,
          Colors.white38,
          Colors.white70,
          Colors.white,
        ];
        low = '0%';
        high = '100%';
        break;
      case 'wind_new':
        colors = [
          Colors.green.shade200,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ];
        low = '0';
        high = '60 m/s';
        break;
      case 'pressure_new':
        colors = [
          Colors.blue.shade900,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.red,
        ];
        low = '950';
        high = '1070 hPa';
        break;
      default:
        colors = [Colors.white24, Colors.white];
        low = '';
        high = '';
    }

    return Row(
      children: [
        Text(low,
            style: GoogleFonts.poppins(
                color: Colors.white38, fontSize: 9)),
        const SizedBox(width: 4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: colors),
          ),
        ),
        const SizedBox(width: 4),
        Text(high,
            style: GoogleFonts.poppins(
                color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}
