import 'dart:math';
import 'package:flutter/material.dart';

class WeatherParticles extends StatefulWidget {
  final String condition;

  const WeatherParticles({super.key, required this.condition});

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  bool get _isRain {
    final c = widget.condition.toLowerCase();
    return c.contains('rain') || c.contains('drizzle') || c.contains('thunderstorm');
  }

  bool get _isSnow => widget.condition.toLowerCase().contains('snow');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _spawnParticles();
  }

  void _spawnParticles() {
    final count = _isRain ? 70 : _isSnow ? 45 : 0;
    _particles = List.generate(count, (_) => _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: _isRain
          ? 0.5 + _random.nextDouble() * 0.5
          : 0.15 + _random.nextDouble() * 0.2,
      size: _isRain
          ? 1.2 + _random.nextDouble() * 1.5
          : 2.0 + _random.nextDouble() * 3.5,
      opacity: 0.25 + _random.nextDouble() * 0.45,
      drift: (_random.nextDouble() - 0.5) * 0.12,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRain && !_isSnow) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            isRain: _isRain,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;
  final double drift;

  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.drift,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isRain;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isRain,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (p.y + progress * p.speed) % 1.0;
      final py = t * size.height;
      final px = isRain
          ? (p.x + progress * 0.04) * size.width
          : (p.x + p.drift * progress * 8) * size.width;

      final paint = Paint()
        ..color = (isRain
                ? const Color(0xFF90CAF9)
                : Colors.white)
            .withOpacity(p.opacity)
        ..strokeWidth = p.size
        ..strokeCap = StrokeCap.round
        ..style = isRain ? PaintingStyle.stroke : PaintingStyle.fill;

      if (isRain) {
        canvas.drawLine(
          Offset(px, py),
          Offset(px - p.size * 0.8, py + 12 * p.size),
          paint,
        );
      } else {
        canvas.drawCircle(Offset(px, py), p.size, paint);
        // Simple snowflake cross lines
        final linePaint = Paint()
          ..color = Colors.white.withOpacity(p.opacity * 0.6)
          ..strokeWidth = 0.8;
        canvas.drawLine(
            Offset(px - p.size, py), Offset(px + p.size, py), linePaint);
        canvas.drawLine(
            Offset(px, py - p.size), Offset(px, py + p.size), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
