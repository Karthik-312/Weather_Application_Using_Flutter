import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/weather_utils.dart';
import 'package:weather_app/widgets/glass_container.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _city1Controller = TextEditingController();
  final _city2Controller = TextEditingController();
  Map<String, dynamic>? _weather1;
  Map<String, dynamic>? _weather2;
  int? _aqi1;
  int? _aqi2;
  bool _loading1 = false;
  bool _loading2 = false;
  String? _error1;
  String? _error2;
  bool _showMap = false;
  String _mapLayer = 'temp_new';
  List<Map<String, dynamic>> _suggestions1 = [];
  List<Map<String, dynamic>> _suggestions2 = [];
  Timer? _debounce1;
  Timer? _debounce2;

  void _onSearchChanged(String query, int index) {
    (index == 1 ? _debounce1 : _debounce2)?.cancel();
    final timer = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().length < 2) {
        setState(() {
          if (index == 1) _suggestions1 = [];
          if (index == 2) _suggestions2 = [];
        });
        return;
      }
      final results = await WeatherService.searchCities(query);
      if (mounted) {
        setState(() {
          if (index == 1) _suggestions1 = results;
          if (index == 2) _suggestions2 = results;
        });
      }
    });
    if (index == 1) _debounce1 = timer;
    else _debounce2 = timer;
  }

  void _selectCity(String cityName, int index) {
    final ctrl = index == 1 ? _city1Controller : _city2Controller;
    ctrl.text = cityName;
    setState(() {
      if (index == 1) _suggestions1 = [];
      else _suggestions2 = [];
    });
    FocusScope.of(context).unfocus();
    _fetchCity(index);
  }

  Future<void> _fetchCity(int index) async {
    final controller = index == 1 ? _city1Controller : _city2Controller;
    final city = controller.text.trim();
    if (city.isEmpty) return;

    setState(() {
      if (index == 1) {
        _loading1 = true;
        _error1 = null;
        _suggestions1 = [];
      } else {
        _loading2 = true;
        _error2 = null;
        _suggestions2 = [];
      }
    });

    try {
      final data = await WeatherService.fetchCurrentWeather(city);
      final lat = (data['coord']['lat'] as num).toDouble();
      final lon = (data['coord']['lon'] as num).toDouble();
      int? aqi;
      try {
        final aqiData = await WeatherService.fetchAirQuality(lat, lon);
        aqi = aqiData['list']?[0]?['main']?['aqi'];
      } catch (_) {}
      setState(() {
        if (index == 1) {
          _weather1 = data;
          _aqi1 = aqi;
        } else {
          _weather2 = data;
          _aqi2 = aqi;
        }
      });
    } catch (e) {
      setState(() {
        if (index == 1) {
          _error1 = e.toString();
        } else {
          _error2 = e.toString();
        }
      });
    }

    setState(() {
      if (index == 1) _loading1 = false;
      if (index == 2) _loading2 = false;
    });
  }

  @override
  void dispose() {
    _city1Controller.dispose();
    _city2Controller.dispose();
    _debounce1?.cancel();
    _debounce2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Compare Weather',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: provider.primaryTextColor)),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: provider.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildSearchField(_city1Controller, 1),
                            if (_suggestions1.isNotEmpty) _buildSuggestionsList(_suggestions1, 1),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Icon(Icons.compare_arrows_rounded,
                            color: Colors.white38, size: 28),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          children: [
                            _buildSearchField(_city2Controller, 2),
                            if (_suggestions2.isNotEmpty) _buildSuggestionsList(_suggestions2, 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_weather1 != null || _weather2 != null)
                    _buildComparison(),
                  if (_weather1 == null && _weather2 == null)
                    _buildPlaceholder(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(TextEditingController controller, int index) {
    final isLoading = index == 1 ? _loading1 : _loading2;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      borderRadius: 16,
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'City ${index}',
          hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white54)),
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: Colors.white54, size: 20),
                  onPressed: () => _fetchCity(index),
                ),
        ),
        onChanged: (v) => _onSearchChanged(v, index),
        onSubmitted: (_) => _fetchCity(index),
      ),
    );
  }

  Widget _buildSuggestionsList(List<Map<String, dynamic>> suggestions, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions.map((s) {
          final name = s['name'] ?? '';
          final country = s['country'] ?? '';
          final state = s['state'] ?? '';
          final subtitle = [if (state.toString().isNotEmpty) state, country].join(', ');
          return ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
            leading: const Icon(Icons.location_on_outlined, color: Colors.white38, size: 16),
            title: Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
            subtitle: subtitle.isNotEmpty
                ? Text(subtitle, style: GoogleFonts.poppins(color: Colors.white30, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            onTap: () => _selectCity(name, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.compare_arrows_rounded,
              size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            'Search two cities to compare\ntheir weather side by side',
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildWeatherCard(_weather1, _error1, _loading1)),
            const SizedBox(width: 12),
            Expanded(child: _buildWeatherCard(_weather2, _error2, _loading2)),
          ],
        ),
        if (_weather1 != null && _weather2 != null) ...[
          const SizedBox(height: 20),
          _buildDetailComparison(),
          const SizedBox(height: 16),
          _buildMapToggle(),
          if (_showMap) ...[
            const SizedBox(height: 12),
            _buildCompareMap(),
          ],
        ],
      ],
    );
  }

  Widget _buildWeatherCard(
      Map<String, dynamic>? weather, String? error, bool loading) {
    if (loading) {
      return const GlassContainer(
        child: Center(
            child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Colors.white54),
        )),
      );
    }
    if (error != null) {
      return GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(error,
              style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center),
        ),
      );
    }
    if (weather == null) {
      return GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Icon(Icons.cloud_outlined,
              size: 50, color: Colors.white.withOpacity(0.15)),
        ),
      );
    }

    final tempC =
        ((weather['main']['temp'] as num).toDouble() - 273.15).round();
    final condition = weather['weather'][0]['main'] as String;
    final desc = WeatherUtils.capitalizeWords(
        weather['weather'][0]['description'] ?? '');
    final name = weather['name'] ?? '';
    final country = weather['sys']?['country'] ?? '';
    final icon = WeatherUtils.getWeatherIcon(condition);

    return GlassContainer(
      child: Column(
        children: [
          Text('$name, $country',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text('$tempC°C',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w300)),
          Text(desc,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDetailComparison() {
    final w1 = _weather1!;
    final w2 = _weather2!;

    final rows = [
      {
        'label': 'Feels Like',
        'icon': Icons.thermostat_outlined,
        'v1': '${((w1['main']['feels_like'] as num).toDouble() - 273.15).round()}°C',
        'v2': '${((w2['main']['feels_like'] as num).toDouble() - 273.15).round()}°C',
      },
      {
        'label': 'Humidity',
        'icon': Icons.water_drop_outlined,
        'v1': '${w1['main']['humidity']}%',
        'v2': '${w2['main']['humidity']}%',
      },
      {
        'label': 'Wind',
        'icon': Icons.air_rounded,
        'v1': '${w1['wind']['speed']} m/s',
        'v2': '${w2['wind']['speed']} m/s',
      },
      {
        'label': 'Pressure',
        'icon': Icons.speed_rounded,
        'v1': '${w1['main']['pressure']} hPa',
        'v2': '${w2['main']['pressure']} hPa',
      },
      {
        'label': 'Visibility',
        'icon': Icons.visibility_rounded,
        'v1':
            '${(((w1['visibility'] ?? 10000) as num).toDouble() / 1000).toStringAsFixed(1)} km',
        'v2':
            '${(((w2['visibility'] ?? 10000) as num).toDouble() / 1000).toStringAsFixed(1)} km',
      },
    ];

    return GlassContainer(
      child: Column(
        children: [
          Text('Detailed Comparison',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(r['v1'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                    ),
                    Column(
                      children: [
                        Icon(r['icon'] as IconData,
                            color: Colors.white38, size: 16),
                        const SizedBox(height: 2),
                        Text(r['label'] as String,
                            style: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                    Expanded(
                      child: Text(r['v2'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMapToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showMap = !_showMap),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              _showMap ? Icons.map_rounded : Icons.map_outlined,
              color: _showMap ? Colors.deepPurpleAccent : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _showMap ? 'Hide Map' : 'View on Map',
                style: GoogleFonts.poppins(
                  color: _showMap ? Colors.deepPurpleAccent : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              _showMap
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: Colors.white38,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareMap() {
    final lat1 = (_weather1!['coord']['lat'] as num).toDouble();
    final lon1 = (_weather1!['coord']['lon'] as num).toDouble();
    final lat2 = (_weather2!['coord']['lat'] as num).toDouble();
    final lon2 = (_weather2!['coord']['lon'] as num).toDouble();

    final centerLat = (lat1 + lat2) / 2;
    final centerLon = (lon1 + lon2) / 2;

    // Rough zoom based on distance
    final dLat = (lat1 - lat2).abs();
    final dLon = (lon1 - lon2).abs();
    final maxSpan = math.max(dLat, dLon);
    double zoom;
    if (maxSpan > 60) {
      zoom = 2;
    } else if (maxSpan > 30) {
      zoom = 3;
    } else if (maxSpan > 15) {
      zoom = 4;
    } else if (maxSpan > 5) {
      zoom = 5;
    } else if (maxSpan > 2) {
      zoom = 7;
    } else {
      zoom = 9;
    }

    final name1 = _weather1!['name'] ?? '';
    final name2 = _weather2!['name'] ?? '';
    final temp1 =
        ((_weather1!['main']['temp'] as num).toDouble() - 273.15).round();
    final temp2 =
        ((_weather2!['main']['temp'] as num).toDouble() - 273.15).round();
    final cond1 = _weather1!['weather'][0]['main'] as String;
    final cond2 = _weather2!['weather'][0]['main'] as String;
    final icon1 = WeatherUtils.getWeatherIcon(cond1);
    final icon2 = WeatherUtils.getWeatherIcon(cond2);

    final layerNames = {
      'temp_new': 'Temp',
      'precipitation_new': 'Rain',
      'clouds_new': 'Clouds',
      'wind_new': 'Wind',
    };

    return Column(
      children: [
        // Map with enlarge button
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 320,
                child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(centerLat, centerLon),
                initialZoom: zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  tileProvider: NetworkTileProvider(),
                ),
                TileLayer(
                  key: ValueKey(_mapLayer),
                  urlTemplate:
                      'https://tile.openweathermap.org/map/$_mapLayer/{z}/{x}/{y}.png?appid=$openWeatherAPIKey',
                  tileProvider: NetworkTileProvider(),
                  tileBuilder: (context, tileWidget, tile) {
                    return Opacity(opacity: 0.7, child: tileWidget);
                  },
                ),
                MarkerLayer(
                  markers: [
                    _buildCityMarker(
                        LatLng(lat1, lon1), name1, temp1, icon1, Colors.deepPurple, _aqi1),
                    _buildCityMarker(
                        LatLng(lat2, lon2), name2, temp2, icon2, Colors.teal, _aqi2),
                  ],
                ),
              ],
            ),
          ),
        ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showFullScreenMap(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Layer selector
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: layerNames.entries.map((entry) {
              final active = _mapLayer == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _mapLayer = entry.key),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? Colors.deepPurple : Colors.white10,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: active
                            ? Colors.deepPurpleAccent
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: GoogleFonts.poppins(
                        color: active ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Marker _buildCityMarker(
      LatLng point, String name, int temp, IconData icon, Color color, int? aqi) {
    final aqiColor = aqi != null ? WeatherUtils.getAQISeverityColor(aqi) : null;
    return Marker(
      width: 140,
      height: 78,
      point: point,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$name $temp°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (aqi != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.air_rounded, color: Colors.white70, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        'AQI $aqi',
                        style: TextStyle(
                          color: aqiColor ?? Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.location_on_rounded, color: color, size: 26),
        ],
      ),
    );
  }

  void _showFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _FullScreenCompareMap(
          weather1: _weather1!,
          weather2: _weather2!,
          aqi1: _aqi1,
          aqi2: _aqi2,
          buildMarker: _buildCityMarker,
        ),
      ),
    );
  }
}

class _FullScreenCompareMap extends StatefulWidget {
  final Map<String, dynamic> weather1;
  final Map<String, dynamic> weather2;
  final int? aqi1;
  final int? aqi2;
  final Marker Function(LatLng, String, int, IconData, Color, int?) buildMarker;

  const _FullScreenCompareMap({
    required this.weather1,
    required this.weather2,
    this.aqi1,
    this.aqi2,
    required this.buildMarker,
  });

  @override
  State<_FullScreenCompareMap> createState() => _FullScreenCompareMapState();
}

class _FullScreenCompareMapState extends State<_FullScreenCompareMap> {
  String _mapLayer = 'temp_new';

  @override
  Widget build(BuildContext context) {
    final lat1 = (widget.weather1['coord']['lat'] as num).toDouble();
    final lon1 = (widget.weather1['coord']['lon'] as num).toDouble();
    final lat2 = (widget.weather2['coord']['lat'] as num).toDouble();
    final lon2 = (widget.weather2['coord']['lon'] as num).toDouble();
    final centerLat = (lat1 + lat2) / 2;
    final centerLon = (lon1 + lon2) / 2;
    final dLat = (lat1 - lat2).abs();
    final dLon = (lon1 - lon2).abs();
    final maxSpan = math.max(dLat, dLon);
    double zoom;
    if (maxSpan > 60) zoom = 2;
    else if (maxSpan > 30) zoom = 3;
    else if (maxSpan > 15) zoom = 4;
    else if (maxSpan > 5) zoom = 5;
    else if (maxSpan > 2) zoom = 7;
    else zoom = 9;

    final name1 = widget.weather1['name'] ?? '';
    final name2 = widget.weather2['name'] ?? '';
    final temp1 = ((widget.weather1['main']['temp'] as num).toDouble() - 273.15).round();
    final temp2 = ((widget.weather2['main']['temp'] as num).toDouble() - 273.15).round();
    final cond1 = widget.weather1['weather'][0]['main'] as String;
    final cond2 = widget.weather2['weather'][0]['main'] as String;
    final icon1 = WeatherUtils.getWeatherIcon(cond1);
    final icon2 = WeatherUtils.getWeatherIcon(cond2);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Compare Map', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(centerLat, centerLon),
                initialZoom: zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  tileProvider: NetworkTileProvider(),
                ),
                TileLayer(
                  key: ValueKey(_mapLayer),
                  urlTemplate: 'https://tile.openweathermap.org/map/$_mapLayer/{z}/{x}/{y}.png?appid=$openWeatherAPIKey',
                  tileProvider: NetworkTileProvider(),
                  tileBuilder: (c, w, t) => Opacity(opacity: 0.7, child: w),
                ),
                MarkerLayer(
                  markers: [
                    widget.buildMarker(LatLng(lat1, lon1), name1, temp1, icon1, Colors.deepPurple, widget.aqi1),
                    widget.buildMarker(LatLng(lat2, lon2), name2, temp2, icon2, Colors.teal, widget.aqi2),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLayerChip('temp_new', 'Temp'),
                _buildLayerChip('precipitation_new', 'Rain'),
                _buildLayerChip('clouds_new', 'Clouds'),
                _buildLayerChip('wind_new', 'Wind'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerChip(String key, String label) {
    final active = _mapLayer == key;
    return GestureDetector(
      onTap: () => setState(() => _mapLayer = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.deepPurple : Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: active ? Colors.white : Colors.white54)),
      ),
    );
  }
}
