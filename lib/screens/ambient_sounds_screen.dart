import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/widgets/glass_container.dart';

class AmbientSoundsScreen extends StatefulWidget {
  final String currentCondition;

  const AmbientSoundsScreen({
    super.key,
    required this.currentCondition,
  });

  @override
  State<AmbientSoundsScreen> createState() => _AmbientSoundsScreenState();
}

class _AmbientSoundsScreenState extends State<AmbientSoundsScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> _activeSounds = {
    'Rain': false,
    'Thunder': false,
    'Wind': false,
    'Birds': false,
    'Ocean': false,
    'Fireplace': false,
  };

  final Map<String, double> _volumes = {
    'Rain': 0.7,
    'Thunder': 0.5,
    'Wind': 0.6,
    'Birds': 0.4,
    'Ocean': 0.7,
    'Fireplace': 0.5,
  };

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Auto-activate sounds based on current weather
    switch (widget.currentCondition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        _activeSounds['Rain'] = true;
        break;
      case 'thunderstorm':
        _activeSounds['Rain'] = true;
        _activeSounds['Thunder'] = true;
        break;
      case 'clear':
        _activeSounds['Birds'] = true;
        break;
      case 'snow':
        _activeSounds['Wind'] = true;
        _activeSounds['Fireplace'] = true;
        break;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  bool get _hasActiveSounds =>
      _activeSounds.values.any((v) => v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Weather Ambience',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0d1b2a),
              Color(0xFF1b2838),
              Color(0xFF0d1b2a)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildVisualizer(),
                const SizedBox(height: 28),
                _buildSoundMixer(),
                const SizedBox(height: 20),
                _buildPresets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _WavePainter(
                progress: _waveController.value,
                isActive: _hasActiveSounds,
                activeSounds: _activeSounds,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundMixer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sound Mixer',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        ..._activeSounds.keys.map((sound) => _buildSoundTile(sound)),
      ],
    );
  }

  Widget _buildSoundTile(String sound) {
    final isActive = _activeSounds[sound]!;
    final volume = _volumes[sound]!;
    final info = _soundInfo(sound);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (info['color'] as Color).withOpacity(
                        isActive ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(info['icon'] as IconData,
                      color: isActive
                          ? info['color'] as Color
                          : Colors.white30,
                      size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sound,
                          style: GoogleFonts.poppins(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(info['desc'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (v) =>
                      setState(() => _activeSounds[sound] = v),
                  activeColor: info['color'] as Color,
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_down_rounded,
                      color: Colors.white24, size: 16),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: info['color'] as Color,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: info['color'] as Color,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: volume,
                        onChanged: (v) =>
                            setState(() => _volumes[sound] = v),
                      ),
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded,
                      color: Colors.white24, size: 16),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresets() {
    final presets = [
      {
        'name': 'Rainy Day',
        'icon': Icons.water_drop_rounded,
        'sounds': {'Rain': true, 'Thunder': false, 'Wind': false, 'Birds': false, 'Ocean': false, 'Fireplace': false},
      },
      {
        'name': 'Thunderstorm',
        'icon': Icons.thunderstorm_rounded,
        'sounds': {'Rain': true, 'Thunder': true, 'Wind': true, 'Birds': false, 'Ocean': false, 'Fireplace': false},
      },
      {
        'name': 'Beach',
        'icon': Icons.beach_access_rounded,
        'sounds': {'Rain': false, 'Thunder': false, 'Wind': true, 'Birds': true, 'Ocean': true, 'Fireplace': false},
      },
      {
        'name': 'Cozy Night',
        'icon': Icons.nightlight_round,
        'sounds': {'Rain': true, 'Thunder': false, 'Wind': false, 'Birds': false, 'Ocean': false, 'Fireplace': true},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Presets',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Row(
          children: presets.map((p) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeSounds.updateAll((key, _) =>
                          (p['sounds'] as Map<String, bool>)[key] ??
                          false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Icon(p['icon'] as IconData,
                            color: Colors.white54, size: 24),
                        const SizedBox(height: 6),
                        Text(p['name'] as String,
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 10),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.white24, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sound playback requires audio assets. The visual mixer above shows your current ambience configuration.',
                  style: GoogleFonts.poppins(
                      color: Colors.white24, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _soundInfo(String sound) {
    switch (sound) {
      case 'Rain':
        return {
          'icon': Icons.water_drop_rounded,
          'color': Colors.lightBlueAccent,
          'desc': 'Gentle rain drops'
        };
      case 'Thunder':
        return {
          'icon': Icons.thunderstorm_rounded,
          'color': Colors.deepPurpleAccent,
          'desc': 'Distant rumbles'
        };
      case 'Wind':
        return {
          'icon': Icons.air_rounded,
          'color': Colors.tealAccent,
          'desc': 'Soft breeze'
        };
      case 'Birds':
        return {
          'icon': Icons.flutter_dash_rounded,
          'color': Colors.greenAccent,
          'desc': 'Birdsong chorus'
        };
      case 'Ocean':
        return {
          'icon': Icons.waves_rounded,
          'color': Colors.cyanAccent,
          'desc': 'Ocean waves'
        };
      case 'Fireplace':
        return {
          'icon': Icons.local_fire_department_rounded,
          'color': Colors.orangeAccent,
          'desc': 'Crackling fire'
        };
      default:
        return {
          'icon': Icons.music_note_rounded,
          'color': Colors.white,
          'desc': ''
        };
    }
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Map<String, bool> activeSounds;

  _WavePainter({
    required this.progress,
    required this.isActive,
    required this.activeSounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final colors = <Color>[];
    if (activeSounds['Rain'] == true) colors.add(Colors.lightBlueAccent);
    if (activeSounds['Thunder'] == true) colors.add(Colors.deepPurpleAccent);
    if (activeSounds['Wind'] == true) colors.add(Colors.tealAccent);
    if (activeSounds['Birds'] == true) colors.add(Colors.greenAccent);
    if (activeSounds['Ocean'] == true) colors.add(Colors.cyanAccent);
    if (activeSounds['Fireplace'] == true) colors.add(Colors.orangeAccent);
    if (colors.isEmpty) colors.add(Colors.white30);

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      final waveHeight = 20.0 + i * 8.0;
      final freq = 2.0 + i * 0.5;
      final offset = progress * 2 * pi + i * pi / 3;

      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height / 2 +
            sin(x / size.width * freq * 2 * pi + offset) * waveHeight;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => true;
}
