import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Color> _accentColors = [
    Color(0xFF6200EA),
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF00ACC1),
    Color(0xFF8BC34A),
  ];

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
                            onChanged: (_) {
                              HapticFeedback.lightImpact();
                              provider.toggleTheme();
                            },
                            activeColor: provider.accentColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Custom accent color
                    GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.palette_rounded,
                                    color: Colors.white70,
                                    size: 22),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accent Color',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Customize the app highlight color',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                _accentColors.map((color) {
                              final isSelected =
                                  provider.accentColor.value ==
                                      color.value;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  provider.setAccentColor(color);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 200),
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color
                                                  .withOpacity(0.5),
                                              blurRadius: 8,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.white,
                                          size: 18)
                                      : null,
                                ),
                              );
                            }).toList(),
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
                              provider,
                              'C',
                              'Celsius (\u00B0C)',
                              Icons.thermostat_rounded),
                          _divider(),
                          _buildUnitTile(
                              provider,
                              'F',
                              'Fahrenheit (\u00B0F)',
                              Icons.thermostat_auto_rounded),
                          _divider(),
                          _buildUnitTile(provider, 'K', 'Kelvin (K)',
                              Icons.science_rounded),
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
                                  color: provider.accentColor
                                      .withOpacity(0.3),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.cloud_rounded,
                                    color: Colors.white,
                                    size: 24),
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
                                    'Version 3.0.0',
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
                            'A feature-rich weather application built with Flutter. '
                            'Includes real-time weather, interactive maps, city comparison, '
                            'moon phases, golden hour, activity suggestions, mood journaling, '
                            'travel planner, ambient sounds, weather history, and more.',
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
      onTap: () {
        HapticFeedback.lightImpact();
        provider.changeUnit(unit);
      },
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
                decoration: BoxDecoration(
                  color: provider.accentColor,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
