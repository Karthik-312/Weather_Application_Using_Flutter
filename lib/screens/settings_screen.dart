import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Settings',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0f0c29),
                  Color(0xFF302b63),
                  Color(0xFF24243e)
                ],
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
                    _buildSectionLabel('Appearance'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              provider.isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Switch between dark and light theme',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: provider.isDarkMode,
                            onChanged: (_) => provider.toggleTheme(),
                            activeColor: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Temperature Unit'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      child: Column(
                        children: [
                          _buildUnitTile(
                              provider, 'C', 'Celsius (°C)', Icons.thermostat_rounded),
                          _divider(),
                          _buildUnitTile(provider, 'F', 'Fahrenheit (°F)',
                              Icons.thermostat_auto_rounded),
                          _divider(),
                          _buildUnitTile(
                              provider, 'K', 'Kelvin (K)', Icons.science_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionLabel('About'),
                    const SizedBox(height: 12),
                    GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.cloud_rounded,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weather App',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Version 2.0.0',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A beautiful weather application built with Flutter. '
                            'Features real-time weather data, 5-day forecasts, '
                            'air quality monitoring, temperature charts, '
                            'GPS location, and smart suggestions.',
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.api_rounded,
                                  color: Colors.white30, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Powered by OpenWeatherMap API',
                                style: GoogleFonts.poppins(
                                  color: Colors.white30,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.white.withOpacity(0.08), height: 1);
  }

  Widget _buildUnitTile(
      WeatherProvider provider, String unit, String label, IconData icon) {
    final isSelected = provider.temperatureUnit == unit;
    return InkWell(
      onTap: () => provider.changeUnit(unit),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
