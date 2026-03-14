import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Free CC-licensed sounds from Wikimedia Commons (transcoded MP3)
  static const Map<String, String> _soundUrls = {
    'Rain':
        'https://upload.wikimedia.org/wikipedia/commons/transcoded/c/cb/Heavy_rain_in_Glenshaw%2C_PA.ogg/Heavy_rain_in_Glenshaw%2C_PA.ogg.mp3',
    'Thunder':
        'https://upload.wikimedia.org/wikipedia/commons/transcoded/5/54/Thunder_Claps.ogg/Thunder_Claps.ogg.mp3',
    'Wind':
        'https://upload.wikimedia.org/wikipedia/commons/transcoded/2/2d/Howling_wind.ogg/Howling_wind.ogg.mp3',
    'Birds':
        'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/42/Bird_singing.ogg/Bird_singing.ogg.mp3',
    'Ocean':
        'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1f/Waves.ogg/Waves.ogg.mp3',
    'Fireplace':
        'https://upload.wikimedia.org/wikipedia/commons/transcoded/b/b1/Campfire_sound_ambience.ogg/Campfire_sound_ambience.ogg.mp3',
  };

  final Map<String, AudioPlayer> _players = {};
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
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errors = {};

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    for (final sound in _soundUrls.keys) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.loop);
      _players[sound] = player;
    }

    // Auto-activate sounds based on current weather
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoActivateByWeather();
    });
  }

  void _autoActivateByWeather() {
    final cond = widget.currentCondition.toLowerCase();
    if (cond == 'rain' || cond == 'drizzle') {
      _toggleSound('Rain', true);
    } else if (cond == 'thunderstorm') {
      _toggleSound('Rain', true);
      _toggleSound('Thunder', true);
    } else if (cond == 'clear') {
      _toggleSound('Birds', true);
    } else if (cond == 'snow') {
      _toggleSound('Wind', true);
      _toggleSound('Fireplace', true);
    }
  }

  Future<void> _toggleSound(String sound, bool active) async {
    if (!mounted) return;
    setState(() {
      _activeSounds[sound] = active;
      if (active) {
        _loadingStates[sound] = true;
        _errors[sound] = null;
      }
    });

    final player = _players[sound]!;
    if (active) {
      try {
        await player.setVolume(_volumes[sound]!);
        await player.play(UrlSource(_soundUrls[sound]!));
        if (mounted) {
          setState(() => _loadingStates[sound] = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loadingStates[sound] = false;
            _errors[sound] = 'Failed to load';
            _activeSounds[sound] = false;
          });
        }
      }
    } else {
      await player.stop();
      if (mounted) setState(() => _loadingStates.remove(sound));
    }
  }

  Future<void> _setVolume(String sound, double volume) async {
    setState(() => _volumes[sound] = volume);
    if (_activeSounds[sound] == true) {
      await _players[sound]!.setVolume(volume);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  bool get _hasActiveSounds => _activeSounds.values.any((v) => v);

  Future<void> _applyPreset(Map<String, bool> sounds) async {
    HapticFeedback.lightImpact();
    for (final entry in sounds.entries) {
      if (_activeSounds[entry.key] != entry.value) {
        await _toggleSound(entry.key, entry.value);
      }
    }
  }

  Future<void> _stopAll() async {
    HapticFeedback.mediumImpact();
    for (final sound in _soundUrls.keys) {
      if (_activeSounds[sound] == true) {
        await _toggleSound(sound, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Weather Ambience',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          if (_hasActiveSounds)
            TextButton.icon(
              onPressed: _stopAll,
              icon: const Icon(Icons.stop_circle_outlined,
                  color: Colors.redAccent, size: 18),
              label: Text('Stop All',
                  style: GoogleFonts.poppins(
                      color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0d1b2a), Color(0xFF1b2838), Color(0xFF0d1b2a)],
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
                const SizedBox(height: 16),
                _buildAttribution(),
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
    final isLoading = _loadingStates[sound] == true;
    final error = _errors[sound];

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
                    color: (info['color'] as Color)
                        .withOpacity(isActive ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: info['color'] as Color,
                          ),
                        )
                      : Icon(info['icon'] as IconData,
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
                              color: isActive ? Colors.white : Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                        error != null ? error : (info['desc'] as String),
                        style: GoogleFonts.poppins(
                            color: error != null
                                ? Colors.redAccent
                                : Colors.white24,
                            fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: isLoading
                      ? null
                      : (v) {
                          HapticFeedback.lightImpact();
                          _toggleSound(sound, v);
                        },
                  activeColor: info['color'] as Color,
                ),
              ],
            ),
            if (isActive && !isLoading) ...[
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
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: volume,
                        onChanged: (v) => _setVolume(sound, v),
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
        'sounds': {
          'Rain': true, 'Thunder': false, 'Wind': false,
          'Birds': false, 'Ocean': false, 'Fireplace': false,
        },
      },
      {
        'name': 'Thunderstorm',
        'icon': Icons.thunderstorm_rounded,
        'sounds': {
          'Rain': true, 'Thunder': true, 'Wind': true,
          'Birds': false, 'Ocean': false, 'Fireplace': false,
        },
      },
      {
        'name': 'Beach',
        'icon': Icons.beach_access_rounded,
        'sounds': {
          'Rain': false, 'Thunder': false, 'Wind': true,
          'Birds': true, 'Ocean': true, 'Fireplace': false,
        },
      },
      {
        'name': 'Cozy Night',
        'icon': Icons.nightlight_round,
        'sounds': {
          'Rain': true, 'Thunder': false, 'Wind': false,
          'Birds': false, 'Ocean': false, 'Fireplace': true,
        },
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
                  onTap: () => _applyPreset(
                      (p['sounds'] as Map<String, bool>)),
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
              Icon(Icons.info_outline_rounded,
                  color: Colors.white38, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sounds loop automatically. Toggle any sound on/off and adjust its volume individually.',
                  style: GoogleFonts.poppins(
                      color: Colors.white38, fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttribution() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Sounds sourced from Wikimedia Commons (CC licensed)',
        style: GoogleFonts.poppins(color: Colors.white24, fontSize: 9),
        textAlign: TextAlign.center,
      ),
    );
  }

  Map<String, dynamic> _soundInfo(String sound) {
    switch (sound) {
      case 'Rain':
        return {
          'icon': Icons.water_drop_rounded,
          'color': const Color(0xFF4FC3F7),
          'desc': 'Gentle rainfall',
        };
      case 'Thunder':
        return {
          'icon': Icons.thunderstorm_rounded,
          'color': const Color(0xFFFFB74D),
          'desc': 'Rolling thunder claps',
        };
      case 'Wind':
        return {
          'icon': Icons.air_rounded,
          'color': const Color(0xFF80CBC4),
          'desc': 'Howling wind',
        };
      case 'Birds':
        return {
          'icon': Icons.flutter_dash_rounded,
          'color': const Color(0xFFA5D6A7),
          'desc': 'Morning birdsong',
        };
      case 'Ocean':
        return {
          'icon': Icons.waves_rounded,
          'color': const Color(0xFF4DD0E1),
          'desc': 'Lakeshore waves',
        };
      case 'Fireplace':
        return {
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFFF8A65),
          'desc': 'Crackling campfire',
        };
      default:
        return {
          'icon': Icons.music_note_rounded,
          'color': Colors.white54,
          'desc': '',
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
        ..color = Colors.white.withOpacity(0.04)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Enable a sound to begin',
          style: TextStyle(color: Color(0x44FFFFFF), fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      return;
    }

    final colors = <Color>[];
    if (activeSounds['Rain'] == true) colors.add(const Color(0xFF4FC3F7));
    if (activeSounds['Thunder'] == true) colors.add(const Color(0xFFFFB74D));
    if (activeSounds['Wind'] == true) colors.add(const Color(0xFF80CBC4));
    if (activeSounds['Birds'] == true) colors.add(const Color(0xFFA5D6A7));
    if (activeSounds['Ocean'] == true) colors.add(const Color(0xFF4DD0E1));
    if (activeSounds['Fireplace'] == true) colors.add(const Color(0xFFFF8A65));

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.35)
        ..style = PaintingStyle.fill;

      final path = Path();
      final waveHeight = size.height * 0.2;
      final baseY = size.height * (0.5 + i * 0.08);
      final phaseShift = i * 0.5;

      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x++) {
        final y = baseY +
            sin((x / size.width * 2 * pi) +
                    (progress * 2 * pi) +
                    phaseShift) *
                waveHeight;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress ||
      old.isActive != isActive ||
      old.activeSounds != activeSounds;
}
